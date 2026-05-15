"""
Plately — AI Response Cache
==============================
In-memory TTL cache for AI responses.
Eliminates duplicate API calls for identical queries.

Features:
  - LRU eviction when cache exceeds max_size
  - Configurable TTL per cache entry
  - Cache key includes prompt + model + locale for uniqueness
  - Thread-safe via simple dict operations (GIL-protected)

Typical savings:
  - Substitute queries: same ingredient asked by multiple users → cached
  - Cooking tips: same step text → cached
  - Recipe translations: same recipe × same language → cached
"""

import hashlib
import time
import logging
from typing import Optional, Any, Dict
from collections import OrderedDict

logger = logging.getLogger("plately.ai_cache")


class AIResponseCache:
    """In-memory LRU cache with TTL for AI responses."""

    def __init__(self, max_size: int = 500, default_ttl: int = 3600):
        """
        Args:
            max_size: Maximum number of cached entries before LRU eviction.
            default_ttl: Default time-to-live in seconds (1 hour).
        """
        self._cache: OrderedDict[str, Dict[str, Any]] = OrderedDict()
        self._max_size = max_size
        self._default_ttl = default_ttl
        self._hits = 0
        self._misses = 0

    @staticmethod
    def _make_key(*parts: str) -> str:
        """Create a deterministic cache key from variable parts."""
        combined = "|".join(str(p).strip().lower() for p in parts if p)
        return hashlib.sha256(combined.encode()).hexdigest()[:16]

    def get(self, *key_parts: str) -> Optional[Any]:
        """Retrieve a cached value if it exists and hasn't expired."""
        key = self._make_key(*key_parts)
        entry = self._cache.get(key)

        if entry is None:
            self._misses += 1
            return None

        # Check expiration
        if time.time() > entry["expires_at"]:
            del self._cache[key]
            self._misses += 1
            return None

        # Move to end (most recently used)
        self._cache.move_to_end(key)
        self._hits += 1
        return entry["value"]

    def put(self, value: Any, *key_parts: str, ttl: Optional[int] = None) -> None:
        """Store a value in the cache with the given key parts."""
        key = self._make_key(*key_parts)
        ttl = ttl or self._default_ttl

        # Evict oldest if at capacity
        while len(self._cache) >= self._max_size:
            evicted_key, _ = self._cache.popitem(last=False)
            logger.debug(f"[Cache] Evicted LRU entry: {evicted_key}")

        self._cache[key] = {
            "value": value,
            "expires_at": time.time() + ttl,
            "created_at": time.time(),
        }

    def invalidate(self, *key_parts: str) -> bool:
        """Remove a specific entry. Returns True if it existed."""
        key = self._make_key(*key_parts)
        if key in self._cache:
            del self._cache[key]
            return True
        return False

    def clear(self) -> None:
        """Clear all cached entries."""
        self._cache.clear()
        self._hits = 0
        self._misses = 0

    @property
    def stats(self) -> Dict[str, Any]:
        """Return cache performance statistics."""
        total = self._hits + self._misses
        return {
            "size": len(self._cache),
            "max_size": self._max_size,
            "hits": self._hits,
            "misses": self._misses,
            "hit_rate": f"{(self._hits / total * 100):.1f}%" if total > 0 else "0%",
        }


# ── Singleton Instance ─────────────────────────────────────────

_cache_instance: Optional[AIResponseCache] = None

def get_ai_cache() -> AIResponseCache:
    """Get the global AI response cache singleton."""
    global _cache_instance
    if _cache_instance is None:
        _cache_instance = AIResponseCache(max_size=500, default_ttl=3600)
    return _cache_instance
