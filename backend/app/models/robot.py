"""
I-Fridge — Robot Protocol Models
==================================
Pydantic models for robot-ready recipe execution.
These models define the exact JSON shape sent to a robotic controller.
"""

from pydantic import BaseModel, Field
from typing import Optional


class RobotActionParameters(BaseModel):
    """Fine-grained parameters for a robot action."""
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
    """Sensor-based completion criteria for a robot action."""
    type: str               # "temperature", "color", "texture", "time"
    target_value: str       # "golden_brown", "165F", "al_dente"
    tolerance: Optional[str] = None  # "±5F"


class RobotAction(BaseModel):
    """A single machine-parseable recipe step."""
    step_number: int
    action: str             # CUT, HEAT, MIX, POUR, SEASON, WAIT, PLATE
    target: str             # canonical ingredient name or previous step output
    tool: Optional[str] = None
    parameters: RobotActionParameters = Field(default_factory=RobotActionParameters)
    duration_seconds: Optional[int] = None
    temperature_celsius: Optional[float] = None
    sensor_check: Optional[SensorCheck] = None
    dependencies: list[int] = []
    outputs: list[str] = []
    requires_attention: bool = True
    human_text: str = ""


class KitchenIngredient(BaseModel):
    """An ingredient needed for execution, with location info."""
    name: str
    quantity: float
    unit: str
    location: Optional[str] = None  # "fridge_drawer_2"


class KitchenState(BaseModel):
    """The current kitchen state needed for plan execution."""
    required_ingredients: list[KitchenIngredient] = []
    required_tools: list[str] = []
    required_appliances: list[str] = []


class RobotExecutionPlan(BaseModel):
    """
    The full execution plan sent to a robot controller.
    Contains all steps, safety warnings, and kitchen state.
    """
    plan_id: str
    recipe_id: str
    recipe_title: str
    total_steps: int
    estimated_total_seconds: int
    actions: list[RobotAction]
    safety_warnings: list[str] = []
    kitchen_state: KitchenState = Field(default_factory=KitchenState)


# --- WebSocket Message Models ---

class RobotCommand(BaseModel):
    """Client → Server WebSocket message."""
    command: str  # "start", "pause", "resume", "cancel", "skip_step"
    step_number: Optional[int] = None


class RobotStatusUpdate(BaseModel):
    """Server → Client WebSocket message."""
    type: str  # "step_started", "step_progress", "step_completed", "error", ...
    step: Optional[int] = None
    action: Optional[str] = None
    target: Optional[str] = None
    percent: Optional[float] = None
    outputs: Optional[list[str]] = None
    sensor_type: Optional[str] = None
    sensor_value: Optional[float] = None
    error_code: Optional[str] = None
    message: Optional[str] = None
    total_time_seconds: Optional[int] = None
