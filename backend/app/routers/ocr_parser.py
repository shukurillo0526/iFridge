"""
I-Fridge — Receipt Scanner Router
===================================
Receives a receipt image and extracts structured ingredient data.

Two-stage local pipeline:
  Stage 1: moondream (vision) reads ALL text from the receipt image
  Stage 2: qwen2.5:3b (text LLM) parses the raw text into structured JSON

Includes retry with a simpler prompt if Stage 1 produces weak output.

Fallback chain:
  1. Local two-stage pipeline (with retry)
  2. Cloud Gemini Vision
  3. Mock data
"""

import json
import logging
from fastapi import APIRouter, UploadFile, File, HTTPException

from app.services.ocr_service import process_gemini_receipt_json
from app.services.ollama_service import get_ollama_service

logger = logging.getLogger("ifridge.ocr")

router = APIRouter()

# ── Stage 1 prompts: moondream reads receipt text ─────────────

# Primary: exhaustive OCR prompt
RECEIPT_OCR_PRIMARY = """This is a photo of a grocery store receipt. Read ALL the text on this receipt carefully.

Read it from top to bottom, line by line. Include:
- The store name at the top
- The date
- Every product name, quantity, and price
- The total amount

Read the exact text you see. If you see Korean text, read it as-is.
Do NOT skip any lines. Read everything printed on this receipt."""

# Fallback: simpler prompt
RECEIPT_OCR_FALLBACK = """What items are listed on this receipt? List the store name, date, and every product with its price."""

# ── Stage 2 prompt: qwen2.5 structures receipt text ──────────

RECEIPT_STRUCTURE_PROMPT = """You are a grocery receipt parser for a kitchen inventory app. Convert this raw receipt text into structured JSON.

RAW RECEIPT TEXT:
{receipt_text}

RULES:
1. Extract store name (translate Korean to English if needed, e.g. "진안식자재마트" → "Jinan Food Materials Mart")
2. Extract purchase date in YYYY-MM-DD format (e.g. "26-02-22" → "2026-02-22")
3. For EACH food product listed on the receipt:
   - item_name: Generic English name. Translate Korean → English:
     * 갓밀크/우유 → "Milk"
     * 당근 → "Carrot"  
     * 삼겹살 → "Pork Belly"
     * 계란 → "Eggs"
     * 닭가슴살/Chicken breast → "Chicken Breast"
     * 치즈 → "Cheese"
     * 빵 → "Bread"
   - quantity: number from the receipt (quantity column, or extract from name like "1L", "500g", "2입")
   - unit: one of pcs, g, kg, ml, L, pack, bunch
   - category: one of Produce, Vegetable, Fruit, Meat, Poultry, Seafood, Dairy, Milk, Cheese, Yogurt, Eggs, Bakery, Bread, Pantry, Canned, Frozen, Beverage, Juice, Snack, Condiment, Spices, Oil, Sauce
   - price: the total price for that item (the last number on the item line)
4. SKIP non-food items: bags, discounts, tax lines, card info, totals, barcodes
5. Include ALL food items — do not skip any

IMPORTANT: Extract EVERY food item. If you see 4 items, return 4 items.

Return ONLY valid JSON, no other text:
{{"store": "Store Name", "date": "2026-02-22", "items": [{{"item_name": "Milk", "quantity": 1, "unit": "L", "category": "Milk", "price": 1980}}, {{"item_name": "Carrot", "quantity": 2, "unit": "pcs", "category": "Vegetable", "price": 1300}}]}}"""

# ── Cloud Gemini (single-stage fallback) ──────────────────────

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

# Mock response
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
    Two-stage pipeline with retry: moondream (OCR) → qwen2.5 (structuring).
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
            receipt_text = None

            # Stage 1A: Primary OCR prompt — thorough text reading
            logger.info("[OCR] Stage 1A: moondream reading receipt (primary)...")
            try:
                text = await ollama.analyze_image(
                    image_bytes=image_bytes,
                    prompt=RECEIPT_OCR_PRIMARY,
                    model="moondream",
                    temperature=0.2,
                    max_tokens=2048,  # receipts can be long
                )
                logger.info(f"[OCR] Stage 1A result ({len(text)} chars): {text[:400]}")
                if text and len(text.strip()) > 30:
                    receipt_text = text
            except Exception as e:
                logger.warning(f"[OCR] Stage 1A failed: {e}")

            # Stage 1B: Retry with simpler prompt if primary was weak
            if not receipt_text or len(receipt_text.strip()) < 30:
                logger.info("[OCR] Stage 1B: retrying with fallback prompt...")
                try:
                    text = await ollama.analyze_image(
                        image_bytes=image_bytes,
                        prompt=RECEIPT_OCR_FALLBACK,
                        model="moondream",
                        temperature=0.4,
                        max_tokens=1024,
                    )
                    logger.info(f"[OCR] Stage 1B result ({len(text)} chars): {text[:400]}")
                    if text and len(text.strip()) > 20:
                        receipt_text = text
                except Exception as e:
                    logger.warning(f"[OCR] Stage 1B failed: {e}")

            # Stage 2: Structure with qwen2.5
            if receipt_text:
                logger.info("[OCR] Stage 2: qwen2.5 structuring into JSON...")
                structured_prompt = RECEIPT_STRUCTURE_PROMPT.format(receipt_text=receipt_text)
                result = await ollama.generate_text_json(
                    prompt=structured_prompt,
                    model="qwen2.5:3b",
                )
                if "error" not in result and result.get("items"):
                    parsed_data = result
                    source = "ollama-two-stage"
                    logger.info(f"[OCR] Two-stage success: {len(result['items'])} items found")
                else:
                    logger.warning(f"[OCR] Stage 2 failed to produce items: {result}")
            else:
                logger.warning("[OCR] All Stage 1 attempts produced insufficient text")
    except Exception as e:
        logger.warning(f"[OCR] Local pipeline failed: {e}")

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

    # Process through heuristic expiry engine
    processed = process_gemini_receipt_json(json.dumps(parsed_data))

    return {
        "status": "success",
        "source": source,
        "data": processed,
    }
