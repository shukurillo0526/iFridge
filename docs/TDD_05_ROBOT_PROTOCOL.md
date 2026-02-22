# Section 5: The "Robot Ready" Protocol

> **Design Mantra:** "If a robot can't parse it, it's not a recipe — it's a suggestion."

---

## 5.1 Why "Robot-Ready" from Day 1?

Building robot-compatible data structures retroactively is a rewrite, not a refactor. By designing the `recipe_steps.robot_action` JSONB schema (Section 1) as the **single source of truth**, we ensure:

1. **The app and the robot read the same data.** The Flutter UI renders `human_text`. The robot reads `robot_action`.
2. **No translation layer is needed.** The FastAPI endpoint simply serializes the existing `robot_action` JSONB and streams it to the robotic controller.
3. **New robot capabilities** (e.g., temperature sensing) are added as optional fields in the JSON schema, not as schema migrations.

---

## 5.2 Communication Architecture

```
┌─────────────────┐         ┌──────────────────┐        ┌──────────────┐
│  Flutter App     │         │   FastAPI Server  │        │  Robot ARM    │
│  (User selects   │  POST   │                  │  WSS   │  Controller   │
│   "Cook This")   │────────▶│  /robot/execute   │───────▶│  (ROS2 Node)  │
│                  │         │                  │        │               │
│                  │◀────────│  WebSocket        │◀───────│  Status Feed  │
│  Live Status     │   WSS   │  /robot/status    │  WSS   │  Telemetry    │
└─────────────────┘         └──────────────────┘        └──────────────┘
```

### Protocol Choice: **WebSocket** over REST

Robot cooking is a **stateful, long-running operation**. REST poll-based status is wasteful. WebSocket provides:
- Real-time step progress updates
- Immediate error/halt notifications
- Bidirectional communication (user can pause/cancel mid-recipe)

---

## 5.3 Robot Command Schema

### The `RobotExecutionPlan`

When a user taps "Cook with Robot," the backend constructs a full `RobotExecutionPlan`:

```python
# app/models/robot.py

from pydantic import BaseModel
from typing import Optional

class RobotActionParameters(BaseModel):
    technique: Optional[str] = None       # "julienne", "dice", "mince"
    thickness_mm: Optional[float] = None
    length_mm: Optional[float] = None
    volume_ml: Optional[float] = None
    weight_grams: Optional[float] = None
    speed_rpm: Optional[int] = None
    rate: Optional[str] = None            # "slow", "medium", "fast"
    arrangement: Optional[str] = None
    garnish: Optional[str] = None

class SensorCheck(BaseModel):
    type: str               # "temperature", "color", "texture", "time"
    target_value: str       # "golden_brown", "165F", "al_dente"
    tolerance: Optional[str] = None  # "±5F"

class RobotAction(BaseModel):
    step_number: int
    action: str             # controlled vocabulary: CUT, HEAT, MIX, POUR, SEASON, WAIT, PLATE
    target: str             # canonical ingredient name or output from previous step
    tool: Optional[str] = None
    parameters: RobotActionParameters
    duration_seconds: Optional[int] = None
    temperature_celsius: Optional[float] = None
    sensor_check: Optional[SensorCheck] = None
    dependencies: list[int] = []         # step_numbers that must complete first
    outputs: list[str] = []              # named outputs for subsequent steps
    requires_attention: bool = True
    human_text: str                      # human-readable description

class RobotExecutionPlan(BaseModel):
    plan_id: str
    recipe_id: str
    recipe_title: str
    total_steps: int
    estimated_total_seconds: int
    actions: list[RobotAction]
    safety_warnings: list[str]           # e.g. "Hot oil involved in step 3"
```

---

## 5.4 Sample JSON Payload — "Step 1: Julienne the Carrots"

This is the **exact payload** the FastAPI backend would send to a robotic arm controller for Step 1 of a stir-fry recipe:

```json
{
  "plan_id": "exec_a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "recipe_id": "rec_98f7e6d5-c4b3-a291-8070-6f5e4d3c2b1a",
  "recipe_title": "Vegetable Stir-Fry with Ginger Soy Glaze",
  "total_steps": 8,
  "estimated_total_seconds": 1620,
  "current_step": {
    "step_number": 1,
    "action": "CUT",
    "target": "carrot",
    "tool": "chef_knife",
    "parameters": {
      "technique": "julienne",
      "thickness_mm": 3.0,
      "length_mm": 50.0,
      "weight_grams": 200.0
    },
    "duration_seconds": null,
    "temperature_celsius": null,
    "sensor_check": null,
    "dependencies": [],
    "outputs": ["julienned_carrot"],
    "requires_attention": false,
    "human_text": "Julienne 200g of carrots into 3mm × 50mm strips."
  },
  "safety_warnings": [
    "Step 3 involves hot oil at 180°C. Ensure splash guard is engaged.",
    "Step 5 involves open flame. Verify fire suppression system is armed."
  ],
  "kitchen_state": {
    "required_ingredients": [
      {"name": "carrot", "quantity": 200, "unit": "g", "location": "fridge_drawer_2"},
      {"name": "bell_pepper", "quantity": 150, "unit": "g", "location": "fridge_drawer_2"},
      {"name": "soy_sauce", "quantity": 30, "unit": "ml", "location": "pantry_shelf_1"},
      {"name": "ginger", "quantity": 15, "unit": "g", "location": "fridge_door_3"}
    ],
    "required_tools": ["chef_knife", "cutting_board", "wok", "spatula"],
    "required_appliances": ["stove_burner_1"]
  }
}
```

