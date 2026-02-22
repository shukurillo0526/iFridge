"""
I-Fridge — Scoring Service
============================
Computes the composite Relevance Score for each recipe.

Formula:
  RelevanceScore = (w1 × ExpiryUrgency) + (w2 × FlavorAffinity) + (w3 × FamiliarityBoost)

Weights are configurable via environment variables (see config.py).
"""

import numpy as np
from datetime import date
from app.core.config import get_settings

# Flavor axes — shared vocabulary between recipes and user profiles.
FLAVOR_AXES = ["sweet", "salty", "sour", "bitter", "umami", "spicy"]


def compute_expiry_urgency(
    recipe_ingredient_ids: list[str],
    user_inventory: dict[str, date],  # {ingredient_id: computed_expiry}
    horizon_days: int = 7,
) -> float:
    """
    How urgently the recipe's ingredients need to be used.

    Items expiring today → 1.0 urgency.
    Items expiring in `horizon_days`+ → 0.0 urgency.
    Returns average urgency across matched ingredients.
    """
    today = date.today()
    urgencies: list[float] = []

    for ing_id in recipe_ingredient_ids:
        expiry = user_inventory.get(ing_id)
        if expiry is None:
            continue  # missing ingredient — skip

        days_left = (expiry - today).days
        # Normalize: 0 days left → urgency 1.0, horizon+ days → 0.0
        normalized = max(0.0, 1.0 - (days_left / horizon_days))
        urgencies.append(normalized)

    return float(np.mean(urgencies)) if urgencies else 0.0


def compute_flavor_affinity(
    recipe_vectors: dict[str, float],  # {"sweet": 0.3, "umami": 0.9, ...}
    user_profile: dict[str, float],    # {"sweet": 0.5, "umami": 0.7, ...}
) -> float:
    """
    Cosine similarity between the recipe's flavor profile
    and the user's learned taste preferences.

    Returns a value between 0.0 (orthogonal) and 1.0 (identical).
    """
    r_vec = np.array([recipe_vectors.get(axis, 0.5) for axis in FLAVOR_AXES])
    u_vec = np.array([user_profile.get(axis, 0.5) for axis in FLAVOR_AXES])

    dot = np.dot(r_vec, u_vec)
    norm = np.linalg.norm(r_vec) * np.linalg.norm(u_vec)

    return float(dot / norm) if norm > 0 else 0.5


def compute_relevance_score(
    expiry_urgency: float,
    flavor_affinity: float,
    is_comfort: bool,
) -> float:
    """
    Compute the final weighted relevance score.

    - Expiry urgency (w1=0.45): Prioritize waste reduction.
    - Flavor affinity (w2=0.35): Personalize to user taste.
    - Familiarity (w3=0.20): Slight boost for comfort food.
    """
    settings = get_settings()

    familiarity = 1.0 if is_comfort else 0.2

    score = (
        settings.WEIGHT_EXPIRY * expiry_urgency
        + settings.WEIGHT_FLAVOR * flavor_affinity
        + settings.WEIGHT_FAMILIAR * familiarity
    )
    return round(min(1.0, max(0.0, score)), 3)
