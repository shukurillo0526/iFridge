import os
import re

path = r'd:\dev\projects\iFridge\backend\app\routers\recipe_ai.py'
with open(path, 'r', encoding='utf-8') as f: content = f.read()

endpoint = """@router.post("/api/v1/ai/translate-recipe")
async def translate_recipe(req: TranslateRecipeRequest):
    \"\"\"
    Translate a recipe using Gemini 1.5 Flash.
    Fast and cheap translation, cached in Supabase.
    \"\"\"
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

    # 2. Not cached, call Gemini
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        raise HTTPException(status_code=500, detail="GEMINI_API_KEY not configured")

    prompt = f\"\"\"Translate the following recipe to {req.target_language} language.
Keep all measurements exact. Make instructions natural.

Title: {req.title}
Ingredients: {req.ingredients}
Steps: {req.steps}

Return JSON strictly in this format:
{{
  "title": "...",
  "ingredients": [{{"name": "...", "quantity": 1, "unit": "...", "prep_note": "..."}}],
  "steps": [{{"step_number": 1, "text": "...", "timer_seconds": null}}]
}}\"\"\"

    url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key={api_key}"
    payload = {
        "contents": [{"parts": [{"text": prompt}]}],
        "generationConfig": {"response_mime_type": "application/json"}
    }
    
    async with httpx.AsyncClient() as client:
        try:
            resp = await client.post(url, json=payload, timeout=20.0)
            resp.raise_for_status()
            data = resp.json()
            raw_text = data["candidates"][0]["content"]["parts"][0]["text"]
            
            if raw_text.startswith("```json"):
                raw_text = raw_text.strip("```json").strip("```").strip()
            elif raw_text.startswith("```"):
                raw_text = raw_text.strip("```").strip()
                
            parsed = json.loads(raw_text)
            
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
                "source": "gemini-1.5-flash",
                "data": parsed
            }
        except Exception as e:
            logger.error(f"[TranslateRecipe] Translation failed: {e}")
            raise HTTPException(status_code=500, detail=str(e))"""

content = re.sub(
    r"@router\.post\(\"/api/v1/ai/translate-recipe\"\).*?raise HTTPException\(status_code=500, detail=str\(e\)\)",
    endpoint,
    content,
    flags=re.DOTALL
)

with open(path, 'w', encoding='utf-8') as f: f.write(content)
print("Updated backend recipe_ai.py with new translation schema!")