---

## 5.5 FastAPI Robot Endpoints

```python
# app/api/routes/robot.py

from fastapi import APIRouter, WebSocket, WebSocketDisconnect
from app.services.robot_planner import RobotPlanner

router = APIRouter(prefix="/api/v1/robot", tags=["robot"])

@router.post("/plan/{recipe_id}")
async def create_execution_plan(
    recipe_id: str,
    user_id: str,
    planner: RobotPlanner = Depends(),
):
    """
    Generates a full RobotExecutionPlan from a recipe.
    Does NOT start execution — just prepares and validates.
    
    Validation includes:
    - All ingredients are in user's inventory
    - All required tools are registered with the robot
    - No safety conflicts detected
    """
    plan = await planner.create_plan(recipe_id, user_id)
    return plan


@router.websocket("/execute/{plan_id}")
async def execute_plan(
    websocket: WebSocket,
    plan_id: str,
):
    """
    WebSocket connection for robot execution.
    
    Client → Server messages:
      {"command": "start"}
      {"command": "pause"}
      {"command": "resume"}
      {"command": "cancel"}
      {"command": "skip_step", "step_number": 3}
    
    Server → Client messages:
      {"type": "step_started",   "step": 1, "action": "CUT", "target": "carrot"}
      {"type": "step_progress",  "step": 1, "percent": 45}
      {"type": "step_completed", "step": 1, "outputs": ["julienned_carrot"]}
      {"type": "sensor_reading", "step": 3, "sensor": "temperature", "value": 175.2}
      {"type": "error",          "step": 3, "code": "TOOL_NOT_FOUND", "message": "..."}
      {"type": "recipe_complete","total_time_seconds": 1580}
    """
    await websocket.accept()
    
    try:
        # Initial handshake
        await websocket.send_json({
            "type": "connected",
            "plan_id": plan_id,
            "status": "ready"
        })
        
        while True:
            data = await websocket.receive_json()
            command = data.get("command")
            
            if command == "start":
                await _stream_execution(websocket, plan_id)
            elif command == "pause":
                await _pause_execution(plan_id)
                await websocket.send_json({"type": "paused"})
            elif command == "cancel":
                await _cancel_execution(plan_id)
                await websocket.send_json({"type": "cancelled"})
                break
                
    except WebSocketDisconnect:
        await _emergency_stop(plan_id)  # Safety first
```

---

## 5.6 Safety Architecture

Robot operations require a layered safety model:

| Layer | Mechanism | Example |
|-------|-----------|---------|
| **L0: Hardware** | Physical emergency stop button | Red button on robot arm |
| **L1: Controller** | ROS2 safety node monitors force/torque | Stop if unexpected resistance |
| **L2: Backend** | Pre-execution validation | Reject plan if knife tool is not calibrated |
| **L3: App** | User confirmation for dangerous steps | "Step 3 involves hot oil. Proceed?" |
| **L4: WebSocket** | Disconnect = Emergency Stop | If app disconnects, robot halts immediately |

```python
# L4 Implementation
async def _emergency_stop(plan_id: str):
    """If WebSocket drops, immediately halt all robot operations."""
    await robot_controller.send_command({
        "command": "EMERGENCY_STOP",
        "plan_id": plan_id,
        "reason": "client_disconnected",
        "timestamp": datetime.utcnow().isoformat()
    })
    # Log for incident review
    logger.critical(f"EMERGENCY STOP triggered for plan {plan_id}: client disconnected")
```

---

## 5.7 Future Integration Roadmap

| Phase | Capability | Backend Change |
|-------|-----------|----------------|
| **V1 (Now)** | App-only, structured data | JSONB schema in place |
| **V2** | Simulation mode — 3D visualization of robot steps | New `/robot/simulate` endpoint, Three.js viewer |
| **V3** | Real robot arm (single station) | ROS2 bridge via WebSocket, safety layer activation |
| **V4** | Multi-station kitchen (parallel execution) | DAG-based step scheduler, concurrent action streams |
| **V5** | Fleet management (commercial kitchens) | Multi-tenant plan orchestrator, queue management |

---

*← [Section 4: Vision Pipeline](./TDD_04_VISION_PIPELINE.md) | [Back to Overview](./TDD_00_OVERVIEW.md)*
