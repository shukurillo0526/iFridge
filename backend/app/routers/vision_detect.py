"""
I-Fridge — Photo Ingredient Detection Router
==============================================
Receives a photo of loose ingredients and identifies them.

Two-stage local pipeline:
  Stage 1: moondream (vision) describes what it sees — emphasis on counting
  Stage 2: qwen2.5:3b (text LLM) structures the description into JSON

If Stage 1 produces a weak description, it retries with a fallback prompt.

Fallback chain:
  1. Local two-stage pipeline (with retry)
  2. Cloud Gemini Vision
  3. Mock data
"""

import json
import logging
from fastapi import APIRouter, UploadFile, File, HTTPException

from app.services.ollama_service import get_ollama_service

logger = logging.getLogger("ifridge.vision")

router = APIRouter()

# ── Stage 1 prompts (moondream vision) ────────────────────────

# Primary: detailed counting prompt
VISION_DESCRIBE_PRIMARY = """Look at this image very carefully.

1. List EVERY food item you can see.
2. For each item, state:
   - What it is (be specific: "brown eggs" not just "food")
   - How many there are (count carefully — count each individual piece)
   - Any packaging (carton, bag, box, bunch)
   - Approximate size or weight if visible

Be thorough. Do not skip any item. Count precisely."""

# Fallback: simpler prompt if primary gives weak results
VISION_DESCRIBE_FALLBACK = """What food items are in this image? List each one with the quantity you can see."""

# ── Stage 2 prompt (qwen2.5:3b text → JSON) ──────────────────

VISION_STRUCTURE_PROMPT = """You are a food ingredient parser for a kitchen inventory app. Convert this image description into a JSON list of food items.

IMAGE DESCRIPTION:
{description}

RULES:
- Extract EVERY food item mentioned in the description
- item_name: short English name (e.g., "Banana", "Eggs", "Chicken Breast")
- quantity: the exact count or weight mentioned (e.g., if "3 bananas" → 3, if "a dozen eggs" → 12, if "a carton of 12 eggs" → 12)
- unit: one of: pcs, g, kg, oz, lb, ml, L, pack, bunch, dozen
- category: one of: Produce, Vegetable, Fruit, Meat, Poultry, Seafood, Dairy, Milk, Cheese, Yogurt, Eggs, Bakery, Bread, Pantry, Canned, Dried, Spices, Oil, Sauce, Condiment, Frozen, Beverage, Juice, Snack
- freshness: fresh, good, aging, or expired (default "fresh")
- confidence: 0.7 to 1.0

IMPORTANT: Do NOT make up items that were not mentioned. Only include items from the description.

Return ONLY valid JSON with no other text:
{{"items": [{{"item_name": "Banana", "quantity": 3, "unit": "pcs", "category": "Fruit", "freshness": "fresh", "confidence": 0.95}}]}}"""

# ── Cloud Gemini (single-stage fallback) ──────────────────────

CLOUD_VISION_PROMPT = """
You are an expert food ingredient identifier for the I-Fridge smart kitchen app.

Look at this photo and identify every visible food ingredient. Count carefully.
For each item provide:
- item_name: A short, generic English name
- quantity: Exact count or weight you can see (count each individual piece)
- unit: One of: pcs, g, kg, oz, lb, ml, L, pack, bunch, dozen
- category: One of: Produce, Vegetable, Fruit, Meat, Poultry, Seafood,
  Dairy, Milk, Cheese, Yogurt, Eggs, Bakery, Bread, Pantry, Canned,
  Dried, Spices, Oil, Sauce, Condiment, Frozen, Beverage, Juice, Snack
- freshness: One of: fresh, good, aging, expired
- confidence: A float 0.0-1.0

Return STRICT JSON ONLY with NO markdown:
{"items": [{"item_name": "Eggs", "quantity": 12, "unit": "pcs", "category": "Eggs", "freshness": "fresh", "confidence": 0.95}]}
"""

MOCK_RESPONSE = {
    "items": [
        {"item_name": "Banana", "quantity": 3, "unit": "pcs", "category": "Fruit", "freshness": "good", "confidence": 0.92},
        {"item_name": "Red Bell Pepper", "quantity": 2, "unit": "pcs", "category": "Vegetable", "freshness": "fresh", "confidence": 0.88},
    ]
}


