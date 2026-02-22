import pandas as pd
import ast
import os
import time
from dotenv import load_dotenv
from supabase import create_client, Client

# Load environment variables (ensure .env has SUPABASE_URL and SUPABASE_KEY)
load_dotenv()

URL = os.environ.get("SUPABASE_URL")
KEY = os.environ.get("SUPABASE_KEY")

if not URL or not KEY:
    raise ValueError("Missing Supabase credentials in .env")

supabase: Client = create_client(URL, KEY)

def clean_value(val):
    if pd.isna(val):
        return None
    return str(val).strip()

def process_batch(df_chunk, start_idx):
    print(f"Processing chunk from index {start_idx}...")
    
    for i, row in df_chunk.iterrows():
        try:
            # 1. Parse lists safely
            tags = ast.literal_eval(row['tags']) if isinstance(row['tags'], str) else []
            ingredients = ast.literal_eval(row['ingredients']) if isinstance(row['ingredients'], str) else []
            steps = ast.literal_eval(row['steps']) if isinstance(row['steps'], str) else []
            
            # Simple heuristic for difficulty and prep time
            prep_time = int(row['minutes']) if pd.notna(row['minutes']) else 30
            difficulty = 1
            if prep_time > 30 and len(steps) > 5:
                difficulty = 2
            if prep_time > 60 and len(steps) > 10:
                difficulty = 3

            # 2. Insert Recipe
            recipe_data = {
                'title': clean_value(row['name']).title() if pd.notna(row['name']) else "Untitled Recipe",
                'description': clean_value(row['description']) or "No description provided.",
                'prep_time_minutes': prep_time,
                'cook_time_minutes': 0, # Unspecified in Food.com usually
                'servings': 2,
                'difficulty': difficulty,
                'cuisine': tags[0] if tags and len(tags) > 0 else 'Global',
                'tags': tags[:5], # Only store top 5 for cleaner UX
            }

            recipe_res = supabase.table('recipes').insert(recipe_data).execute()
            
            if not recipe_res.data:
                continue
                
            recipe_id = recipe_res.data[0]['id']

            # 3. Process Ingredients
            # Upsert into master_ingredients then link to recipe_ingredients
            for ing_raw in ingredients:
                ing_name = ing_raw.title().strip()
                
                # Check if it exists in master_ingredients
                master_res = supabase.table('master_ingredients').select('id').eq('display_name_en', ing_name).execute()
                
                ing_id = None
                if master_res.data:
                    ing_id = master_res.data[0]['id']
                else:
                    # Insert new master ingredient
                    new_ing = {
                        'display_name_en': ing_name,
                        'category': 'Pantry' # generic fallback
                    }
                    ins_res = supabase.table('master_ingredients').insert(new_ing).execute()
                    if ins_res.data:
                        ing_id = ins_res.data[0]['id']
                        
                if ing_id:
                    # Link it to the recipe
                    ri_data = {
                        'recipe_id': recipe_id,
                        'ingredient_id': ing_id,
                        'quantity': 1, # Default placeholder
                        'unit': 'serving', # Default placeholder
                        'is_optional': False
                    }
                    supabase.table('recipe_ingredients').insert(ri_data).execute()
                    
            print(f"[{i}] Migrated: {recipe_data['title']}")
            
        except Exception as e:
            print(f"Error on row {i}: {e}")

def run_etl(csv_path: str, chunk_size=50):
    print(f"Starting ETL pipeline for {csv_path}")
    
    # Using chunksize to not overload memory or Supabase free-tier connections
    chunk_iterator = pd.read_csv(csv_path, chunksize=chunk_size)
    
    start_idx = 0
    for chunk in chunk_iterator:
        process_batch(chunk, start_idx)
        start_idx += chunk_size
        time.sleep(1) # Simple rate limiting

if __name__ == "__main__":
    import sys
    if len(sys.argv) < 2:
        print("Usage: python etl_foodcom.py <path_to_RAW_recipes.csv>")
    else:
        run_etl(sys.argv[1])
