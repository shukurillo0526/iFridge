"""
I-Fridge — Robot API Routes
==============================
Endpoints for robot execution plan generation and WebSocket control.
"""

import json
import logging
from datetime import datetime
from fastapi import APIRouter, WebSocket, WebSocketDisconnect, HTTPException, Depends

from app.services.robot_planner import RobotPlanner, RobotPlannerError
from app.models.robot import RobotExecutionPlan

router = APIRouter(prefix="/api/v1/robot", tags=["robot"])
logger = logging.getLogger(__name__)


@router.post("/plan/{recipe_id}", response_model=RobotExecutionPlan)
async def create_execution_plan(
    recipe_id: str,
    user_id: str,
):
    """
    Generate a validated RobotExecutionPlan from a recipe.

    **Does NOT start execution** — just prepares, validates, and returns the plan.

    **Validation includes:**
    - Recipe exists and has structured steps
    - All required ingredients are available
    - Safety warnings are auto-generated for heat/sharp tool steps
    - Step dependencies form a valid execution graph
    """
    try:
        planner = RobotPlanner()
        plan = await planner.create_plan(recipe_id, user_id)
        return plan

    except RobotPlannerError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.websocket("/execute/{plan_id}")
async def execute_plan(websocket: WebSocket, plan_id: str):
    """
    WebSocket connection for real-time robot execution control.

    **Client → Server commands:**
    - `{"command": "start"}` — Begin execution
    - `{"command": "pause"}` — Pause at current step boundary
    - `{"command": "resume"}` — Resume paused execution
    - `{"command": "cancel"}` — Cancel and safe-stop
    - `{"command": "skip_step", "step_number": 3}` — Skip a step

    **Server → Client status updates:**
    - `step_started` — A new step is beginning
    - `step_progress` — Progress % within a step
    - `step_completed` — Step finished, outputs available
    - `sensor_reading` — Real-time sensor data
    - `error` — An error occurred
    - `recipe_complete` — All steps finished
    """
    await websocket.accept()

    try:
        # Initial handshake
        await websocket.send_json({
            "type": "connected",
            "plan_id": plan_id,
            "status": "ready",
            "timestamp": datetime.utcnow().isoformat(),
        })

        while True:
            data = await websocket.receive_json()
            command = data.get("command")

            if command == "start":
                await websocket.send_json({
                    "type": "execution_started",
                    "plan_id": plan_id,
                    "message": "Robot execution initiated. Monitoring...",
                })
                # In production: stream execution events from ROS2 bridge
                # For now: acknowledge the command
                logger.info(f"Plan {plan_id}: execution started")

            elif command == "pause":
                await websocket.send_json({
                    "type": "paused",
                    "plan_id": plan_id,
                    "message": "Execution paused at current step boundary.",
                })
                logger.info(f"Plan {plan_id}: paused")

            elif command == "resume":
                await websocket.send_json({
                    "type": "resumed",
                    "plan_id": plan_id,
                    "message": "Execution resumed.",
                })
                logger.info(f"Plan {plan_id}: resumed")

            elif command == "cancel":
                await websocket.send_json({
                    "type": "cancelled",
                    "plan_id": plan_id,
                    "message": "Execution cancelled. Robot entering safe state.",
                })
                logger.info(f"Plan {plan_id}: cancelled by user")
                break

            elif command == "skip_step":
                step = data.get("step_number")
                await websocket.send_json({
                    "type": "step_skipped",
                    "step": step,
                    "message": f"Step {step} skipped.",
                })
                logger.info(f"Plan {plan_id}: step {step} skipped")

            else:
                await websocket.send_json({
                    "type": "error",
                    "error_code": "UNKNOWN_COMMAND",
                    "message": f"Unknown command: {command}",
                })

    except WebSocketDisconnect:
        # SAFETY: If client disconnects, trigger emergency stop
        logger.critical(
            f"EMERGENCY STOP for plan {plan_id}: client disconnected unexpectedly"
        )
        # In production: send halt command to ROS2 bridge
        # await robot_controller.emergency_stop(plan_id)