@router.post("/api/v1/vision/detect-ingredients")
async def detect_ingredients(file: UploadFile = File(...)):
    """
    Receives a photo of loose food ingredients and identifies them.
    Two-stage pipeline with retry: moondream → qwen2.5.
    """
    if not file.content_type or not file.content_type.startswith('image/'):
        raise HTTPException(status_code=400, detail="File must be an image")

    image_bytes = await file.read()
    source = "mock"
    parsed_data = None

    # ── Attempt 1: Local two-stage pipeline ──────────────────────
    try:
        ollama = get_ollama_service()
        if await ollama.is_available():
            description = None

            # Stage 1A: Primary describe prompt
            logger.info("[Vision] Stage 1A: moondream describing image (primary)...")
            try:
                desc = await ollama.analyze_image(
                    image_bytes=image_bytes,
                    prompt=VISION_DESCRIBE_PRIMARY,
                    model="moondream",
                    temperature=0.3,
                    max_tokens=1024,
                )
                logger.info(f"[Vision] Stage 1A result ({len(desc)} chars): {desc[:300]}")
                if desc and len(desc.strip()) > 15:
                    description = desc
            except Exception as e:
                logger.warning(f"[Vision] Stage 1A failed: {e}")

            # Stage 1B: Retry with fallback prompt if primary was weak
            if not description or len(description.strip()) < 15:
                logger.info("[Vision] Stage 1B: retrying with fallback prompt...")
                try:
                    desc = await ollama.analyze_image(
                        image_bytes=image_bytes,
                        prompt=VISION_DESCRIBE_FALLBACK,
                        model="moondream",
                        temperature=0.5,
                        max_tokens=512,
                    )
                    logger.info(f"[Vision] Stage 1B result ({len(desc)} chars): {desc[:300]}")
                    if desc and len(desc.strip()) > 10:
                        description = desc
                except Exception as e:
                    logger.warning(f"[Vision] Stage 1B failed: {e}")

            # Stage 2: Structure with qwen2.5
            if description:
                logger.info("[Vision] Stage 2: qwen2.5 structuring into JSON...")
                structured_prompt = VISION_STRUCTURE_PROMPT.format(description=description)
                result = await ollama.generate_text_json(
                    prompt=structured_prompt,
                    model="qwen2.5:3b",
                )
                if "error" not in result and result.get("items"):
                    parsed_data = result
                    source = "ollama-two-stage"
                    logger.info(f"[Vision] Success: {len(result['items'])} items detected")
                else:
                    logger.warning(f"[Vision] Stage 2 parse failed: {result}")
    except Exception as e:
        logger.warning(f"[Vision] Local pipeline failed: {e}")

    # ── Attempt 2: Cloud Gemini ─────────────────────────────────
    if parsed_data is None:
        try:
            import os
            api_key = os.environ.get("GEMINI_API_KEY")
            if api_key:
                import google.generativeai as genai
                genai.configure(api_key=api_key)
                model = genai.GenerativeModel('gemini-1.5-flash')
                response = model.generate_content(
                    [
                        CLOUD_VISION_PROMPT,
                        {"mime_type": file.content_type, "data": image_bytes},
                    ],
                    generation_config=genai.GenerationConfig(
                        temperature=0.1,
                        max_output_tokens=2048,
                    ),
                )
                raw_text = response.text.strip()
                if raw_text.startswith("```"):
                    raw_text = raw_text.split("\n", 1)[1]
                    if raw_text.endswith("```"):
                        raw_text = raw_text[:-3]
                parsed_data = json.loads(raw_text)
                source = "gemini"
        except Exception as e:
            logger.warning(f"[Vision] Gemini failed: {e}")

    # ── Attempt 3: Mock fallback ────────────────────────────────
    if parsed_data is None:
        parsed_data = MOCK_RESPONSE
        source = "mock"

    items = parsed_data.get("items", [])

    return {
        "status": "success",
        "source": source,
        "item_count": len(items),
        "data": parsed_data,
    }
