"""
I-Fridge — AI Recipe Assistant Router
=======================================
Uses local LLM (qwen3:8b via Ollama) for recipe generation,
ingredient substitution, and cooking tips.
"""

import json
import logging
import httpx
import os
from fastapi import APIRouter, HTTPException, Request
from pydantic import BaseModel
from typing import List, Optional

from app.services.ollama_service import get_ollama_service
from app.services.youtube_intelligence import extract_recipe_from_youtube
from app.db.supabase_client import get_supabase
from slowapi import Limiter
from slowapi.util import get_remote_address

limiter = Limiter(key_func=get_remote_address)

logger = logging.getLogger("ifridge.recipe_ai")

router = APIRouter()


# ── Request Models ───────────────────────────────────────────────

class GenerateRecipeRequest(BaseModel):
    ingredients: List[str]
    cuisine: Optional[str] = None
    max_time_minutes: Optional[int] = None
    difficulty: Optional[int] = None  # 1-3
    servings: Optional[int] = 2
    shelf_only: Optional[bool] = False

class SubstituteRequest(BaseModel):
    ingredient: str
    recipe_context: Optional[str] = None

class CookingTipRequest(BaseModel):
    step_text: str
    question: Optional[str] = None

class YouTubeRecipeRequest(BaseModel):
    video_title: str
    video_description: str = ""
    channel_name: str = ""
    youtube_id: Optional[str] = None

class ShoppingListRequest(BaseModel):
    user_id: str
    recipe_ids: List[str]  # recipes the user wants to cook

class TranslateRecipeRequest(BaseModel):
    recipe_id: str
    title: str
    ingredients: str
    steps: str
    target_language: str


# ── Endpoints ────────────────────────────────────────────────────

@router.post("/api/v1/ai/generate-recipe")
@limiter.limit("10/minute")
async def generate_recipe(request: Request, req: GenerateRecipeRequest):
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

    shelf_constraint = ""
    if req.shelf_only:
        shelf_constraint = "\nIMPORTANT: Use ONLY the listed ingredients. Do NOT add any extra ingredients that are not in the list. You may use common pantry staples like salt, pepper, oil, and water."

    prompt = f"""Create a recipe using these ingredients: {', '.join(req.ingredients)}.
Servings: {req.servings or 2}
{constraint_text}{shelf_constraint}

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


class ChatRequest(BaseModel):
    messages: list[dict]
    stream: Optional[bool] = False
    context: Optional[str] = None

@router.post("/api/v1/ai/chat")
async def ai_chat(req: ChatRequest):
    """
    Generic chat endpoint for AI assistant.
    """
    ollama = get_ollama_service()
    if not await ollama.is_available():
        raise HTTPException(status_code=503, detail="AI service unavailable. Start Ollama.")
    
    # We will just pass the messages directly to Ollama generate_text if it supports history,
    # but ollama_service.py's generate_text expects a prompt string.
    # So we'll format the history into a single prompt for now.
    prompt_parts = []
    for msg in req.messages:
        role = msg.get('role', 'user').upper()
        content = msg.get('content', '')
        prompt_parts.append(f"{role}:\n{content}")
    
    final_prompt = "\n\n".join(prompt_parts)
    if req.context:
        final_prompt = f"Context:\n{req.context}\n\n" + final_prompt
        
    system = "You are a helpful cooking assistant."
    
    response = await ollama.generate_text(final_prompt, system_prompt=system, max_tokens=1024)
    
    return {
        "status": "success",
        "source": "ollama-local",
        "data": {"message": response.strip()},
    }

class NormalizeRecipeRequest(BaseModel):
    raw_text: str
    recipe_title: Optional[str] = None

class ParseRawRecipeRequest(BaseModel):
    raw_text: str



@router.post("/api/v1/ai/normalize-recipe")
async def normalize_recipe(req: NormalizeRecipeRequest):
    """
    Take raw/terse recipe text and return structured, detailed steps
    with timer data. Useful for importing or enriching recipes.
    """
    ollama = get_ollama_service()
    if not await ollama.is_available():
        raise HTTPException(status_code=503, detail="AI service unavailable. Start Ollama.")

    title_hint = f" for '{req.recipe_title}'" if req.recipe_title else ""

    prompt = f"""Convert this raw recipe text{title_hint} into detailed, beginner-friendly cooking steps.

