-- ============================================================
-- Plately — Migration 014: Ingredient Indexing & Provenance
-- ============================================================
-- Phase 1: Add integer code (human-readable index)
-- Phase 2: Add provenance tracking (source, verified, created_by)
-- Phase 3: Add nutrition columns (protein, fat, carbs)
-- Phase 4: Backfill sub_category for older ingredients
-- ============================================================

-- ────────────────────────────────────────────────────────────
-- PHASE 1: Integer Code Index
-- ────────────────────────────────────────────────────────────

-- Add a sequential integer code for human-readable reference.
-- UUIDs remain the primary key and foreign key target.
ALTER TABLE public.ingredients
    ADD COLUMN IF NOT EXISTS code SERIAL;

-- Backfill codes alphabetically by canonical_name so ordering is stable.
-- This assigns 1..N to all existing rows.
WITH numbered AS (
    SELECT id, ROW_NUMBER() OVER (ORDER BY canonical_name ASC) AS rn
    FROM public.ingredients
)
UPDATE public.ingredients i
SET code = n.rn
FROM numbered n
WHERE i.id = n.id;

-- Make code unique and not null going forward
ALTER TABLE public.ingredients
    ALTER COLUMN code SET NOT NULL;

ALTER TABLE public.ingredients
    ADD CONSTRAINT uq_ingredients_code UNIQUE (code);

-- Create index for fast lookups by code
CREATE INDEX IF NOT EXISTS idx_ingredients_code ON public.ingredients(code);


-- ────────────────────────────────────────────────────────────
-- PHASE 2: Provenance Tracking
-- ────────────────────────────────────────────────────────────

-- source: 'canonical' (our curated 319) or 'user_contributed' (user-created)
ALTER TABLE public.ingredients
    ADD COLUMN IF NOT EXISTS source TEXT NOT NULL DEFAULT 'canonical';

-- verified: true for canonical ingredients, false for auto-created ones
ALTER TABLE public.ingredients
    ADD COLUMN IF NOT EXISTS verified BOOLEAN NOT NULL DEFAULT TRUE;

-- created_by: NULL for canonical, user UUID for user-contributed
ALTER TABLE public.ingredients
    ADD COLUMN IF NOT EXISTS created_by UUID REFERENCES public.users(id) ON DELETE SET NULL;


-- ────────────────────────────────────────────────────────────
-- PHASE 3: Nutrition Columns (nullable, populated later)
-- ────────────────────────────────────────────────────────────

-- calories_per_100g already exists from migration 011, skip it
-- Add macronutrient columns
ALTER TABLE public.ingredients
    ADD COLUMN IF NOT EXISTS protein_per_100g NUMERIC(6,2);

ALTER TABLE public.ingredients
    ADD COLUMN IF NOT EXISTS fat_per_100g NUMERIC(6,2);

ALTER TABLE public.ingredients
    ADD COLUMN IF NOT EXISTS carbs_per_100g NUMERIC(6,2);


-- ────────────────────────────────────────────────────────────
-- PHASE 4: Backfill sub_category for older ingredients
-- ────────────────────────────────────────────────────────────
-- Many ingredients from the original seed and early migrations
-- have sub_category = NULL. Fill them with sensible defaults.

UPDATE public.ingredients SET sub_category = 'milk'         WHERE canonical_name = 'whole_milk'       AND sub_category IS NULL;
UPDATE public.ingredients SET sub_category = 'pome'         WHERE canonical_name = 'fuji_apple'       AND sub_category IS NULL;
UPDATE public.ingredients SET sub_category = 'poultry'      WHERE canonical_name = 'chicken_breast'   AND sub_category IS NULL;
UPDATE public.ingredients SET sub_category = 'egg'          WHERE canonical_name = 'egg'              AND sub_category IS NULL;
UPDATE public.ingredients SET sub_category = 'leafy_green'  WHERE canonical_name = 'spinach'          AND sub_category IS NULL;
UPDATE public.ingredients SET sub_category = 'root'         WHERE canonical_name = 'carrot'           AND sub_category IS NULL;
UPDATE public.ingredients SET sub_category = 'sauce'        WHERE canonical_name = 'soy_sauce'        AND sub_category IS NULL;
UPDATE public.ingredients SET sub_category = 'root'         WHERE canonical_name = 'ginger'           AND sub_category IS NULL;
UPDATE public.ingredients SET sub_category = 'nightshade'   WHERE canonical_name = 'bell_pepper'      AND sub_category IS NULL;
UPDATE public.ingredients SET sub_category = 'dumpling'     WHERE canonical_name = 'frozen_dumplings' AND sub_category IS NULL;

