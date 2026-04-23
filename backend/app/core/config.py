"""
I-Fridge Backend — Application Configuration
=============================================
All settings are loaded from environment variables via pydantic-settings.
Create a `.env` file in the backend root with these keys.
"""

from pydantic_settings import BaseSettings
from functools import lru_cache


class Settings(BaseSettings):
    """Application settings loaded from environment / .env file."""

    # --- App ---
    APP_NAME: str = "I-Fridge API"
    APP_VERSION: str = "3.4.0"
    DEBUG: bool = False
    LOG_LEVEL: str = "INFO"
    STRUCTURED_LOGS: bool = False  # True for production JSON logs

    # --- Supabase ---
    SUPABASE_URL: str = ""
    SUPABASE_ANON_KEY: str = ""
    SUPABASE_SERVICE_ROLE_KEY: str = ""

    # --- Clarifai ---
    CLARIFAI_API_KEY: str = ""
    CLARIFAI_FOOD_MODEL_ID: str = "food-item-recognition"

    # --- Vision thresholds ---
    VISION_THRESHOLD_AUTO: float = 0.90
    VISION_THRESHOLD_CONFIRM: float = 0.70

    # --- Recommendation engine weights (must sum to ~1.0) ---
    WEIGHT_EXPIRY: float = 0.25      # Waste reduction urgency
    WEIGHT_FLAVOR: float = 0.20      # Flavor affinity (cosine)
    WEIGHT_FAMILIAR: float = 0.10    # Comfort food boost
    WEIGHT_DIFFICULTY: float = 0.10  # Skill-level match
    WEIGHT_RECENCY: float = 0.10     # Variety (penalize recent)
    WEIGHT_COVERAGE: float = 0.25    # Ingredient match %

    # --- Server ---
    HOST: str = "0.0.0.0"
    PORT: int = 8000

    model_config = {"env_file": ".env", "env_file_encoding": "utf-8"}


@lru_cache()
def get_settings() -> Settings:
    """Cached settings singleton."""
    return Settings()
