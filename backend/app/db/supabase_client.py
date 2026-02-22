"""
I-Fridge Backend — Supabase Client
===================================
Provides an async-compatible Supabase client singleton.
"""

from supabase import create_client, Client
from app.core.config import get_settings

_client: Client | None = None


def get_supabase() -> Client:
    """Returns the Supabase client singleton (lazy initialized)."""
    global _client
    if _client is None:
        settings = get_settings()
        _client = create_client(
            settings.SUPABASE_URL,
            settings.SUPABASE_SERVICE_ROLE_KEY,
        )
    return _client