-- ── Proteins ──
UPDATE public.ingredients SET sub_category = 'poultry'      WHERE canonical_name IN ('chicken_thigh', 'chicken_wing', 'chicken_whole') AND sub_category IS NULL;
UPDATE public.ingredients SET sub_category = 'red_meat'     WHERE canonical_name IN ('beef', 'ground_beef', 'beef_brisket', 'pork', 'pork_belly', 'ground_pork') AND sub_category IS NULL;
UPDATE public.ingredients SET sub_category = 'fish'         WHERE canonical_name IN ('salmon', 'tuna', 'cod', 'shrimp', 'squid', 'clam', 'mussel', 'crab', 'mackerel', 'anchovy', 'sardine') AND sub_category IS NULL;
UPDATE public.ingredients SET sub_category = 'processed'    WHERE canonical_name IN ('bacon', 'sausage', 'ham', 'hot_dog', 'spam') AND sub_category IS NULL;
UPDATE public.ingredients SET sub_category = 'plant'        WHERE canonical_name IN ('tofu', 'firm_tofu', 'silken_tofu') AND sub_category IS NULL;

-- ── Dairy ──
UPDATE public.ingredients SET sub_category = 'cheese'       WHERE canonical_name IN ('cheddar', 'mozzarella', 'parmesan', 'cream_cheese', 'feta', 'gruyere', 'swiss_cheese', 'blue_cheese', 'brie', 'provolone', 'american_cheese', 'cottage_cheese') AND sub_category IS NULL;
UPDATE public.ingredients SET sub_category = 'milk'         WHERE canonical_name IN ('milk', 'skim_milk', 'almond_milk', 'oat_milk', 'soy_milk', 'evaporated_milk', 'condensed_milk') AND sub_category IS NULL;
UPDATE public.ingredients SET sub_category = 'cream'        WHERE canonical_name IN ('sour_cream', 'whipping_cream', 'half_and_half') AND sub_category IS NULL;
UPDATE public.ingredients SET sub_category = 'fermented'    WHERE canonical_name IN ('yogurt', 'greek_yogurt', 'plain_yogurt') AND sub_category IS NULL;
UPDATE public.ingredients SET sub_category = 'butter'       WHERE canonical_name IN ('butter', 'unsalted_butter', 'ghee', 'margarine') AND sub_category IS NULL;

-- ── Vegetables ──
UPDATE public.ingredients SET sub_category = 'root'         WHERE canonical_name IN ('potato', 'onion', 'garlic', 'radish', 'beet', 'parsnip', 'celery_root') AND sub_category IS NULL;
UPDATE public.ingredients SET sub_category = 'leafy_green'  WHERE canonical_name IN ('lettuce', 'cabbage', 'arugula', 'romaine', 'spring_onion', 'chive', 'cilantro', 'parsley', 'basil', 'mint', 'dill', 'thyme', 'rosemary', 'oregano', 'bay_leaf') AND sub_category IS NULL;
UPDATE public.ingredients SET sub_category = 'nightshade'   WHERE canonical_name IN ('tomato', 'eggplant', 'zucchini', 'chili_pepper', 'green_pepper', 'red_pepper') AND sub_category IS NULL;
UPDATE public.ingredients SET sub_category = 'cruciferous'  WHERE canonical_name IN ('broccoli', 'cauliflower', 'cabbage_napa') AND sub_category IS NULL;
UPDATE public.ingredients SET sub_category = 'allium'       WHERE canonical_name IN ('onion', 'garlic', 'green_onion') AND sub_category IS NULL;
UPDATE public.ingredients SET sub_category = 'gourd'        WHERE canonical_name IN ('cucumber', 'pumpkin', 'squash', 'butternut_squash') AND sub_category IS NULL;
UPDATE public.ingredients SET sub_category = 'legume'       WHERE canonical_name IN ('green_bean', 'pea', 'snow_pea', 'edamame') AND sub_category IS NULL;
UPDATE public.ingredients SET sub_category = 'mushroom'     WHERE canonical_name IN ('mushroom', 'shiitake', 'enoki', 'oyster_mushroom', 'king_oyster_mushroom', 'portobello') AND sub_category IS NULL;
UPDATE public.ingredients SET sub_category = 'corn'         WHERE canonical_name IN ('corn', 'corn_kernel', 'baby_corn') AND sub_category IS NULL;

-- ── Fruits ──
UPDATE public.ingredients SET sub_category = 'citrus'       WHERE canonical_name IN ('lemon', 'lime', 'orange', 'grapefruit', 'mandarin', 'yuzu') AND sub_category IS NULL;
UPDATE public.ingredients SET sub_category = 'berry'        WHERE canonical_name IN ('strawberry', 'blueberry', 'raspberry', 'blackberry', 'cranberry') AND sub_category IS NULL;
UPDATE public.ingredients SET sub_category = 'tropical'     WHERE canonical_name IN ('banana', 'mango', 'pineapple', 'papaya', 'coconut', 'passion_fruit', 'kiwi') AND sub_category IS NULL;
UPDATE public.ingredients SET sub_category = 'stone'        WHERE canonical_name IN ('peach', 'plum', 'cherry', 'apricot', 'nectarine') AND sub_category IS NULL;
UPDATE public.ingredients SET sub_category = 'melon'        WHERE canonical_name IN ('watermelon', 'cantaloupe', 'honeydew') AND sub_category IS NULL;
UPDATE public.ingredients SET sub_category = 'pome'         WHERE canonical_name IN ('apple', 'pear', 'grape') AND sub_category IS NULL;

