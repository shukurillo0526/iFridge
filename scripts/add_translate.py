import os
import re

path = r'd:\dev\projects\iFridge\backend\app\routers\recipe_ai.py'
with open(path, 'r', encoding='utf-8') as f: content = f.read()

models = """class ShoppingListRequest(BaseModel):
    user_id: str
    recipe_ids: List[str]  # recipes the user wants to cook

class TranslateRecipeRequest(BaseModel):
    title: str
    ingredients: str
    steps: str
    target_language: str"""

content = content.replace(
    "class ShoppingListRequest(BaseModel):\n    user_id: str\n    recipe_ids: List[str]  # recipes the user wants to cook",
    models
)

endpoint = """import httpx

@router.post("/api/v1/ai/translate-recipe")
async def translate_recipe(req: TranslateRecipeRequest):
    \"\"\"
    Translate a recipe using Gemini 1.5 Flash.
    Fast and cheap translation.
    \"\"\"
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
            # It might have markdown json blocks, clean it
            if text_response.startswith("```json"):
                text_response = text_response.strip("```json").strip("```").strip()
            elif text_response.startswith("```"):
                text_response = text_response.strip("```").strip()
                
            return {
                "status": "success",
                "source": "gemini-1.5-flash",
                "data": json.loads(text_response)
            }
        except Exception as e:
            logger.error(f"[TranslateRecipe] Translation failed: {e}")
            raise HTTPException(status_code=500, detail=str(e))
"""

if "import httpx" not in content:
    content = content.replace("import logging", "import logging\nimport httpx\nimport os")

# Insert before ShoppingList
content = content.replace(
    "@router.post(\"/api/v1/ai/shopping-list\")",
    endpoint + "\n\n@router.post(\"/api/v1/ai/shopping-list\")"
)

with open(path, 'w', encoding='utf-8') as f: f.write(content)
print("Updated backend recipe_ai.py!")