Raw text:
{req.raw_text}

For each step:
- Write clear, specific instructions a beginner can follow
- Include exact measurements, temperatures, and visual cues
- Add timer_seconds for any step that involves waiting (boiling, baking, simmering, resting)
- Set timer_auto_start to true for passive waiting steps (simmer, bake, rest)

Return JSON only:
{{"steps": [{{"step": 1, "text": "...", "timer_seconds": null, "timer_auto_start": false}}]}}"""

    system = "You are a professional chef. Convert terse recipe instructions into detailed, beginner-friendly steps. Return only valid JSON."

    result = await ollama.generate_text_json(prompt, system_prompt=system)

    return {
        "status": "success" if "error" not in result else "partial",
        "source": "ollama-local",
        "data": result,
    }


@router.post("/api/v1/ai/parse-raw")
async def parse_raw_recipe(req: ParseRawRecipeRequest):
    """
    Parse a completely unstructured chunk of text (e.g. pasted from a website or blog)
    into a fully structured recipe object with title, ingredients, and steps.
    """
    ollama = get_ollama_service()
    if not await ollama.is_available():
        raise HTTPException(status_code=503, detail="AI service unavailable. Start Ollama.")

    prompt = f"""Extract and structure the recipe from this raw text.

Raw text:
{req.raw_text}

Extract the matching recipe title, prep time, cook time, servings, a short description, and an array of ingredients (with name, quantity, unit), and an array of detailed steps.

Return JSON only in this exact format:
{{
  "title": "...",
  "description": "...",
  "prep_time_minutes": 10,
  "cook_time_minutes": 20,
  "servings": 2,
  "difficulty": 1,
  "cuisine": "...",
  "ingredients": [{{"name": "...", "quantity": 1.5, "unit": "cups"}}],
  "steps": [{{"step": 1, "text": "...", "timer_seconds": null, "timer_auto_start": false}}]
}}"""

    system = "You are a professional chef and recipe parser. Extract the recipe details precisely. Return only valid JSON."

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


@router.post("/api/v1/ai/youtube-recipe")
@limiter.limit("10/minute")
async def extract_youtube_recipe(request: Request, req: YouTubeRecipeRequest):
    """
    Extract a structured recipe from YouTube video metadata.
    Uses the local LLM to parse titles + descriptions into ingredients/steps.
    """
    try:
        result = await extract_recipe_from_youtube(
            video_title=req.video_title,
            video_description=req.video_description,
            channel_name=req.channel_name,
        )

        if "error" in result:
            raise HTTPException(status_code=503, detail=result["error"])

        return {
            "status": "success",
            "source": "ollama-local",
            "data": result,
        }
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"[YouTubeRecipe] Extraction failed: {e}")
        raise HTTPException(status_code=500, detail=str(e))


import httpx

@router.post("/api/v1/ai/translate-recipe")
async def translate_recipe(req: TranslateRecipeRequest):
    """
    Translate a recipe using the local Ollama LLM.
    Fast translation, cached in Supabase.
    """
    db = get_supabase()
    
    # 1. Check cache in database
    try:
        cached = (
            db.table("recipe_translations")
            .select("title_translated, ingredients_translated, steps_translated")
            .eq("recipe_id", req.recipe_id)
            .eq("language_code", req.target_language)
            .maybe_single()
            .execute()
        )
        if cached and cached.data:
            return {
                "status": "success",
                "source": "database-cache",
                "data": {
                    "title": cached.data["title_translated"],
                    "ingredients": cached.data["ingredients_translated"],
                    "steps": cached.data["steps_translated"]
                }
            }
    except Exception as e:
        logger.warning(f"Failed to check translation cache: {e}")

    # 2. Not cached, call local Ollama
    ollama = get_ollama_service()
    if not await ollama.is_available():
        raise HTTPException(status_code=503, detail="Local AI service unavailable. Start Ollama.")

    prompt = f"""Translate the following recipe to {req.target_language} language.
