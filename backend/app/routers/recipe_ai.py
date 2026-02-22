"""
I-Fridge — AI Recipe Assistant Router
=======================================
Uses local LLM (gemma3:1b via Ollama) for recipe generation,
ingredient substitution, and cooking tips.
"""

import json
import logging
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List, Optional

from app.services.ollama_service import get_ollama_service

logger = logging.getLogger("ifridge.recipe_ai")

router = APIRouter()


# ── Request Models ───────────────────────────────────────────────

class GenerateRecipeRequest(BaseModel):
    ingredients: List[str]
    cuisine: Optional[str] = None
    max_time_minutes: Optional[int] = None
    difficulty: Optional[int] = None  # 1-3
    servings: Optional[int] = 2

class SubstituteRequest(BaseModel):
    ingredient: str
    recipe_context: Optional[str] = None

class CookingTipRequest(BaseModel):
    step_text: str
    question: Optional[str] = None


# ── Endpoints ────────────────────────────────────────────────────

@router.post("/api/v1/ai/generate-recipe")
async def generate_recipe(req: GenerateRecipeRequest):
    """
    Generate a recipe from available ingredients using the local LLM.
    """
    ollama = get_ollama_service()
    if not await ollama.is_available():
        raise HTTPException(status_code=503, detail="AI service unavailable. Start Ollama.")

    constraints = []
    if req.cuisine:
        constraints.append(f"Cuisine: {req.cuisine}")
    if req.max_time_minutes:
        constraints.append(f"Max time: {req.max_time_minutes} minutes")
    if req.difficulty:
        diff_map = {1: "Easy", 2: "Medium", 3: "Hard"}
        constraints.append(f"Difficulty: {diff_map.get(req.difficulty, 'Easy')}")

    constraint_text = "\n".join(constraints) if constraints else "No constraints"

    prompt = f"""Create a recipe using these ingredients: {', '.join(req.ingredients)}.
Servings: {req.servings or 2}
{constraint_text}

Return JSON only:
{{"title": "Recipe Name", "description": "Short description", "prep_time_minutes": 10, "cook_time_minutes": 20, "servings": 2, "difficulty": 1, "cuisine": "...", "ingredients": [{{"name": "...", "quantity": 1, "unit": "pcs"}}], "steps": [{{"step": 1, "text": "...", "time_seconds": 60}}]}}"""

    system = "You are a professional chef. Create practical, delicious recipes. Return only valid JSON."

    result = await ollama.generate_text_json(prompt, system_prompt=system)

    if "error" in result:
        return {
            "status": "partial",
            "message": "AI returned non-JSON. Raw response included.",
            "data": result,
        }

    return {
        "status": "success",
        "source": "ollama-local",
        "data": result,
    }


@router.post("/api/v1/ai/substitute")
async def suggest_substitute(req: SubstituteRequest):
    """
    Suggest substitutes for a missing ingredient.
    """
    ollama = get_ollama_service()
    if not await ollama.is_available():
        raise HTTPException(status_code=503, detail="AI service unavailable. Start Ollama.")

    context = f" Recipe context: {req.recipe_context}" if req.recipe_context else ""

    prompt = f"""I'm missing "{req.ingredient}" for cooking.{context}

Suggest 3 substitutes. Return JSON only:
{{"ingredient": "{req.ingredient}", "substitutes": [{{"name": "...", "ratio": "1:1", "notes": "..."}}]}}"""

    system = "You are a cooking expert. Suggest practical ingredient substitutes. Return only valid JSON."

    result = await ollama.generate_text_json(prompt, system_prompt=system)

    return {
        "status": "success" if "error" not in result else "partial",
        "source": "ollama-local",
        "data": result,
    }


@router.post("/api/v1/ai/cooking-tip")
async def get_cooking_tip(req: CookingTipRequest):
    """
    Get a cooking tip or answer a question about a recipe step.
    """
    ollama = get_ollama_service()
    if not await ollama.is_available():
        raise HTTPException(status_code=503, detail="AI service unavailable. Start Ollama.")

    question = req.question or "Give me a helpful tip for this step."

    prompt = f"""Recipe step: "{req.step_text}"
Question: {question}

Give a brief, practical cooking tip (2-3 sentences max)."""

    system = "You are a friendly cooking assistant. Give brief, practical tips."

    response = await ollama.generate_text(prompt, system_prompt=system, max_tokens=300)

    return {
        "status": "success",
        "source": "ollama-local",
        "data": {"tip": response.strip()},
    }
