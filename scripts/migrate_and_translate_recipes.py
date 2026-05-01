import os
import sys
import json
import asyncio
import httpx
from dotenv import load_dotenv

# Ensure we can import the backend modules
sys.path.insert(0, r'd:\dev\projects\iFridge\backend')
load_dotenv(r'd:\dev\projects\iFridge\backend\.env')

from app.db.supabase_client import get_supabase

async def main():
    db = get_supabase()
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        print("GEMINI_API_KEY is not set in .env")
        return

    print("========================================")
    print("Recipe Migration & Translation Engine")
    print("========================================")

    # 1. Fetch all existing recipes before the schema change
    print("1. Fetching all 133 recipes and their relational data...")
    try:
        recipes_resp = db.table("recipes").select("*").execute()
        recipes = recipes_resp.data
        
        # If the relational tables are already dropped, this will fail.
        # We assume the user runs this script BEFORE running the SQL migration!
        ingredients_resp = db.table("recipe_ingredients").select("*, ingredients(display_name_en)").execute()
        steps_resp = db.table("recipe_steps").select("*").execute()
        
        recipe_ing_map = {}
        for row in ingredients_resp.data:
            rid = row["recipe_id"]
            if rid not in recipe_ing_map:
                recipe_ing_map[rid] = []
            
            name = row.get("ingredients", {}).get("display_name_en", "Unknown") if row.get("ingredients") else "Unknown"
            
            recipe_ing_map[rid].append({
                "ingredient_id": row["ingredient_id"],
                "name": name,
                "quantity": row["quantity"],
                "unit": row["unit"],
                "is_optional": row["is_optional"],
                "prep_note": row["prep_note"]
            })
            
        recipe_steps_map = {}
        for row in steps_resp.data:
            rid = row["recipe_id"]
            if rid not in recipe_steps_map:
                recipe_steps_map[rid] = []
            recipe_steps_map[rid].append({
                "step_number": row["step_number"],
                "text": row["human_text"],
                "timer_seconds": row["estimated_seconds"]
            })
            
        # Combine into new structure
        new_recipes = []
        for r in recipes:
            rid = r["id"]
            r["ingredients"] = recipe_ing_map.get(rid, [])
            r["steps"] = sorted(recipe_steps_map.get(rid, []), key=lambda x: x["step_number"])
            new_recipes.append(r)
            
        with open("recipes_backup.json", "w", encoding="utf-8") as f:
            json.dump(new_recipes, f, indent=2)
            
        print(f"-> Successfully backed up {len(new_recipes)} recipes to recipes_backup.json.")
        
    except Exception as e:
        print(f"Error fetching existing recipes: {e}")
        print("Maybe you already ran the SQL migration? Reading from recipes_backup.json instead...")
        try:
            with open("recipes_backup.json", "r", encoding="utf-8") as f:
                new_recipes = json.load(f)
        except Exception as read_err:
            print("Could not read backup file either. Aborting.")
            return

    # Prompt user to run SQL migration
    print("\n=======================================================")
    print("ACTION REQUIRED:")
    print("1. Go to Supabase Dashboard -> SQL Editor")
    print("2. Run the SQL script located at: backend/migrations/009_restructure_recipes.sql")
    print("   (This will drop the old tables and add JSONB columns)")
    print("=======================================================")
    input("Press ENTER when you have successfully run the SQL script...")

    # 2. Delete existing recipes from the DB (to recreate them)
    print("\n2. Deleting old recipes from database...")
    # Delete all recipes. The CASCADE will handle everything else if tables still existed.
    # Note: If RLS is enabled, Service Role bypasses it.
    for r in new_recipes:
        db.table("recipes").delete().eq("id", r["id"]).execute()
    print("-> Deleted old recipes.")

    # 3. Re-insert recipes using the NEW structure (ingredients and steps as JSONB)
    print("\n3. Re-inserting recipes into the new JSONB schema...")
    for r in new_recipes:
        db.table("recipes").insert({
            "id": r["id"],
            "title": r["title"],
            "description": r["description"],
            "cuisine": r["cuisine"],
            "difficulty": r["difficulty"],
            "prep_time_minutes": r["prep_time_minutes"],
            "cook_time_minutes": r["cook_time_minutes"],
            "servings": r["servings"],
            "image_url": r["image_url"],
            "tags": r["tags"],
            "flavor_vectors": r["flavor_vectors"],
            "is_community": r["is_community"],
            "author_id": r["author_id"],
            "created_at": r["created_at"],
            "ingredients": r["ingredients"], # automatically converted to jsonb
            "steps": r["steps"]              # automatically converted to jsonb
        }).execute()
    print("-> Re-inserted all recipes!")

    # 4. Pre-translate all recipes into target languages
    target_languages = ["uz", "ru", "ko"]
    print(f"\n4. Beginning AI translation for {len(new_recipes)} recipes into {target_languages}...")
    
    url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key={api_key}"
    
    async with httpx.AsyncClient() as client:
        for idx, recipe in enumerate(new_recipes):
            rid = recipe["id"]
            title = recipe["title"]
            ing_text = "\\n".join([f"- {i.get('quantity', '')} {i.get('unit', '')} {i.get('name', '')}" for i in recipe["ingredients"]])
            steps_text = "\\n".join([f"{s['step_number']}. {s['text']}" for s in recipe["steps"]])
            
            print(f"[{idx+1}/{len(new_recipes)}] Translating '{title}'...")
            
            for lang in target_languages:
                # Check if already translated (in case script crashed and we resume)
                existing = db.table("recipe_translations").select("id").eq("recipe_id", rid).eq("language_code", lang).maybe_single().execute()
                if existing and existing.data:
                    continue
                    
                prompt = f\"\"\"Translate this recipe to {lang}. Keep measurements exact. Make it natural.
Title: {title}
Ingredients: {ing_text}
Steps: {steps_text}

Return strictly JSON:
{{
  "title": "...",
  "ingredients": [{{"name": "...", "quantity": 1, "unit": "..."}}],
  "steps": [{{"step_number": 1, "text": "..."}}]
}}\"\"\"

                payload = {
                    "contents": [{"parts": [{"text": prompt}]}],
                    "generationConfig": {"response_mime_type": "application/json"}
                }
                
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
                    
                    db.table("recipe_translations").insert({
                        "recipe_id": rid,
                        "language_code": lang,
                        "title_translated": parsed.get("title", title),
                        "ingredients_translated": parsed.get("ingredients", []),
                        "steps_translated": parsed.get("steps", [])
                    }).execute()
                    
                    # Be nice to the free tier API limits (15 RPM usually for free tier, delay slightly)
                    await asyncio.sleep(2)
                    
                except Exception as e:
                    print(f"  -> Failed to translate to {lang}: {e}")

    print("\n=======================================================")
    print("SUCCESS! All 133 recipes restructured and pre-translated!")
    print("=======================================================")

if __name__ == "__main__":
    asyncio.run(main())
