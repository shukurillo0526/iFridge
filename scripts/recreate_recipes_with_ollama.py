import asyncio
import sys
import json

sys.path.insert(0, r'd:\dev\projects\iFridge\backend')
from dotenv import load_dotenv
load_dotenv(r'd:\dev\projects\iFridge\backend\.env')

from app.db.supabase_client import get_supabase
from app.services.ollama_service import get_ollama_service

async def main():
    print("==========================================================")
    print("  iFridge - Automated Recipe Re-Generator (Local Ollama)  ")
    print("==========================================================")
    
    db = get_supabase()
    ollama = get_ollama_service()
    
    if not await ollama.is_available():
        print("ERROR: Local Ollama is not running! Please start Ollama first.")
        return

    # 1. Fetch all recipes
    print("Fetching all recipes from database...")
    resp = db.table("recipes").select("id, title").execute()
    recipes = resp.data
    
    print(f"Found {len(recipes)} recipes to recreate.")
    
    system_prompt = "You are an expert chef. Generate detailed, exact, step-by-step instructions. Return ONLY valid JSON."
    
    # Process sequentially
    for idx, r in enumerate(recipes):
        rid = r["id"]
        title = r["title"]
        
        # Check if already processed (e.g. if script was interrupted)
        # We can check if steps array has more than 1 item and has detailed text. 
        # But to be safe, we'll just process everything. If user wants to resume, they can modify this.
        
        print(f"[{idx+1}/{len(recipes)}] Recreating '{title}'...")
        
        prompt = f"""Generate a professional, highly detailed recipe for '{title}'.
Requirements:
1. Provide exact, specific ingredients with precise quantities.
2. Provide long, detailed, step-by-step cooking instructions.
3. Include timer_seconds for any step that involves waiting (boiling, baking, etc).

Return strictly JSON in this format:
{{
  "ingredients": [
    {{ "name": "...", "quantity": 1.5, "unit": "cups", "prep_note": "..." }}
  ],
  "steps": [
    {{ "step_number": 1, "text": "...", "timer_seconds": 600 }}
  ]
}}"""
        
        try:
            result = await ollama.generate_text_json(prompt, system_prompt=system_prompt)
            
            if "error" in result:
                print(f"  -> Error generating {title}: {result['error']}")
                continue
                
            ingredients = result.get("ingredients", [])
            steps = result.get("steps", [])
            
            if not ingredients or not steps:
                print(f"  -> Warning: Generated empty data for {title}")
                continue
                
            # Update database with new rich JSON structure
            db.table("recipes").update({
                "ingredients": ingredients,
                "steps": steps
            }).eq("id", rid).execute()
            
            print(f"  -> Successfully updated '{title}' with {len(ingredients)} ingredients and {len(steps)} steps.")
            
        except Exception as e:
            print(f"  -> Exception while processing '{title}': {e}")
            
    print("\nAll recipes have been recreated successfully using Local AI!")

if __name__ == "__main__":
    asyncio.run(main())