Keep all measurements exact. Make instructions natural.

Title: {req.title}
Ingredients: {req.ingredients}
Steps: {req.steps}

Return JSON strictly in this format:
{{
  "title": "...",
  "ingredients": [{{"name": "...", "quantity": 1, "unit": "...", "prep_note": "..."}}],
  "steps": [{{"step_number": 1, "text": "...", "timer_seconds": null}}]
}}"""

    system = "You are a professional recipe translator. Return only exact JSON structure as requested."

    result = await ollama.generate_text_json(prompt, system_prompt=system)

    if "error" in result:
        return {
            "status": "partial",
            "message": "AI returned non-JSON. Raw response included.",
            "data": result,
        }

    parsed = result

    # 3. Save to cache
    try:
        db.table("recipe_translations").insert({
            "recipe_id": req.recipe_id,
            "language_code": req.target_language,
            "title_translated": parsed.get("title", req.title),
            "ingredients_translated": parsed.get("ingredients", []),
            "steps_translated": parsed.get("steps", [])
        }).execute()
    except Exception as e:
        logger.warning(f"Failed to save translation cache: {e}")
        
    return {
        "status": "success",
        "source": "ollama-local",
        "data": parsed
    }

@router.post("/api/v1/ai/shopping-list")
async def generate_shopping_list(req: ShoppingListRequest):
    """
    Generate a consolidated shopping list from missing ingredients
    across multiple recipes the user wants to cook.
    
    Groups items by category and deduplicates shared ingredients.
    """
    db = get_supabase()
    try:
        # 1. Get user's current inventory
        inv = (
            db.table("inventory_items")
            .select("ingredient_id, quantity, unit")
            .eq("user_id", req.user_id)
            .gt("quantity", 0)
            .execute()
        )
        owned_ids = {row["ingredient_id"] for row in (inv.data or [])}

        # 2. Get required ingredients for all requested recipes
        shopping: dict[str, dict] = {}

        for recipe_id in req.recipe_ids:
            ings = (
                db.table("recipe_ingredients")
                .select("ingredient_id, quantity, unit, is_optional, ingredients(display_name_en, category)")
                .eq("recipe_id", recipe_id)
                .eq("is_optional", False)
                .execute()
            )
            recipe_meta = (
                db.table("recipes")
                .select("title")
                .eq("id", recipe_id)
                .maybe_single()
                .execute()
            )
            recipe_title = recipe_meta.data["title"] if recipe_meta.data else recipe_id

            for ing in (ings.data or []):
                iid = ing["ingredient_id"]
                if iid in owned_ids:
                    continue

                ing_data = ing.get("ingredients") or {}
                name = ing_data.get("display_name_en", "Unknown")
                category = ing_data.get("category", "other")
                qty = float(ing.get("quantity", 1))
                unit = ing.get("unit", "")

                if iid in shopping:
                    shopping[iid]["qty_needed"] += qty
                    shopping[iid]["recipes"].append(recipe_title)
                else:
                    shopping[iid] = {
                        "ingredient_id": iid,
                        "name": name,
                        "category": category,
                        "qty_needed": qty,
                        "unit": unit,
                        "recipes": [recipe_title],
                    }

        # 3. Group by category
        by_category: dict[str, list] = {}
        for item in shopping.values():
            cat = item["category"]
            by_category.setdefault(cat, []).append(item)

        result = []
        for cat in sorted(by_category.keys()):
            items = sorted(by_category[cat], key=lambda x: x["name"])
            result.append({"category": cat, "items": items})

        return {
            "status": "success",
            "data": {
                "categories": result,
                "total_items": len(shopping),
                "recipe_count": len(req.recipe_ids),
            },
        }

    except Exception as e:
        logger.error(f"[ShoppingList] Generation failed: {e}")
        raise HTTPException(status_code=500, detail=str(e))

