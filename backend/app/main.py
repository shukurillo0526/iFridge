"""
I-Fridge — Application Entry Point
====================================
FastAPI application with full production middleware stack:
- Request ID tracing (X-Request-ID)
- Structured JSON logging
- Input validation (body size, UUID format)
- Global error handling with standardized envelopes
- Rate limiting on AI-heavy endpoints
- CORS for Flutter frontend
- Comprehensive health checks
"""

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from app.routers import (
    ocr_parser, barcode_lookup, vision_detect, recipe_ai,
    embeddings, inventory, user_data, calorie_analysis,
    recommendations, health,
)
from app.services.ollama_service import get_ollama_service
from app.middleware.request_middleware import RequestIdMiddleware, InputValidationMiddleware
from app.middleware.error_handlers import register_error_handlers
from app.core.logging_config import setup_logging
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded
import uvicorn

# ── Logging ──────────────────────────────────────────────────────
# Use structured=False for local development (readable logs)
# Use structured=True for production (JSON logs)
setup_logging(level="INFO", structured=False)

# ── Rate Limiter ─────────────────────────────────────────────────
limiter = Limiter(key_func=get_remote_address)

# ── FastAPI App ──────────────────────────────────────────────────
app = FastAPI(
    title="I-Fridge AI Backend",
    description=(
        "Vision and Intelligence layer for the I-Fridge consumer app. "
        "Local Ollama AI + Supabase DB + vector search.\n\n"
        "## Features\n"
        "- 🔍 **Vision**: OCR receipt scanning, barcode lookup, food image recognition\n"
        "- 🤖 **AI**: Recipe generation, ingredient substitution, cooking tips\n"
        "- 📊 **Recommendations**: 6-signal composite scoring engine\n"
        "- 🎥 **YouTube Intelligence**: Auto-extract recipes from video metadata\n"
        "- 🛒 **Shopping**: Smart shopping list generation\n"
        "- 📈 **Nutrition**: Calorie analysis and daily tracking\n"
        "- 👤 **User**: Flavor profile auto-learning, engagement tracking\n"
    ),
    version="3.4.0",
    docs_url="/docs",
    redoc_url="/redoc",
    openapi_tags=[
        {"name": "Health", "description": "System health checks and status"},
        {"name": "Vision", "description": "OCR, barcode, and food image recognition"},
        {"name": "AI", "description": "Recipe generation, substitution, and cooking tips"},
        {"name": "Recipes", "description": "Recipe recommendations and scoring"},
        {"name": "Inventory", "description": "Ingredient and inventory management"},
        {"name": "User Data", "description": "User profiles, shopping lists, meal plans"},
        {"name": "Nutrition", "description": "Calorie analysis and tracking"},
        {"name": "Embeddings", "description": "Vector search and similarity"},
    ],
)

# ── Rate Limiter Setup ───────────────────────────────────────────
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# ── Middleware Stack (order matters — last added runs first) ─────
# 1. CORS (outermost)
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:8080",
        "http://localhost:3000",
        "http://127.0.0.1:8080",
        "https://shukurillo0526.github.io",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
    expose_headers=["X-Request-ID", "X-Response-Time"],
)

# 2. Request ID + timing (runs after CORS, adds tracing headers)
app.add_middleware(RequestIdMiddleware)

# 3. Input validation (runs last, innermost)
app.add_middleware(InputValidationMiddleware)

# ── Global Error Handlers ────────────────────────────────────────
register_error_handlers(app)

# ── Routers ──────────────────────────────────────────────────────
app.include_router(health.router)
app.include_router(ocr_parser.router)
app.include_router(barcode_lookup.router)
app.include_router(vision_detect.router)
app.include_router(recipe_ai.router)
app.include_router(embeddings.router)
app.include_router(inventory.router)
app.include_router(user_data.router)
app.include_router(calorie_analysis.router)
app.include_router(recommendations.router)


# ── Root ─────────────────────────────────────────────────────────
@app.get("/", tags=["Health"])
async def root():
    return {
        "name": "I-Fridge Intelligence API",
        "version": "3.4.0",
        "docs": "/docs",
        "health": "/api/v1/health",
    }


@app.get("/api/v1/ai/status", tags=["AI"])
async def ai_status():
    """Health check for the local AI pipeline."""
    ollama = get_ollama_service()
    available = await ollama.is_available()
    models = await ollama.list_models() if available else []
    return {
        "ollama_running": available,
        "models_loaded": models,
        "gpu": "RTX 5070 Ti (16GB VRAM)",
        "recommended": {
            "vision": "qwen2.5vl:7b",
            "text": "qwen3:8b",
            "embedding": "nomic-embed-text",
        }
    }


if __name__ == "__main__":
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)
