# Section 2: The "5-Tier" Recommendation Engine (Python/FastAPI)

> **Principle:** The engine is a **funnel**, not a switch. Every request flows through all 5 tiers and aggregates scored results. The UI then presents them in tier-grouped carousels.

---

## 2.1 Architecture Overview

```
User taps "What can I cook?"
            │
            ▼
   ┌─────────────────┐
   │  /recommend      │  FastAPI Endpoint
   │  POST {user_id}  │
   └────────┬────────┘
            │
   ┌────────▼────────┐
   │ Load User Context│  Inventory, History, Flavor Profile
   └────────┬────────┘
            │
   ┌────────▼────────────────────────────────────┐
   │               TIER PIPELINE                  │
   │  ┌───────┐ ┌───────┐ ┌───────┐ ┌───────┐   │
   │  │Tier 1 │→│Tier 2 │→│Tier 3 │→│Tier 4 │   │
   │  │& 2    │ │       │ │& 4    │ │       │   │
   │  └───────┘ └───────┘ └───────┘ └───────┘   │
   │                    │                         │
   │              ┌─────▼─────┐                   │
   │              │  Tier 5   │ Semantic Search    │
   │              └───────────┘                   │
   └─────────────────┬───────────────────────────┘
                     │
            ┌────────▼────────┐
            │  Score & Rank   │  Relevance Score per recipe
            └────────┬────────┘
                     │
            ┌────────▼────────┐
            │  JSON Response  │  Tier-grouped, scored, sorted
            └─────────────────┘
```

---

## 2.2 Core Data Models

```python
# app/models/recommendation.py

from pydantic import BaseModel
from enum import IntEnum
from typing import Optional

class Tier(IntEnum):
    INSTANT_COMFORT = 1       # 100% match + cooked before
    INSTANT_DISCOVERY = 2     # 100% match + never cooked
    MINOR_SHOP_COMFORT = 3    # missing 1-3 items + cooked before
    MINOR_SHOP_DISCOVERY = 4  # missing 1-3 items + never cooked
    GLOBAL_SEARCH = 5         # semantic search by flavor profile

class ScoredRecipe(BaseModel):
    recipe_id: str
    title: str
    tier: Tier
    relevance_score: float          # 0.0 – 1.0
    match_percentage: float         # ingredient match %
    missing_ingredients: list[str]
    expiry_urgency: float           # higher = uses soon-to-expire items
    flavor_affinity: float          # cosine similarity to user profile
    is_comfort: bool                # user has cooked this before
    image_url: Optional[str] = None

class RecommendationResponse(BaseModel):
    user_id: str
    generated_at: str
    tiers: dict[int, list[ScoredRecipe]]  # {1: [...], 2: [...], ...}
    urgent_items: list[dict]              # items expiring within 2 days
```

---

## 2.3 The Tier Classification Query

The central query that powers Tiers 1–4 is a **single SQL query** that computes match percentage per recipe:

