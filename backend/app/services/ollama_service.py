"""
I-Fridge — Local AI Service Layer (Ollama)
==========================================
Manages all interactions with the local Ollama server.
Supports vision (moondream/qwen3), text generation (qwen3:8b),
and embeddings (nomic-embed-text).

Architecture:
  - 4GB VRAM budget (GTX 1650 Ti)
  - Only ONE large model loaded at a time
  - Embeddings model runs on CPU (~270MB) alongside GPU models
  - Automatic fallback to cloud Gemini if Ollama is unavailable
"""

import httpx
import base64
import json
import logging
from typing import Optional, Dict, List, Any

logger = logging.getLogger("ifridge.ollama")

OLLAMA_BASE_URL = "http://localhost:11434"

# Model registry — maps task types to preferred models
# Dynamically resolved at runtime based on what's available
MODEL_REGISTRY = {
    "vision": ["moondream", "qwen2.5:3b", "qwen3:8b"],
    "text": ["qwen2.5:3b", "qwen3:8b", "gemma3:1b"],
    "embedding": ["nomic-embed-text"],           # embedding models (CPU-safe)
}


class OllamaService:
    """Unified interface to the local Ollama server."""

    def __init__(self, base_url: str = OLLAMA_BASE_URL, timeout: float = 120.0):
        self.base_url = base_url
        self.timeout = timeout
        self._client = httpx.AsyncClient(timeout=timeout)
        self._available_models: Optional[List[str]] = None

    async def is_available(self) -> bool:
        """Check if the Ollama server is running."""
        try:
            resp = await self._client.get(f"{self.base_url}/api/tags")
            return resp.status_code == 200
        except (httpx.ConnectError, httpx.TimeoutException):
            return False

    async def list_models(self) -> List[str]:
        """Return names of locally available models."""
        try:
            resp = await self._client.get(f"{self.base_url}/api/tags")
            data = resp.json()
            self._available_models = [m["name"] for m in data.get("models", [])]
            return self._available_models
        except Exception:
            return []

    async def _resolve_model(self, task: str) -> Optional[str]:
        """Find the best available model for a given task."""
        if self._available_models is None:
            await self.list_models()
        candidates = MODEL_REGISTRY.get(task, [])
        for model in candidates:
            if self._available_models and any(
                m == model or m.startswith(model.split(":")[0])
                for m in self._available_models
            ):
                return model
        # Return first candidate and let Ollama handle the error
        return candidates[0] if candidates else None

    # ── Vision ───────────────────────────────────────────────────

    async def analyze_image(
        self,
        image_bytes: bytes,
        prompt: str,
        model: Optional[str] = None,
        temperature: float = 0.2,
        max_tokens: int = 2048,
    ) -> str:
        """
        Send an image + prompt to a vision model via /api/chat.
        Returns the raw text response.
        """
        model = model or await self._resolve_model("vision")
        b64_image = base64.b64encode(image_bytes).decode("utf-8")

        messages = []
        # For qwen3 models, append /no_think to skip extended reasoning
        if model and "qwen3" in model:
            messages.append({"role": "system", "content": "/no_think"})
        messages.append({
            "role": "user",
            "content": prompt,
            "images": [b64_image],
        })

        payload = {
            "model": model,
            "messages": messages,
            "stream": False,
            "options": {
                "temperature": temperature,
                "num_predict": max_tokens,
            },
        }

        logger.info(f"[Ollama] Vision request → {model} (temp={temperature}, max_tok={max_tokens})")
        resp = await self._client.post(
            f"{self.base_url}/api/chat",
            json=payload,
        )
        resp.raise_for_status()
        result = resp.json()
        msg = result.get("message", {})
        return self._strip_thinking_tags(msg.get("content", ""))

    async def analyze_image_json(
        self,
        image_bytes: bytes,
        prompt: str,
        model: Optional[str] = None,
    ) -> Dict[str, Any]:
        """Send an image + prompt, parse the response as JSON."""
        raw = await self.analyze_image(image_bytes, prompt, model)
        return self._parse_json_response(raw)

    # ── Text Generation ──────────────────────────────────────────

    async def generate_text(
        self,
        prompt: str,
        model: Optional[str] = None,
        system_prompt: Optional[str] = None,
        temperature: float = 0.7,
        max_tokens: int = 1024,
    ) -> str:
        """
        Generate text from a prompt using a local LLM via /api/chat.
        Returns the raw text response.
        """
        model = model or await self._resolve_model("text")

        messages = []
        if system_prompt:
            # For qwen3 models, append /no_think to skip extended reasoning
            sys_content = system_prompt
            if model and "qwen3" in model:
                sys_content += "\n/no_think"
            messages.append({"role": "system", "content": sys_content})
        elif model and "qwen3" in model:
            messages.append({"role": "system", "content": "/no_think"})
        messages.append({"role": "user", "content": prompt})

        payload = {
            "model": model,
            "messages": messages,
            "stream": False,
            "options": {
                "temperature": temperature,
                "num_predict": max_tokens,
            },
        }

        logger.info(f"[Ollama] Text generation → {model}")
        resp = await self._client.post(
            f"{self.base_url}/api/chat",
            json=payload,
        )
        resp.raise_for_status()
        result = resp.json()
        msg = result.get("message", {})
        return self._strip_thinking_tags(msg.get("content", ""))

    async def generate_text_json(
        self,
        prompt: str,
        model: Optional[str] = None,
        system_prompt: Optional[str] = None,
    ) -> Dict[str, Any]:
        """Generate text and parse as JSON."""
        raw = await self.generate_text(
            prompt, model, system_prompt, temperature=0.1
        )
        return self._parse_json_response(raw)

    # ── Embeddings ───────────────────────────────────────────────

    async def get_embedding(
        self,
        text: str,
        model: Optional[str] = None,
    ) -> List[float]:
        """Generate an embedding vector for the given text."""
        model = model or (await self._resolve_model("embedding")) or "nomic-embed-text"

        payload = {"model": model, "input": text}
        resp = await self._client.post(
            f"{self.base_url}/api/embed", json=payload
        )
        resp.raise_for_status()
        data = resp.json()
        embeddings = data.get("embeddings", [[]])
        return embeddings[0] if embeddings else []

    async def get_embeddings_batch(
        self,
        texts: List[str],
        model: Optional[str] = None,
    ) -> List[List[float]]:
        """Generate embeddings for multiple texts."""
        model = model or (await self._resolve_model("embedding")) or "nomic-embed-text"

        payload = {"model": model, "input": texts}
        resp = await self._client.post(
            f"{self.base_url}/api/embed", json=payload
        )
        resp.raise_for_status()
        data = resp.json()
        return data.get("embeddings", [])

    # ── Response Processing Helpers ────────────────────────────────

    @staticmethod
    def _strip_thinking_tags(text: str) -> str:
        """Strip <think>...</think> reasoning blocks from models like qwen3."""
        import re
        # Remove <think>...</think> blocks (possibly multiline)
        cleaned = re.sub(r'<think>.*?</think>', '', text, flags=re.DOTALL)
        return cleaned.strip()

    def _parse_json_response(self, raw: str) -> Dict[str, Any]:
        """Parse a raw LLM response into JSON, handling code fences and edge cases."""
        text = raw.strip()

        # Strip markdown code fences (```json ... ``` or ``` ... ```)
        if text.startswith("```"):
            lines = text.split("\n")
            text = "\n".join(lines[1:])
            if text.rstrip().endswith("```"):
                text = text.rstrip()[:-3]
            text = text.strip()

        # Try direct parse
        try:
            result = json.loads(text)
            if isinstance(result, list):
                return {"items": result}
            return result
        except json.JSONDecodeError:
            pass

        # Try to find JSON object within text (handles preamble/postamble text)
        start = text.find("{")
        end = text.rfind("}") + 1
        if start >= 0 and end > start:
            candidate = text[start:end]
            try:
                result = json.loads(candidate)
                return result
            except json.JSONDecodeError:
                pass

        # Try to find JSON array within text
        start = text.find("[")
        end = text.rfind("]") + 1
        if start >= 0 and end > start:
            candidate = text[start:end]
            try:
                result = json.loads(candidate)
                if isinstance(result, list):
                    return {"items": result}
            except json.JSONDecodeError:
                pass

        logger.warning(f"[Ollama] Failed to parse JSON from response ({len(text)} chars): {text[:300]}")
        return {"error": "Failed to parse JSON", "raw_response": text[:500]}

    # ── Cleanup ──────────────────────────────────────────────────

    async def close(self):
        """Close the HTTP client."""
        await self._client.aclose()


# ── Module-level singleton ───────────────────────────────────────
_instance: Optional[OllamaService] = None

def get_ollama_service() -> OllamaService:
    """Get or create the singleton OllamaService instance."""
    global _instance
    if _instance is None:
        _instance = OllamaService()
    return _instance
