"""
I-Fridge — Embedding & Vector Search Router
=============================================
Uses local nomic-embed-text via Ollama to generate embeddings
for recipes and user preferences, enabling semantic similarity search.
"""

import json
import logging
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List, Optional

from app.services.ollama_service import get_ollama_service

logger = logging.getLogger("ifridge.embeddings")

router = APIRouter()


class EmbedTextRequest(BaseModel):
    text: str

class EmbedBatchRequest(BaseModel):
    texts: List[str]

class SemanticSearchRequest(BaseModel):
    query: str
    candidates: List[dict]  # Each dict has 'id', 'title', 'description'
    top_k: int = 5


def _cosine_similarity(a: List[float], b: List[float]) -> float:
    """Compute cosine similarity between two vectors."""
    if not a or not b or len(a) != len(b):
        return 0.0
    dot = sum(x * y for x, y in zip(a, b))
    norm_a = sum(x * x for x in a) ** 0.5
    norm_b = sum(x * x for x in b) ** 0.5
    if norm_a == 0 or norm_b == 0:
        return 0.0
    return dot / (norm_a * norm_b)


@router.post("/api/v1/ai/embed")
async def embed_text(req: EmbedTextRequest):
    """Generate an embedding vector for a single text."""
    ollama = get_ollama_service()
    if not await ollama.is_available():
        raise HTTPException(status_code=503, detail="Ollama unavailable")

    try:
        vector = await ollama.get_embedding(req.text)
        return {
            "status": "success",
            "dimensions": len(vector),
            "embedding": vector,
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/api/v1/ai/embed-batch")
async def embed_batch(req: EmbedBatchRequest):
    """Generate embeddings for multiple texts at once."""
    ollama = get_ollama_service()
    if not await ollama.is_available():
        raise HTTPException(status_code=503, detail="Ollama unavailable")

    try:
        vectors = await ollama.get_embeddings_batch(req.texts)
        return {
            "status": "success",
            "count": len(vectors),
            "dimensions": len(vectors[0]) if vectors else 0,
            "embeddings": vectors,
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/api/v1/ai/semantic-search")
async def semantic_search(req: SemanticSearchRequest):
    """
    Perform semantic search: embed the query, compute similarity
    against pre-computed candidate embeddings, return top-K results.

    Each candidate dict should have: id, title, description.
    The title + description are embedded and compared against the query.
    """
    ollama = get_ollama_service()
    if not await ollama.is_available():
        raise HTTPException(status_code=503, detail="Ollama unavailable")

    try:
        # Embed the search query
        query_vec = await ollama.get_embedding(req.query)

        # Embed all candidate descriptions and compute similarity
        candidate_texts = [
            f"{c.get('title', '')}. {c.get('description', '')}"
            for c in req.candidates
        ]
        candidate_vecs = await ollama.get_embeddings_batch(candidate_texts)

        # Score and rank
        scored = []
        for i, candidate in enumerate(req.candidates):
            if i < len(candidate_vecs):
                sim = _cosine_similarity(query_vec, candidate_vecs[i])
                scored.append({
                    "id": candidate.get("id"),
                    "title": candidate.get("title"),
                    "score": round(sim, 4),
                })

        # Sort by similarity score descending
        scored.sort(key=lambda x: x["score"], reverse=True)

        return {
            "status": "success",
            "query": req.query,
            "results": scored[:req.top_k],
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/api/v1/ai/personalize")
async def personalize_recipes(
    user_history: List[str],
    candidate_titles: List[str],
    top_k: int = 10
):
    """
    Personalize recipe recommendations based on user cooking history.

    Workflow:
    1. Embed the user's cooking history as a single preference vector
    2. Embed all candidate recipe titles
    3. Rank by cosine similarity to the user's preference
    """
    ollama = get_ollama_service()
    if not await ollama.is_available():
        raise HTTPException(status_code=503, detail="Ollama unavailable")

    try:
        # Create a user preference summary
        history_text = f"I enjoy cooking: {', '.join(user_history)}. Recommend similar recipes."
        user_vec = await ollama.get_embedding(history_text)

        # Embed candidates
        candidate_vecs = await ollama.get_embeddings_batch(candidate_titles)

        # Score and rank
        scored = []
        for i, title in enumerate(candidate_titles):
            if i < len(candidate_vecs):
                sim = _cosine_similarity(user_vec, candidate_vecs[i])
                scored.append({"title": title, "score": round(sim, 4)})

        scored.sort(key=lambda x: x["score"], reverse=True)

        return {
            "status": "success",
            "user_profile_summary": history_text,
            "results": scored[:top_k],
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
