import asyncio
import sys
import json
import re

sys.path.insert(0, r'd:\dev\projects\iFridge\backend')
from dotenv import load_dotenv
load_dotenv(r'd:\dev\projects\iFridge\backend\.env')

from app.db.supabase_client import get_supabase
from app.services.ollama_service import get_ollama_service

async def main():
    print("==========================================================")
    print("  iFridge - Resuming Recipe Re-Generator (Local Ollama)   ")
    print("==========================================================")
    
    db = get_supabase()
    ollama = get_ollama_service()
    
    if not await ollama.is_available():
        print("ERROR: Local Ollama is not running! Please start Ollama first.")
        return

    # Fetch recipes that failed (ingredients is '[]' or null)
    resp = db.table("recipes").select("id, title, ingredients").execute()
    recipes = [r for r in resp.data if not r.get("ingredients") or str(r.get("ingredients")) == '[]']
    
    print(f"Found {len(recipes)} recipes that still need to be recreated.")
    
    system_prompt = "You are an expert chef. Return ONLY a valid JSON object without any explanations, markdown, or extra text."
    
    for idx, r in enumerate(recipes):
        rid = r["id"]
        title = r["title"]
        
        print(f"[{idx+1}/{len(recipes)}] Recreating '{title}'...")
        
        prompt = f"""Generate a professional, highly detailed recipe for '{title}'.
Requirements:
1. Provide exact ingredients with quantities.
2. Provide step-by-step cooking instructions.

You must reply with ONLY a raw JSON object matching this exact schema (no backticks, no markdown):
{{
  "ingredients": [
    {{ "name": "Flour", "quantity": 1.5, "unit": "cups", "prep_note": "Sifted" }}
  ],
  "steps": [
    {{ "step_number": 1, "text": "Preheat oven...", "timer_seconds": 600 }}
  ]
}}
"""
        
        retries = 3
        success = False
        
        for attempt in range(retries):
            try:
                # Use raw text generation so we can parse it more robustly
                raw_text = await ollama.generate_text(prompt, system_prompt=system_prompt, temperature=0.2)
                
                # Extract JSON block using regex
                match = re.search(r'\\{.*\\}', raw_text, re.DOTALL)
                if match:
                    json_str = match.group(0)
                else:
                    json_str = raw_text
                
                result = json.loads(json_str)
                
                ingredients = result.get("ingredients", [])
                steps = result.get("steps", [])
                
                if not ingredients or not steps:
                    print(f"  -> Attempt {attempt+1} generated empty data, retrying...")
                    continue
                    
                db.table("recipes").update({
                    "ingredients": ingredients,
                    "steps": steps
                }).eq("id", rid).execute()
                
                print(f"  -> Successfully updated '{title}'!")
                success = True
                break
                
            except json.JSONDecodeError as e:
                print(f"  -> Attempt {attempt+1} JSON error: {e}")
            except Exception as e:
                print(f"  -> Attempt {attempt+1} Exception: {e}")
                
        if not success:
            print(f"  -> Failed to recreate '{title}' after {retries} attempts.")
            
    print("\nResumption complete!")

if __name__ == "__main__":
    asyncio.run(main())