```python
# app/services/recommendation_engine.py

TIER_QUERY = """
WITH user_inventory AS (
    -- Get all ingredient IDs the user currently has
    SELECT DISTINCT ingredient_id
    FROM inventory_items
    WHERE user_id = :user_id
      AND computed_expiry >= CURRENT_DATE  -- not expired
      AND quantity > 0
),
recipe_match AS (
    SELECT
        r.id AS recipe_id,
        r.title,
        r.flavor_vectors,
        r.image_url,
        COUNT(ri.id)                                    AS total_ingredients,
        COUNT(ui.ingredient_id)                         AS matched_ingredients,
        COUNT(ri.id) - COUNT(ui.ingredient_id)          AS missing_count,
        ROUND(
            COUNT(ui.ingredient_id)::NUMERIC / NULLIF(COUNT(ri.id), 0), 
            2
        )                                                AS match_pct,
        -- Aggregate missing ingredient names for display
        ARRAY_AGG(
            CASE WHEN ui.ingredient_id IS NULL 
                 THEN ing.display_name_en END
        ) FILTER (WHERE ui.ingredient_id IS NULL)       AS missing_names
    FROM recipes r
    JOIN recipe_ingredients ri ON ri.recipe_id = r.id
    JOIN ingredients ing       ON ing.id = ri.ingredient_id
    LEFT JOIN user_inventory ui ON ui.ingredient_id = ri.ingredient_id
    WHERE ri.is_optional = FALSE  -- only count required ingredients
    GROUP BY r.id, r.title, r.flavor_vectors, r.image_url
),
user_history AS (
    -- Recipes the user has cooked before
    SELECT DISTINCT recipe_id
    FROM user_recipe_history
    WHERE user_id = :user_id
)
SELECT
    rm.recipe_id,
    rm.title,
    rm.match_pct,
    rm.missing_count,
    rm.missing_names,
    rm.flavor_vectors,
    rm.image_url,
    CASE WHEN uh.recipe_id IS NOT NULL THEN TRUE ELSE FALSE END AS is_comfort,
    -- Tier classification
    CASE
        WHEN rm.match_pct = 1.0 AND uh.recipe_id IS NOT NULL THEN 1
        WHEN rm.match_pct = 1.0 AND uh.recipe_id IS NULL     THEN 2
        WHEN rm.missing_count BETWEEN 1 AND 3 AND uh.recipe_id IS NOT NULL THEN 3
        WHEN rm.missing_count BETWEEN 1 AND 3 AND uh.recipe_id IS NULL     THEN 4
        ELSE NULL  -- Tier 5 handled separately
    END AS tier
FROM recipe_match rm
LEFT JOIN user_history uh ON uh.recipe_id = rm.recipe_id
WHERE rm.missing_count <= 3  -- Tiers 1-4 only
ORDER BY tier ASC, rm.match_pct DESC;
"""
```

---

## 2.4 Relevance Score Calculation

The **Relevance Score** is a weighted composite of three signals:

```
RelevanceScore = (w1 × ExpiryUrgency) + (w2 × FlavorAffinity) + (w3 × FamiliarityBoost)
```

| Weight | Signal | Range | Description |
|--------|--------|-------|-------------|
| `w1 = 0.45` | Expiry Urgency | 0.0–1.0 | Prioritize recipes that use soon-to-expire items |
| `w2 = 0.35` | Flavor Affinity | 0.0–1.0 | Cosine similarity between recipe and user flavor vectors |
| `w3 = 0.20` | Familiarity Boost | 0.0–1.0 | Slight boost for comfort food (Tiers 1 & 3) |

```python
# app/services/scoring.py

import numpy as np
from datetime import date, timedelta

# --- Weights ---
W_EXPIRY    = 0.45
W_FLAVOR    = 0.35
W_FAMILIAR  = 0.20

FLAVOR_AXES = ["sweet", "salty", "sour", "bitter", "umami", "spicy"]


def compute_expiry_urgency(
    recipe_ingredient_ids: list[str],
    user_inventory: dict[str, date],     # {ingredient_id: computed_expiry}
    horizon_days: int = 7
) -> float:
    """
    Score = average normalized urgency of matched ingredients.
    Items expiring today = 1.0, items expiring in `horizon_days`+ = 0.0.
    """
    today = date.today()
    urgencies = []

    for ing_id in recipe_ingredient_ids:
        expiry = user_inventory.get(ing_id)
        if expiry is None:
            continue  # missing ingredient, skip
        
        days_left = (expiry - today).days
        # Clamp to [0, horizon_days]
        normalized = max(0.0, 1.0 - (days_left / horizon_days))
        urgencies.append(normalized)

    return float(np.mean(urgencies)) if urgencies else 0.0


def compute_flavor_affinity(
    recipe_vectors: dict[str, float],    # {"sweet": 0.3, "umami": 0.9, ...}
    user_profile: dict[str, float]       # {"sweet": 0.5, "umami": 0.7, ...}
) -> float:
    """Cosine similarity between recipe flavor vector and user taste profile."""
    r_vec = np.array([recipe_vectors.get(axis, 0.5) for axis in FLAVOR_AXES])
    u_vec = np.array([user_profile.get(axis, 0.5) for axis in FLAVOR_AXES])

    dot = np.dot(r_vec, u_vec)
    norm = np.linalg.norm(r_vec) * np.linalg.norm(u_vec)
    
    return float(dot / norm) if norm > 0 else 0.5


def compute_relevance_score(
    expiry_urgency: float,
    flavor_affinity: float,
    is_comfort: bool
) -> float:
    """Final weighted relevance score."""
    familiarity = 1.0 if is_comfort else 0.2
    
    score = (
        W_EXPIRY   * expiry_urgency +
        W_FLAVOR   * flavor_affinity +
        W_FAMILIAR * familiarity
    )
    return round(min(1.0, max(0.0, score)), 3)
```

