"""
I-Fridge — Photo Ingredient Detection Router
==============================================
Receives a photo of loose ingredients and identifies them.

Priority chain:
  1. Local Ollama (moondream) — free, private, works offline
  2. Cloud Gemini Vision — higher accuracy, requires API key
  3. Mock data — development fallback
"""

import json
import logging
from fastapi import APIRouter, UploadFile, File, HTTPException

from app.services.ollama_service import get_ollama_service

logger = logging.getLogger("ifridge.vision")

router = APIRouter()

# ── Prompts ──────────────────────────────────────────────────────

LOCAL_VISION_PROMPT = """Look at this photo and identify every visible food ingredient.

For each item provide:
- item_name: short English name (e.g., "Apple", "Chicken Breast")
- quantity: estimated count or weight visible
- unit: pcs, g, kg, ml, L, or pack
- category: one of Produce, Vegetable, Fruit, Meat, Dairy, Milk, Eggs, Bakery, Bread, Pantry, Seafood, Frozen, Beverage, Snack
- freshness: fresh, good, aging, or expired
- confidence: 0.0 to 1.0

Return JSON only:
{"items": [{"item_name": "...", "quantity": 1, "unit": "pcs", "category": "...", "freshness": "fresh", "confidence": 0.9}]}

If no food is visible, return: {"items": []}"""

CLOUD_VISION_PROMPT = """
You are an expert food ingredient identifier for the I-Fridge smart kitchen app.

Look at this photo and identify every visible food ingredient. For each item:
- item_name: A short, generic English name
- quantity: Estimated count or weight you can see (default 1 if unclear)
- unit: One of: pcs, g, kg, oz, lb, ml, L, pack, bunch
- category: One of: Produce, Vegetable, Fruit, Meat, Poultry, Seafood,
  Dairy, Milk, Cheese, Yogurt, Eggs, Bakery, Bread, Pantry, Canned,
  Dried, Spices, Oil, Sauce, Condiment, Frozen, Beverage, Juice, Snack
- freshness: One of: fresh, good, aging, expired
- confidence: A float 0.0–1.0

Return STRICT JSON ONLY with NO markdown:
{"items": [{"item_name": "Apple", "quantity": 3, "unit": "pcs", "category": "Fruit", "freshness": "fresh", "confidence": 0.95}]}
"""

MOCK_RESPONSE = {
    "items": [
        {"item_name": "Banana", "quantity": 4, "unit": "pcs", "category": "Fruit", "freshness": "good", "confidence": 0.92},
        {"item_name": "Red Bell Pepper", "quantity": 2, "unit": "pcs", "category": "Vegetable", "freshness": "fresh", "confidence": 0.88},
        {"item_name": "Whole Milk", "quantity": 1, "unit": "L", "category": "Milk", "freshness": "fresh", "confidence": 0.85},
        {"item_name": "Chicken Thigh", "quantity": 500, "unit": "g", "category": "Meat", "freshness": "fresh", "confidence": 0.78},
        {"item_name": "Sourdough Bread", "quantity": 1, "unit": "pcs", "category": "Bread", "freshness": "fresh", "confidence": 0.90},
    ]
}


@router.post("/api/v1/vision/detect-ingredients")
async def detect_ingredients(file: UploadFile = File(...)):
    """
    Receives a photo of loose food ingredients and identifies them.
    Tries: Local Ollama → Cloud Gemini → Mock fallback.
    """
    if not file.content_type or not file.content_type.startswith('image/'):
        raise HTTPException(status_code=400, detail="File must be an image")

    image_bytes = await file.read()
    source = "mock"
    parsed_data = None

    # ── Attempt 1: Local Ollama (moondream) ──────────────────────
    try:
        ollama = get_ollama_service()
        if await ollama.is_available():
            logger.info("[Vision] Trying local Ollama (moondream)...")
            result = await ollama.analyze_image_json(
                image_bytes=image_bytes,
                prompt=LOCAL_VISION_PROMPT,
                model="moondream",
            )
            if "error" not in result:
                parsed_data = result
                source = "ollama-moondream"
                logger.info(f"[Vision] Ollama success: {len(result.get('items', []))} items")
    except Exception as e:
        logger.warning(f"[Vision] Ollama failed: {e}")

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
