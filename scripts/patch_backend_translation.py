import os
import re

path = r'd:\dev\projects\iFridge\backend\app\routers\recipe_ai.py'
with open(path, 'r', encoding='utf-8') as f: content = f.read()

models = """class TranslateRecipeRequest(BaseModel):
    recipe_id: str
    title: str
    ingredients: str
    steps: str
    target_language: str"""

content = re.sub(
    r"class TranslateRecipeRequest\(BaseModel\):.*?target_language: str",
    models,
    content,
    flags=re.DOTALL
)

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
            .select("title, ingredients, steps")
            .eq("recipe_id", req.recipe_id)
            .eq("language_code", req.target_language)
            .maybe_single()
            .execute()
        )
        if cached and cached.data:
            return {
                "status": "success",
                "source": "database-cache",
                "data": cached.data
            }
    except Exception as e:
        logger.warning(f"Failed to check translation cache (table might not exist yet): {e}")

    # 2. Not cached, call Gemini
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        raise HTTPException(status_code=500, detail="GEMINI_API_KEY not configured")

    prompt = f\"\"\"Translate the following recipe to {req.target_language} language.
Keep all measurements and numbers exactly the same.
Make the instructions natural and easy to follow.

Title: {req.title}
Ingredients: {req.ingredients}
Steps: {req.steps}

Return JSON only in this exact format:
{{
  "title": "...",
  "ingredients": "...",
  "steps": "..."
}}\"\"\"

    url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key={api_key}"
    payload = {
        "contents": [{"parts": [{"text": prompt}]}],
        "generationConfig": {"response_mime_type": "application/json"}
    }
    
    async with httpx.AsyncClient() as client:
        try:
            resp = await client.post(url, json=payload, timeout=15.0)
            resp.raise_for_status()
            data = resp.json()
            text_response = data["candidates"][0]["content"]["parts"][0]["text"]
            
            if text_response.startswith("```json"):
                text_response = text_response.strip("```json").strip("```").strip()
            elif text_response.startswith("```"):
                text_response = text_response.strip("```").strip()
                
            parsed = json.loads(text_response)
            
            # 3. Save to cache
            try:
                db.table("recipe_translations").insert({
                    "recipe_id": req.recipe_id,
                    "language_code": req.target_language,
                    "title": parsed.get("title", req.title),
                    "ingredients": parsed.get("ingredients", ""),
                    "steps": parsed.get("steps", "")
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
print("Updated backend recipe_ai.py with DB cache logic!")