---

## 2.5 Tier 5: Semantic Global Search

Tier 5 fires when Tiers 1–4 return fewer than a minimum threshold (e.g., <5 recipes), or the user explicitly taps "Explore More."

```python
# app/services/tier5_search.py

from supabase import Client

def tier5_semantic_search(
    supabase: Client,
    user_flavor_profile: dict[str, float],
    dietary_tags: list[str],
    limit: int = 20
) -> list[dict]:
    """
    Search the full recipe database, ranked by flavor profile affinity.
    Uses Supabase's pgvector extension for vector similarity search.
    
    Prerequisite: recipes.flavor_embedding column (vector(6)) populated
    from flavor_vectors JSONB via a DB trigger.
    """
    # Build the query vector from user profile
    query_vector = [
        user_flavor_profile.get(axis, 0.5)
        for axis in ["sweet", "salty", "sour", "bitter", "umami", "spicy"]
    ]

    # Use Supabase RPC to call a pgvector similarity function
    result = supabase.rpc("search_recipes_by_flavor", {
        "query_embedding": query_vector,
        "dietary_filter": dietary_tags,
        "match_count": limit
    }).execute()

    return result.data
```

**Corresponding Postgres function:**

```sql
CREATE OR REPLACE FUNCTION search_recipes_by_flavor(
    query_embedding vector(6),
    dietary_filter  TEXT[],
    match_count     INT DEFAULT 20
)
RETURNS TABLE (
    recipe_id   UUID,
    title       TEXT,
    similarity  FLOAT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        r.id,
        r.title,
        1 - (r.flavor_embedding <=> query_embedding) AS similarity
    FROM recipes r
    WHERE (
        array_length(dietary_filter, 1) IS NULL
        OR r.tags && dietary_filter
    )
    ORDER BY r.flavor_embedding <=> query_embedding
    LIMIT match_count;
END;
$$ LANGUAGE plpgsql;
```

---

## 2.6 FastAPI Endpoint

```python
# app/api/routes/recommendations.py

from fastapi import APIRouter, Depends, Query
from app.services.recommendation_engine import RecommendationEngine
from app.models.recommendation import RecommendationResponse

router = APIRouter(prefix="/api/v1", tags=["recommendations"])

@router.post("/recommend", response_model=RecommendationResponse)
async def get_recommendations(
    user_id: str,
    max_per_tier: int = Query(default=10, le=50),
    include_tier5: bool = Query(default=True),
    engine: RecommendationEngine = Depends()
):
    """
    Returns tier-grouped recipe recommendations.
    
    Flow:
    1. Load user inventory, history, and flavor profile
    2. Execute tier classification query (Tiers 1-4)
    3. Score each recipe with RelevanceScore
    4. Optionally run Tier 5 semantic search
    5. Return grouped, scored, sorted results
    """
    return await engine.generate(
        user_id=user_id,
        max_per_tier=max_per_tier,
        include_tier5=include_tier5
    )
```

---

*← [Section 1: Schema](./TDD_01_DATA_SCHEMA.md) | [Section 3: UI Architecture →](./TDD_03_UI_ARCHITECTURE.md)*
