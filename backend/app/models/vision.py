"""
I-Fridge — Vision Models
=========================
Pydantic models for the Clarifai vision pipeline.
"""

from pydantic import BaseModel, Field
from typing import Optional


class VisionPrediction(BaseModel):
    """A single Clarifai prediction mapped to our ingredient system."""
    clarifai_concept: str
    clarifai_id: str
    confidence: float = Field(ge=0.0, le=1.0)
    action: str  # "auto_add", "confirm", "correct"
    canonical_match: Optional[dict] = None  # {id, canonical_name, display_name_en}
    alternatives: list[dict] = []           # similar ingredients for correction UI


class VisionResponse(BaseModel):
    """Grouped response from the vision recognition endpoint."""
    auto_added: list[str] = []      # inventory item IDs that were auto-added
    confirm: list[VisionPrediction] = []
    correct: list[VisionPrediction] = []


class CorrectionRequest(BaseModel):
    """User correction of a vision prediction."""
    original_prediction: str
    corrected_ingredient_id: str
    clarifai_concept_id: Optional[str] = None
    confidence: Optional[float] = None
    image_storage_path: Optional[str] = None
