"""Verify the full pipeline: ingredients -> recipe_ingredients -> recommendations."""
from app.db.supabase_client import get_supabase

db = get_supabase()

# 1. Summary stats
ings = db.table("ingredients").select("id", count="exact").execute()
ri = db.table("recipe_ingredients").select("id", count="exact").execute()
recipes = db.table("recipes").select("id", count="exact").execute()

print("=== SYSTEM STATUS ===")
print(f"  Canonical ingredients: {ings.count}")
print(f"  Recipes: {recipes.count}")
print(f"  Recipe-Ingredient links: {ri.count}")
print(f"  Avg ingredients/recipe: {ri.count / recipes.count:.1f}")

# 2. Check a sample recipe's relational ingredients
sample = db.table("recipes").select("id, title").limit(1).execute()
if sample.data:
    r = sample.data[0]
    linked = (
        db.table("recipe_ingredients")
        .select("quantity, unit, prep_note, ingredients(canonical_name, display_name_en, display_name_uz, display_name_ru)")
        .eq("recipe_id", r["id"])
        .execute()
    )
    print(f"\n=== Sample: {r['title']} ({len(linked.data)} ingredients) ===")
    for item in linked.data:
        ing = item.get("ingredients", {})
        print(f"  {item.get('quantity', '')} {item.get('unit', '')} {ing.get('display_name_en', '?')} | UZ: {ing.get('display_name_uz', '?')} | RU: {ing.get('display_name_ru', '?')}")

# 3. Translation coverage check
has_uz = db.table("ingredients").select("id", count="exact").neq("display_name_uz", "").execute()
has_ru = db.table("ingredients").select("id", count="exact").neq("display_name_ru", "").execute()
has_ko = db.table("ingredients").select("id", count="exact").neq("display_name_ko", "").execute()

print(f"\n=== TRANSLATION COVERAGE ===")
print(f"  Korean:  {has_ko.count}/{ings.count}")
print(f"  Uzbek:   {has_uz.count}/{ings.count}")
print(f"  Russian: {has_ru.count}/{ings.count}")
