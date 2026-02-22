"""
I-Fridge — Recommendation Models
==================================
Pydantic models for the 5-Tier recommendation engine.
"""

from pydantic import BaseModel, Field
from enum import IntEnum
from typing import Optional
from datetime import datetime


class Tier(IntEnum):
    """The 5-Tier recommendation hierarchy."""
    INSTANT_COMFORT = 1       # 100% match + cooked before
    INSTANT_DISCOVERY = 2     # 100% match + never cooked
    MINOR_SHOP_COMFORT = 3    # missing 1-3 items + cooked before
    MINOR_SHOP_DISCOVERY = 4  # missing 1-3 items + never cooked
    GLOBAL_SEARCH = 5         # semantic search by flavor profile


class ScoredRecipe(BaseModel):
    """A recipe scored and classified by the recommendation engine."""
    recipe_id: str
    title: str
    tier: Tier
    relevance_score: float = Field(ge=0.0, le=1.0)
    match_percentage: float = Field(ge=0.0, le=1.0)
    missing_ingredients: list[str] = []
    expiry_urgency: float = Field(ge=0.0, le=1.0, default=0.0)
    flavor_affinity: float = Field(ge=0.0, le=1.0, default=0.5)
    is_comfort: bool = False
    image_url: Optional[str] = None
    cuisine: Optional[str] = None
    prep_time_minutes: Optional[int] = None


class UrgentItem(BaseModel):
    """An inventory item nearing expiry."""
    ingredient_name: str
    days_remaining: int
    quantity: float
    unit: str


class RecommendationResponse(BaseModel):
    """The full response from the recommendation endpoint."""
    user_id: str
    generated_at: str = Field(default_factory=lambda: datetime.utcnow().isoformat())
    tiers: dict[int, list[ScoredRecipe]] = {1: [], 2: [], 3: [], 4: [], 5: []}
    urgent_items: list[UrgentItem] = []
    total_recipes: int = 0
