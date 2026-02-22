"""
I-Fridge — Recommendation API Routes
======================================
Endpoints for the 5-Tier recipe recommendation engine.
"""

from fastapi import APIRouter, Depends, Query, HTTPException
from app.services.recommendation_engine import RecommendationEngine
from app.models.recommendation import RecommendationResponse

router = APIRouter(prefix="/api/v1", tags=["recommendations"])


@router.post("/recommend", response_model=RecommendationResponse)
async def get_recommendations(
    user_id: str,
    max_per_tier: int = Query(default=10, le=50, description="Max recipes per tier"),
    include_tier5: bool = Query(default=True, description="Include Tier 5 global search"),
):
    """
    Generate tier-grouped recipe recommendations for a user.

    The engine:
    1. Loads the user's inventory, cook history, and flavor profile
    2. Classifies all matching recipes into Tiers 1-4
    3. Scores each recipe with a composite Relevance Score
    4. Optionally runs Tier 5 semantic search for global discovery
    5. Returns recipes grouped by tier, sorted by relevance

    **Tiers:**
    - **Tier 1:** 100% match + cooked before ("Comfort Food")
    - **Tier 2:** 100% match + never cooked ("Discovery")
    - **Tier 3:** Missing 1-3 items + cooked before
    - **Tier 4:** Missing 1-3 items + never cooked
    - **Tier 5:** Semantic search ranked by Flavor Profile
    """
    try:
        engine = RecommendationEngine()
        result = await engine.generate(
            user_id=user_id,
            max_per_tier=max_per_tier,
            include_tier5=include_tier5,
        )
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
