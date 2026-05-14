"""
Plately — Cloud AI Fallback Service
=======================================
Automatic fallback chain: Ollama (local) → OpenAI/Gemini (cloud) → mock.

Usage:
  Set API keys in .env:
    OPENAI_API_KEY=sk-...
    GEMINI_API_KEY=AIza...

  The service auto-detects which provider is available
  and routes requests through the fallback chain.
"""

import httpx
import json
import logging
from typing import Optional, Dict, List, Any

from app.core.config import get_settings

logger = logging.getLogger("plately.cloud_ai")


class CloudAIService:
    """Fallback AI service using OpenAI or Google Gemini."""

    def __init__(self):
        settings = get_settings()
        self.openai_key: Optional[str] = getattr(settings, 'OPENAI_API_KEY', None)
        self.gemini_key: Optional[str] = getattr(settings, 'GEMINI_API_KEY', None)
        self._client = httpx.AsyncClient(timeout=60.0)

    @property
    def provider(self) -> Optional[str]:
        """Which cloud provider is configured."""
        if self.openai_key:
            return "openai"
        if self.gemini_key:
            return "gemini"
        return None

    @property
    def is_configured(self) -> bool:
        return self.provider is not None

    # ── OpenAI ───────────────────────────────────────────────────

    async def _openai_generate(
        self, prompt: str, system_prompt: Optional[str] = None,
        temperature: float = 0.7, max_tokens: int = 1024,
        format: Optional[str] = None, image_bytes: Optional[bytes] = None, mime_type: str = "image/jpeg",
    ) -> str:
        messages = []
        if system_prompt:
            messages.append({"role": "system", "content": system_prompt})
            
        if image_bytes:
            import base64
            b64 = base64.b64encode(image_bytes).decode('utf-8')
            messages.append({
                "role": "user",
                "content": [
                    {"type": "text", "text": prompt},
                    {"type": "image_url", "image_url": {"url": f"data:{mime_type};base64,{b64}"}}
                ]
            })
        else:
            messages.append({"role": "user", "content": prompt})

        payload = {
            "model": "gpt-4o-mini",
            "messages": messages,
            "temperature": temperature,
            "max_tokens": max_tokens,
        }
        if format == "json":
            payload["response_format"] = {"type": "json_object"}

        resp = await self._client.post(
            "https://api.openai.com/v1/chat/completions",
            headers={
                "Authorization": f"Bearer {self.openai_key}",
                "Content-Type": "application/json",
            },
            json=payload,
        )
        resp.raise_for_status()
        data = resp.json()
        return data["choices"][0]["message"]["content"]

    # ── Gemini ───────────────────────────────────────────────────

    async def _gemini_generate(
        self, prompt: str, system_prompt: Optional[str] = None,
        temperature: float = 0.7, max_tokens: int = 1024,
        format: Optional[str] = None, image_bytes: Optional[bytes] = None, mime_type: str = "image/jpeg",
        model: str = "gemini-2.5-flash",
    ) -> str:
        full_prompt = f"{system_prompt}\n\n{prompt}" if system_prompt else prompt
        
        parts = []
        parts.append({"text": full_prompt})
        if image_bytes:
            import base64
            b64 = base64.b64encode(image_bytes).decode('utf-8')
            parts.append({"inlineData": {"mimeType": mime_type, "data": b64}})

        gen_config = {
            "temperature": temperature,
            "maxOutputTokens": max_tokens,
        }
        if format == "json":
            gen_config["responseMimeType"] = "application/json"

        import asyncio
        max_retries = 3
        for attempt in range(max_retries):
            resp = await self._client.post(
                f"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent?key={self.gemini_key}",
                json={
                    "contents": [{"parts": parts}],
                    "generationConfig": gen_config,
                },
            )
            if resp.status_code == 429 and attempt < max_retries - 1:
                wait = (attempt + 1) * 5
                logger.warning(f"[CloudAI] Gemini rate-limited, retrying in {wait}s (attempt {attempt+1}/{max_retries})")
                await asyncio.sleep(wait)
                continue
            resp.raise_for_status()
            data = resp.json()
            return data["candidates"][0]["content"]["parts"][0]["text"]

    # ── Public API ───────────────────────────────────────────────

    async def generate_text(
        self, prompt: str, system_prompt: Optional[str] = None,
        temperature: float = 0.7, max_tokens: int = 1024,
        format: Optional[str] = None, image_bytes: Optional[bytes] = None, mime_type: str = "image/jpeg",
        model: Optional[str] = None,
    ) -> str:
        """Generate text using the configured cloud provider."""
        if self.openai_key:
            # If OpenAI is used, we stick to gpt-4o-mini for now unless overridden
            logger.info("[CloudAI] Using OpenAI gpt-4o-mini")
            return await self._openai_generate(prompt, system_prompt, temperature, max_tokens, format, image_bytes, mime_type)
        elif self.gemini_key:
            gemini_model = model or "gemini-2.5-flash"
            logger.info(f"[CloudAI] Using Gemini model: {gemini_model}")
            return await self._gemini_generate(
                prompt, system_prompt, temperature, max_tokens, 
                format, image_bytes, mime_type, model=gemini_model
            )
        else:
            raise RuntimeError("No cloud AI provider configured. Set OPENAI_API_KEY or GEMINI_API_KEY in .env")

    async def close(self):
        await self._client.aclose()


# ── Module-level singleton ───────────────────────────────────────
_cloud_instance: Optional[CloudAIService] = None

def get_cloud_ai_service() -> CloudAIService:
    global _cloud_instance
    if _cloud_instance is None:
        _cloud_instance = CloudAIService()
    return _cloud_instance
