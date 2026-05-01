import asyncio
import os
import sys
import json
from pathlib import Path

# Add backend to path so we can use existing app services
backend_dir = Path(__file__).parent.parent / "backend"
sys.path.append(str(backend_dir))

from dotenv import load_dotenv
load_dotenv(backend_dir / ".env")

sys.stdout.reconfigure(encoding='utf-8')

from app.db.supabase_client import get_supabase
from app.services.ollama_service import get_ollama_service

async def main():
    print("Starting local translation job using Ollama...")
    db = get_supabase()
    ollama = get_ollama_service()
    
    if not await ollama.is_available():
        print("Error: Ollama is not available. Please ensure it's running via `ollama serve`")
        return
        
    models = await ollama.list_models()
    print(f"Available Ollama models: {models}")
    model_name = await ollama._resolve_model("text")
    print(f"Selected model for translation: {model_name}")

    # 1. Fetch all recipes
    response = db.table("recipes").select("id, title, ingredients, steps").execute()
    recipes = response.data
    print(f"Found {len(recipes)} recipes in the database.")

    target_languages = ["ru", "uz"]

    for i, recipe in enumerate(recipes):
        recipe_id = recipe["id"]
        title = recipe["title"]
        ingredients = recipe["ingredients"]
        steps = recipe["steps"]
        
        for lang in target_languages:
            # Check if we already translated this (skip if not forced)
            force_retranslate = len(sys.argv) > 1 and sys.argv[1] == '--force'
            
            cached = db.table("recipe_translations") \
                .select("id") \
                .eq("recipe_id", recipe_id) \
                .eq("language_code", lang) \
                .execute()
            
            if cached.data and not force_retranslate:
                print(f"[{i+1}/{len(recipes)}] '{title}' -> {lang} (Skipping, already cached)")
                continue

            if cached.data and force_retranslate:
                # Delete existing translation before regenerating
                db.table("recipe_translations").delete().eq("recipe_id", recipe_id).eq("language_code", lang).execute()

            print(f"[{i+1}/{len(recipes)}] Translating '{title}' to {lang}...")
            
            prompt = f"""Translate the following recipe to {lang} language.
Keep all measurements exact. Make instructions natural.

CRITICAL RULE FOR RECIPE TITLE:
Do not blindly translate the entire title literally. Preserve cultural dish names or styles, while translating the core ingredients.
For example:
- 'Chicken Nuggets' -> 'Tovuq nuggets' (instead of literal translation)
- 'Teriyaki Chicken Bowl' -> 'Teriyaki Tovuq Bowl'
- 'Beef Stroganoff' -> 'Mol go'shtidan Stroganoff'
- 'Hummus' -> 'Hummus'

Title: {title}
Ingredients: {json.dumps(ingredients, ensure_ascii=False)}
Steps: {json.dumps(steps, ensure_ascii=False)}

Return JSON strictly in this format:
{{
  "title": "...",
  "ingredients": [{{"name": "...", "quantity": 1, "unit": "...", "prep_note": "..."}}],
  "steps": [{{"step_number": 1, "text": "...", "timer_seconds": null}}]
}}"""
            system = "You are a professional recipe translator. Return only exact JSON structure as requested."

            result = await ollama.generate_text_json(prompt, system_prompt=system)
            
            if "error" in result:
                print(f"  [ERROR] Translating '{title}' to {lang}: {result['error']}")
                continue
            
            try:
                db.table("recipe_translations").insert({
                    "recipe_id": recipe_id,
                    "language_code": lang,
                    "title_translated": result.get("title", title),
                    "ingredients_translated": result.get("ingredients", ingredients),
                    "steps_translated": result.get("steps", steps)
                }).execute()
                print(f"  [OK] Saved {lang} translation.")
            except Exception as e:
                print(f"  [ERROR] DB Error saving {lang} translation: {e}")

if __name__ == "__main__":
    asyncio.run(main())
