"""
I-Fridge — Receipt Scanner Router
===================================
Receives a receipt image and extracts structured ingredient data.

Priority chain:
  1. Local Ollama (moondream) — free, private, works offline
  2. Cloud Gemini Vision — higher accuracy, requires API key
  3. Mock data — development fallback
"""

import json
import logging
from fastapi import APIRouter, UploadFile, File, HTTPException

from app.services.ocr_service import process_gemini_receipt_json
from app.services.ollama_service import get_ollama_service

logger = logging.getLogger("ifridge.ocr")

router = APIRouter()

# ── Prompts ──────────────────────────────────────────────────────

# Simplified prompt for local models (moondream has limited context)
LOCAL_RECEIPT_PROMPT = """Look at this grocery receipt image. Extract the store name, date, and all food items.

For each food item, provide:
- item_name: English name (translate Korean if needed)
- quantity: number amount
- unit: pcs, g, kg, ml, L, or pack
- category: one of Produce, Vegetable, Fruit, Meat, Dairy, Milk, Eggs, Bakery, Bread, Pantry, Seafood, Frozen, Beverage, Snack
- price: the price number

Return JSON only:
{"store": "name", "date": "YYYY-MM-DD", "items": [{"item_name": "...", "quantity": 1, "unit": "pcs", "category": "...", "price": 0}]}"""

# Full prompt for cloud Gemini (supports more detail)
CLOUD_RECEIPT_PROMPT = """
You are an expert Korean grocery receipt parser for the I-Fridge smart kitchen app.

RECEIPT FORMAT (Korean marts like 진안식자재마트, 이마트, 홈플러스, etc.):
- Store name is on the first line, often prefixed with (주) or (사)
- Date line: "판매일:YY-MM-DD HH:MM" → convert to "20YY-MM-DD"
- Item table header: "NO. 상품명 단가 수량 금액"
- Each item has TWO lines:
  Line 1: NO. [Korean product name] [size info like 1L, 500g]
  Line 2: [barcode number] [unit_price] [qty] [total_price] [tax marker like #]
- Items marked with # are tax-exempt food (면세물품) — these are always food.
- Total line: "합 계:" followed by the total amount
- Skip non-food rows (bags, discounts, tax summaries, card info, barcodes)

TRANSLATION RULES for Korean food names:
- "갓밀크 저지방 1L" → item_name: "Low Fat Milk", quantity: 1, unit: "L", category: "Milk"
- "세척당근(송국산) 2입/1팩" → item_name: "Washed Carrot", quantity: 2, unit: "pcs", category: "Vegetable"
- "삼겹살 600g" → item_name: "Pork Belly", quantity: 600, unit: "g", category: "Meat"
- "계란 30구" → item_name: "Eggs", quantity: 30, unit: "pcs", category: "Eggs"
- Extract volume/weight from the product name (e.g., "1L", "500ml", "200g")

Return STRICT JSON ONLY with NO markdown formatting, NO code fences:
{
  "store": "Store Name in English",
  "date": "YYYY-MM-DD",
  "items": [
    {
      "item_name": "Generic English Name",
      "quantity": 1.0,
      "unit": "pcs/L/g/kg/ml/pack/bunch",
      "category": "Dairy/Vegetable/Meat/Fruit/Pantry/...",
      "price": 1980
    }
  ]
}
"""

# Mock response mirrors the real receipt from 진안식자재마트 (2026-02-22)
MOCK_RESPONSE = {
    "store": "Jinan Food Materials Mart",
    "date": "2026-02-22",
    "items": [
        {"item_name": "Low Fat Milk", "quantity": 1.0, "unit": "L", "category": "Milk", "price": 1980},
        {"item_name": "Washed Carrot", "quantity": 2.0, "unit": "pcs", "category": "Vegetable", "price": 1300},
    ]
}


@router.post("/api/v1/receipt/scan")
async def scan_receipt(file: UploadFile = File(...)):
    """
    Receives a receipt image and returns structured ingredient data.
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
            logger.info("[OCR] Trying local Ollama (moondream)...")
            result = await ollama.analyze_image_json(
                image_bytes=image_bytes,
                prompt=LOCAL_RECEIPT_PROMPT,
                model="moondream",
            )
            if "error" not in result and result.get("items"):
                parsed_data = result
                source = "ollama-moondream"
                logger.info(f"[OCR] Ollama success: {len(result['items'])} items found")
    except Exception as e:
        logger.warning(f"[OCR] Ollama failed: {e}")

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
                        CLOUD_RECEIPT_PROMPT,
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
                logger.info(f"[OCR] Gemini success: {len(parsed_data.get('items', []))} items")
        except Exception as e:
            logger.warning(f"[OCR] Gemini failed: {e}")

    # ── Attempt 3: Mock fallback ────────────────────────────────
    if parsed_data is None:
        logger.info("[OCR] Using mock fallback data")
        parsed_data = MOCK_RESPONSE
        source = "mock"

    # Process through our heuristic expiry engine
    processed = process_gemini_receipt_json(json.dumps(parsed_data))

    return {
        "status": "success",
        "source": source,
        "data": processed,
    }