-- ── Grains ──
UPDATE public.ingredients SET sub_category = 'rice'         WHERE canonical_name IN ('rice', 'white_rice', 'brown_rice', 'jasmine_rice', 'sushi_rice', 'sticky_rice', 'rice_flour') AND sub_category IS NULL;
UPDATE public.ingredients SET sub_category = 'pasta'        WHERE canonical_name IN ('pasta', 'spaghetti', 'penne', 'macaroni', 'linguine', 'fettuccine', 'lasagna_sheets', 'ramen_noodles', 'udon', 'soba', 'vermicelli', 'egg_noodle') AND sub_category IS NULL;
UPDATE public.ingredients SET sub_category = 'bread'        WHERE canonical_name IN ('bread', 'white_bread', 'sourdough', 'pita', 'tortilla', 'baguette', 'ciabatta', 'brioche', 'breadcrumbs', 'panko') AND sub_category IS NULL;
UPDATE public.ingredients SET sub_category = 'flour'        WHERE canonical_name IN ('flour', 'all_purpose_flour', 'bread_flour', 'whole_wheat_flour', 'cake_flour', 'cornstarch') AND sub_category IS NULL;
UPDATE public.ingredients SET sub_category = 'cereal'       WHERE canonical_name IN ('oats', 'rolled_oats', 'granola', 'cereal') AND sub_category IS NULL;

-- ── Seasonings & Condiments ──
UPDATE public.ingredients SET sub_category = 'spice'        WHERE canonical_name IN ('salt', 'black_pepper', 'white_pepper', 'paprika', 'cayenne', 'chili_flakes', 'cinnamon', 'nutmeg', 'clove', 'cardamom', 'coriander_seed', 'cumin', 'turmeric', 'curry_powder', 'garam_masala', 'five_spice', 'star_anise', 'saffron', 'vanilla', 'vanilla_extract') AND sub_category IS NULL;
UPDATE public.ingredients SET sub_category = 'sauce'        WHERE canonical_name IN ('fish_sauce', 'oyster_sauce', 'hoisin_sauce', 'sriracha', 'hot_sauce', 'ketchup', 'mayonnaise', 'mustard', 'bbq_sauce', 'teriyaki_sauce', 'tomato_sauce', 'marinara', 'salsa') AND sub_category IS NULL;
UPDATE public.ingredients SET sub_category = 'paste'        WHERE canonical_name IN ('gochujang', 'doenjang', 'tomato_paste', 'curry_paste', 'wasabi') AND sub_category IS NULL;
UPDATE public.ingredients SET sub_category = 'vinegar'      WHERE canonical_name IN ('vinegar', 'rice_vinegar', 'balsamic_vinegar', 'apple_cider_vinegar', 'white_vinegar') AND sub_category IS NULL;

-- ── Oils ──
UPDATE public.ingredients SET sub_category = 'cooking_oil'  WHERE canonical_name IN ('olive_oil', 'vegetable_oil', 'canola_oil', 'sunflower_oil', 'coconut_oil', 'sesame_oil', 'avocado_oil', 'peanut_oil') AND sub_category IS NULL;

-- ── Baking ──
UPDATE public.ingredients SET sub_category = 'sweetener'    WHERE canonical_name IN ('sugar', 'brown_sugar', 'powdered_sugar', 'honey') AND sub_category IS NULL;
UPDATE public.ingredients SET sub_category = 'leavening'    WHERE canonical_name IN ('baking_powder', 'baking_soda', 'yeast') AND sub_category IS NULL;
UPDATE public.ingredients SET sub_category = 'chocolate'    WHERE canonical_name IN ('chocolate', 'dark_chocolate', 'cocoa_powder', 'chocolate_chips', 'white_chocolate') AND sub_category IS NULL;

-- ── Nuts ──
UPDATE public.ingredients SET sub_category = 'tree_nut'     WHERE canonical_name IN ('almond', 'walnut', 'cashew', 'pecan', 'pistachio', 'hazelnut', 'macadamia') AND sub_category IS NULL;
UPDATE public.ingredients SET sub_category = 'seed'         WHERE canonical_name IN ('sesame_seed', 'sunflower_seed', 'flax_seed', 'chia_seed', 'pumpkin_seed') AND sub_category IS NULL;
UPDATE public.ingredients SET sub_category = 'legume_nut'   WHERE canonical_name IN ('peanut', 'peanut_butter') AND sub_category IS NULL;

-- ── Catch-all: anything still NULL gets 'general' ──
UPDATE public.ingredients SET sub_category = 'general' WHERE sub_category IS NULL;


-- ────────────────────────────────────────────────────────────
-- VERIFICATION QUERIES (run to confirm)
-- ────────────────────────────────────────────────────────────
-- SELECT code, canonical_name, category, sub_category, source
-- FROM public.ingredients
-- ORDER BY code
-- LIMIT 30;
--
-- SELECT COUNT(*) AS total,
--        COUNT(sub_category) AS has_sub,
--        COUNT(*) - COUNT(sub_category) AS missing_sub
-- FROM public.ingredients;
