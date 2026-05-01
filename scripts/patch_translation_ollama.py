import os
import re

path = r'd:\dev\projects\iFridge\backend\app\routers\recipe_ai.py'
with open(path, 'r', encoding='utf-8') as f: content = f.read()

endpoint = """@router.post("/api/v1/ai/translate-recipe")
async def translate_recipe(req: TranslateRecipeRequest):
    \"\"\"
    Translate a recipe using the local Ollama LLM.
    Fast translation, cached in Supabase.
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

    # 2. Not cached, call local Ollama
    ollama = get_ollama_service()
    if not await ollama.is_available():
        raise HTTPException(status_code=503, detail="Local AI service unavailable. Start Ollama.")

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
    }"""

content = re.sub(
    r"@router\.post\(\"/api/v1/ai/translate-recipe\"\).*?(?=\n\n@router\.post\(\"/api/v1/ai/shopping-list\"\))",
    endpoint,
    content,
    flags=re.DOTALL
)

with open(path, 'w', encoding='utf-8') as f: f.write(content)
print("Updated backend recipe_ai.py to use Local Ollama!")
