from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routers import ocr_parser, barcode_lookup, vision_detect, recipe_ai, embeddings
from app.services.ollama_service import get_ollama_service
import uvicorn

# Initialize FastAPI App
app = FastAPI(
    title="I-Fridge AI Backend",
    description="Vision and Intelligence layer for the I-Fridge consumer app. Local Ollama AI + vector search.",
    version="3.1.0"
)

# Allow CORS for Flutter Frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register Routers
app.include_router(ocr_parser.router)
app.include_router(barcode_lookup.router)
app.include_router(vision_detect.router)
app.include_router(recipe_ai.router)
app.include_router(embeddings.router)

@app.get("/")
async def root():
    return {"message": "I-Fridge Intelligence API v3.0 is running"}

@app.get("/api/v1/ai/status")
async def ai_status():
    """Health check for the local AI pipeline."""
    ollama = get_ollama_service()
    available = await ollama.is_available()
    models = await ollama.list_models() if available else []
    return {
        "ollama_running": available,
        "models_loaded": models,
        "gpu": "GTX 1650 Ti (4GB VRAM)",
        "recommended": {
            "vision": "moondream",
            "text": "gemma3:1b",
            "embedding": "nomic-embed-text",
        }
    }

if __name__ == "__main__":
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)
