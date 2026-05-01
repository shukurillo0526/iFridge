"""
iFridge — Recipe Seed Runner
Loads JSON batch files and updates Supabase recipes with rich JSONB data.
"""
import sys, json, os, glob

sys.path.insert(0, r'd:\dev\projects\iFridge\backend')
from dotenv import load_dotenv
load_dotenv(r'd:\dev\projects\iFridge\backend\.env')
from app.db.supabase_client import get_supabase

def main():
    db = get_supabase()
    batch_dir = os.path.join(os.path.dirname(__file__), "recipe_batches")
    files = sorted(glob.glob(os.path.join(batch_dir, "batch_*.json")))

    if not files:
        print("No batch files found in scripts/recipe_batches/")
        return

    # Build title->id map
    rows = db.table("recipes").select("id, title").execute().data
    title_map = {r["title"]: r["id"] for r in rows}
    print(f"Loaded {len(title_map)} recipes from DB.\n")

    total, updated, skipped = 0, 0, 0
    for f in files:
        print(f"Processing {os.path.basename(f)}...")
        with open(f, "r", encoding="utf-8") as fh:
            recipes = json.load(fh)
        for r in recipes:
            total += 1
            title = r["title"]
            rid = title_map.get(title)
            if not rid:
                print(f"  SKIP (not in DB): {title}")
                skipped += 1
                continue
            db.table("recipes").update({
                "ingredients": r["ingredients"],
                "steps": r["steps"]
            }).eq("id", rid).execute()
            print(f"  OK: {title}")
            updated += 1

    print(f"\nDone! Updated: {updated}, Skipped: {skipped}, Total: {total}")

if __name__ == "__main__":
    main()
