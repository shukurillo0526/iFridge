-- ============================================================
-- I-Fridge — Additional Seed Data (Phase 4b)
-- ============================================================
-- Run AFTER seed_data.sql in Supabase SQL Editor.
-- Adds 12 new ingredients and 15 recipes designed to produce
-- at least 3 recipes per tier when matched against the demo
-- user's 7 inventory items.
-- ============================================================

DO $$
DECLARE
    v_demo_user_id UUID := '00000000-0000-4000-8000-000000000001';

    -- Existing ingredient IDs (looked up from canonical_name)
    v_milk_id       UUID;
    v_apple_id      UUID;
    v_chicken_id    UUID;
    v_egg_id        UUID;
    v_spinach_id    UUID;
    v_carrot_id     UUID;
    v_soy_id        UUID;
    v_ginger_id     UUID;
    v_pepper_id     UUID;
    v_dumpling_id   UUID;

    -- New ingredient IDs
    v_garlic_id     UUID;
    v_onion_id      UUID;
    v_butter_id     UUID;
    v_flour_id      UUID;
    v_sugar_id      UUID;
    v_olive_oil_id  UUID;
    v_tomato_id     UUID;
    v_broccoli_id   UUID;
    v_cheese_id     UUID;
    v_rice_id       UUID;
    v_tofu_id       UUID;
    v_banana_id     UUID;

    -- Recipe IDs
    v_r1  UUID;  v_r2  UUID;  v_r3  UUID;  v_r4  UUID;  v_r5  UUID;
    v_r6  UUID;  v_r7  UUID;  v_r8  UUID;  v_r9  UUID;  v_r10 UUID;
    v_r11 UUID;  v_r12 UUID;  v_r13 UUID;  v_r14 UUID;  v_r15 UUID;

BEGIN

-- ── 1. Add New Ingredients ─────────────────────────────────────

INSERT INTO public.ingredients (canonical_name, display_name_en, display_name_ko, category, sub_category, default_unit, sealed_shelf_life_days, opened_shelf_life_days, storage_zone) VALUES
('garlic',           'Garlic',           '마늘',      'vegetable', 'allium',       'piece', 60,  30, 'pantry'),
('yellow_onion',     'Yellow Onion',     '양파',      'vegetable', 'allium',       'piece', 30,  14, 'pantry'),
('unsalted_butter',  'Unsalted Butter',  '무염 버터',  'dairy',     'butter',       'g',     60,  14, 'fridge'),
('all_purpose_flour','All-Purpose Flour','밀가루',     'grain',     'flour',        'g',     365, 180,'pantry'),
('granulated_sugar', 'Granulated Sugar', '설탕',      'seasoning', 'sweetener',    'g',     730, 365,'pantry'),
('olive_oil',        'Olive Oil',        '올리브유',   'fat',       'oil',          'ml',    365, 180,'pantry'),
('tomato',           'Tomato',           '토마토',     'vegetable', 'nightshade',   'piece', 7,   3,  'fridge'),
('broccoli',         'Broccoli',         '브로콜리',   'vegetable', 'cruciferous',  'piece', 7,   3,  'fridge'),
('cheddar_cheese',   'Cheddar Cheese',   '체더 치즈',  'dairy',     'cheese',       'g',     60,  14, 'fridge'),
('jasmine_rice',     'Jasmine Rice',     '자스민 쌀',  'grain',     'rice',         'g',     365, 365,'pantry'),
('firm_tofu',        'Firm Tofu',        '두부',      'protein',   'soy',          'g',     7,   3,  'fridge'),
('banana',           'Banana',           '바나나',     'fruit',     'tropical',     'piece', 7,   3,  'fridge')
ON CONFLICT (canonical_name) DO NOTHING;

-- ── 2. Look Up All Ingredient IDs ──────────────────────────────

-- Existing
SELECT id INTO v_milk_id      FROM public.ingredients WHERE canonical_name = 'whole_milk';
SELECT id INTO v_apple_id     FROM public.ingredients WHERE canonical_name = 'fuji_apple';
SELECT id INTO v_chicken_id   FROM public.ingredients WHERE canonical_name = 'chicken_breast';
SELECT id INTO v_egg_id       FROM public.ingredients WHERE canonical_name = 'egg';
SELECT id INTO v_spinach_id   FROM public.ingredients WHERE canonical_name = 'spinach';
SELECT id INTO v_carrot_id    FROM public.ingredients WHERE canonical_name = 'carrot';
SELECT id INTO v_soy_id       FROM public.ingredients WHERE canonical_name = 'soy_sauce';
SELECT id INTO v_ginger_id    FROM public.ingredients WHERE canonical_name = 'ginger';
SELECT id INTO v_pepper_id    FROM public.ingredients WHERE canonical_name = 'bell_pepper';
SELECT id INTO v_dumpling_id  FROM public.ingredients WHERE canonical_name = 'frozen_dumplings';

-- New
SELECT id INTO v_garlic_id    FROM public.ingredients WHERE canonical_name = 'garlic';
SELECT id INTO v_onion_id     FROM public.ingredients WHERE canonical_name = 'yellow_onion';
SELECT id INTO v_butter_id    FROM public.ingredients WHERE canonical_name = 'unsalted_butter';
SELECT id INTO v_flour_id     FROM public.ingredients WHERE canonical_name = 'all_purpose_flour';
SELECT id INTO v_sugar_id     FROM public.ingredients WHERE canonical_name = 'granulated_sugar';
SELECT id INTO v_olive_oil_id FROM public.ingredients WHERE canonical_name = 'olive_oil';
SELECT id INTO v_tomato_id    FROM public.ingredients WHERE canonical_name = 'tomato';
SELECT id INTO v_broccoli_id  FROM public.ingredients WHERE canonical_name = 'broccoli';
SELECT id INTO v_cheese_id    FROM public.ingredients WHERE canonical_name = 'cheddar_cheese';
SELECT id INTO v_rice_id      FROM public.ingredients WHERE canonical_name = 'jasmine_rice';
SELECT id INTO v_tofu_id      FROM public.ingredients WHERE canonical_name = 'firm_tofu';
SELECT id INTO v_banana_id    FROM public.ingredients WHERE canonical_name = 'banana';

-- ── 3. Generate Recipe UUIDs ───────────────────────────────────

v_r1  := gen_random_uuid();  v_r2  := gen_random_uuid();  v_r3  := gen_random_uuid();
v_r4  := gen_random_uuid();  v_r5  := gen_random_uuid();  v_r6  := gen_random_uuid();
v_r7  := gen_random_uuid();  v_r8  := gen_random_uuid();  v_r9  := gen_random_uuid();
v_r10 := gen_random_uuid();  v_r11 := gen_random_uuid();  v_r12 := gen_random_uuid();
v_r13 := gen_random_uuid();  v_r14 := gen_random_uuid();  v_r15 := gen_random_uuid();

-- ============================================================
-- TIER 1 — PERFECT (100% match)
-- Uses ONLY: milk, apple, chicken, eggs, spinach, dumplings, soy_sauce
-- ============================================================

INSERT INTO public.recipes (id, title, description, cuisine, difficulty, prep_time_minutes, cook_time_minutes, servings, tags, flavor_vectors) VALUES
    (v_r1, 'Soy-Glazed Chicken Bites',
     'Pan-seared chicken pieces glazed with soy sauce, simple and flavorful.',
     'Korean', 1, 5, 12, 2,
     ARRAY['quick', 'protein', 'easy'],
     '{"umami": 0.9, "salty": 0.7, "sweet": 0.1}'::JSONB),

    (v_r2, 'Creamy Spinach Egg Bowl',
     'Soft scrambled eggs with wilted spinach and a splash of warm milk.',
     'American', 1, 3, 8, 1,
     ARRAY['breakfast', 'easy', 'healthy'],
     '{"umami": 0.4, "salty": 0.3, "sweet": 0.2}'::JSONB),

    (v_r3, 'Chicken Dumpling Hot Pot',
     'Hearty pot of dumplings and chicken simmered in soy broth with egg ribbons.',
     'Korean', 2, 5, 20, 2,
     ARRAY['comfort', 'soup', 'one-pot'],
     '{"umami": 0.9, "salty": 0.6, "sweet": 0.1, "spicy": 0.2}'::JSONB);

-- ============================================================
-- TIER 2 — DISCOVER (80–99% match = 4/5 owned)
-- Each has 5 required ingredients, 4 owned + 1 not-owned
-- ============================================================

INSERT INTO public.recipes (id, title, description, cuisine, difficulty, prep_time_minutes, cook_time_minutes, servings, tags, flavor_vectors) VALUES
    (v_r4, 'Chicken Fried Rice',
     'Classic fried rice with chicken, egg, soy sauce, spinach, and jasmine rice.',
     'Asian', 2, 10, 12, 2,
     ARRAY['fried-rice', 'one-pan', 'filling'],
     '{"umami": 0.8, "salty": 0.6, "sweet": 0.2}'::JSONB),

    (v_r5, 'Teriyaki Chicken Bowl',
     'Soy-glazed chicken over greens with a soft egg, accented with fresh ginger.',
     'Japanese', 2, 10, 15, 2,
     ARRAY['bowl', 'teriyaki', 'protein'],
     '{"umami": 0.9, "sweet": 0.5, "salty": 0.7}'::JSONB),

    (v_r6, 'Spinach Chicken Milk Soup',
     'Comforting creamy soup with chicken, spinach, egg, and garlic.',
     'Fusion', 2, 10, 20, 2,
     ARRAY['soup', 'creamy', 'comfort'],
     '{"umami": 0.6, "salty": 0.4, "sweet": 0.3}'::JSONB);

-- ============================================================
-- TIER 3 — ALMOST (60–79% match = 3/5 owned)
-- Each has 5 required, 3 owned + 2 not-owned
-- ============================================================

INSERT INTO public.recipes (id, title, description, cuisine, difficulty, prep_time_minutes, cook_time_minutes, servings, tags, flavor_vectors) VALUES
    (v_r7, 'Chicken Apple Waldorf',
     'Crispy chicken and Fuji apple salad with spinach, onion, and olive oil dressing.',
     'American', 2, 15, 0, 2,
     ARRAY['salad', 'fresh', 'light'],
     '{"sweet": 0.5, "sour": 0.3, "umami": 0.3}'::JSONB),

    (v_r8, 'Creamy Spinach Frittata',
     'Baked egg frittata with spinach, milk, cheddar cheese, and butter.',
     'Italian', 2, 10, 20, 3,
     ARRAY['brunch', 'baked', 'cheesy'],
     '{"umami": 0.6, "salty": 0.5, "sweet": 0.2}'::JSONB),

    (v_r9, 'Egg Vegetable Stir-Fry',
     'Quick wok-fried eggs with soy sauce, spinach, bell pepper, and broccoli.',
     'Asian', 1, 5, 10, 2,
     ARRAY['quick', 'veggie', 'stir-fry'],
     '{"umami": 0.7, "salty": 0.5, "sweet": 0.1}'::JSONB);

-- ============================================================
-- TIER 4 — TRY (40–59% match = 2/5 owned)
-- Each has 5 required, 2 owned + 3 not-owned
-- ============================================================

INSERT INTO public.recipes (id, title, description, cuisine, difficulty, prep_time_minutes, cook_time_minutes, servings, tags, flavor_vectors) VALUES
    (v_r10, 'Banana Egg Pancakes',
     'Fluffy pancakes with banana, eggs, milk, flour, and butter.',
     'American', 1, 5, 15, 4,
     ARRAY['breakfast', 'pancake', 'sweet'],
     '{"sweet": 0.8, "umami": 0.1}'::JSONB),

    (v_r11, 'Tomato Egg Stir-Fry',
     'Chinese-style wok-fried eggs with tomato, garlic, onion, and soy sauce.',
     'Chinese', 1, 5, 8, 2,
     ARRAY['quick', 'classic', 'wok'],
     '{"umami": 0.7, "sweet": 0.3, "sour": 0.4, "salty": 0.5}'::JSONB),

    (v_r12, 'Chicken Broccoli Bake',
     'Baked chicken with broccoli, cheddar cheese, garlic, and butter.',
     'American', 2, 15, 25, 3,
     ARRAY['casserole', 'cheesy', 'baked'],
     '{"umami": 0.7, "salty": 0.5, "sweet": 0.1}'::JSONB);

-- ============================================================
-- TIER 5 — GLOBAL (<40% match = 0-1/5 owned)
-- Each has 4-5 required, 0-1 owned
-- ============================================================

INSERT INTO public.recipes (id, title, description, cuisine, difficulty, prep_time_minutes, cook_time_minutes, servings, tags, flavor_vectors) VALUES
    (v_r13, 'Tofu Veggie Stir-Fry',
     'Wok-fried firm tofu with broccoli, carrot, garlic, and ginger.',
     'Asian', 1, 10, 10, 2,
     ARRAY['vegan', 'healthy', 'stir-fry'],
     '{"umami": 0.6, "salty": 0.3, "sweet": 0.2, "spicy": 0.3}'::JSONB),

    (v_r14, 'Classic Banana Bread',
     'Moist banana bread with flour, sugar, butter, and ripe bananas.',
     'American', 2, 15, 55, 8,
     ARRAY['baking', 'sweet', 'classic'],
     '{"sweet": 0.9, "umami": 0.1}'::JSONB),

    (v_r15, 'Cheese Tomato Tart',
     'Rustic tart with fresh tomatoes, cheddar cheese, onion, flour, and olive oil.',
     'French', 3, 20, 30, 4,
     ARRAY['baking', 'savory', 'tart'],
     '{"umami": 0.6, "salty": 0.5, "sour": 0.3, "sweet": 0.2}'::JSONB);

-- ── 4. Recipe Ingredients ──────────────────────────────────────

INSERT INTO public.recipe_ingredients (recipe_id, ingredient_id, quantity, unit, is_optional, prep_note) VALUES

    -- ── TIER 1: Soy-Glazed Chicken Bites (chicken, soy, eggs) = 3/3 = 100%
    (v_r1, v_chicken_id, 400, 'g',     FALSE, 'cubed'),
    (v_r1, v_soy_id,     40,  'ml',    FALSE, NULL),
    (v_r1, v_egg_id,     1,   'piece', FALSE, 'beaten for coating'),

    -- ── TIER 1: Creamy Spinach Egg Bowl (eggs, spinach, milk) = 3/3 = 100%
    (v_r2, v_egg_id,     3,   'piece', FALSE, 'soft scramble'),
    (v_r2, v_spinach_id, 0.5, 'bunch', FALSE, 'wilted'),
    (v_r2, v_milk_id,    50,  'ml',    FALSE, 'splash'),

    -- ── TIER 1: Chicken Dumpling Hot Pot (chicken, dumplings, soy, eggs, spinach) = 5/5 = 100%
    (v_r3, v_chicken_id,  200, 'g',     FALSE, 'sliced'),
    (v_r3, v_dumpling_id, 8,   'piece', FALSE, NULL),
    (v_r3, v_soy_id,      30,  'ml',    FALSE, NULL),
    (v_r3, v_egg_id,      2,   'piece', FALSE, 'egg ribbons'),
    (v_r3, v_spinach_id,  1,   'bunch', FALSE, 'added last'),

    -- ── TIER 2: Chicken Fried Rice (chicken✓, eggs✓, soy✓, spinach✓, rice✗) = 4/5 = 80%
    (v_r4, v_chicken_id, 250, 'g',     FALSE, 'diced'),
    (v_r4, v_egg_id,     2,   'piece', FALSE, 'scrambled'),
    (v_r4, v_soy_id,     30,  'ml',    FALSE, NULL),
    (v_r4, v_spinach_id, 0.5, 'bunch', FALSE, 'chopped'),
    (v_r4, v_rice_id,    300, 'g',     FALSE, 'day-old cooked'),

    -- ── TIER 2: Teriyaki Chicken Bowl (chicken✓, soy✓, eggs✓, spinach✓, ginger✗) = 4/5 = 80%
    (v_r5, v_chicken_id, 300, 'g',     FALSE, 'grilled slices'),
    (v_r5, v_soy_id,     40,  'ml',    FALSE, 'teriyaki base'),
    (v_r5, v_egg_id,     1,   'piece', FALSE, 'soft-boiled'),
    (v_r5, v_spinach_id, 1,   'bunch', FALSE, 'bed of greens'),
    (v_r5, v_ginger_id,  15,  'g',     FALSE, 'grated'),

    -- ── TIER 2: Spinach Chicken Milk Soup (chicken✓, spinach✓, eggs✓, milk✓, garlic✗) = 4/5 = 80%
    (v_r6, v_chicken_id, 200, 'g',     FALSE, 'shredded'),
    (v_r6, v_spinach_id, 1,   'bunch', FALSE, NULL),
    (v_r6, v_egg_id,     1,   'piece', FALSE, 'whisked in'),
    (v_r6, v_milk_id,    200, 'ml',    FALSE, 'cream base'),
    (v_r6, v_garlic_id,  3,   'piece', FALSE, 'minced'),

    -- ── TIER 3: Chicken Apple Waldorf (chicken✓, apple✓, spinach✓, onion✗, olive_oil✗) = 3/5 = 60%
    (v_r7, v_chicken_id,  200, 'g',     FALSE, 'grilled, sliced'),
    (v_r7, v_apple_id,    2,   'piece', FALSE, 'thin sliced'),
    (v_r7, v_spinach_id,  1,   'bunch', FALSE, 'bed'),
    (v_r7, v_onion_id,    0.5, 'piece', FALSE, 'thinly sliced'),
    (v_r7, v_olive_oil_id,15, 'ml',    FALSE, 'dressing'),

    -- ── TIER 3: Creamy Spinach Frittata (eggs✓, spinach✓, milk✓, cheese✗, butter✗) = 3/5 = 60%
    (v_r8, v_egg_id,     4,   'piece', FALSE, 'beaten'),
    (v_r8, v_spinach_id, 1,   'bunch', FALSE, 'chopped'),
    (v_r8, v_milk_id,    60,  'ml',    FALSE, NULL),
    (v_r8, v_cheese_id,  80,  'g',     FALSE, 'grated'),
    (v_r8, v_butter_id,  20,  'g',     FALSE, 'for pan'),

    -- ── TIER 3: Egg Vegetable Stir-Fry (eggs✓, soy✓, spinach✓, pepper✗, broccoli✗) = 3/5 = 60%
    (v_r9, v_egg_id,      3,   'piece', FALSE, 'beaten'),
    (v_r9, v_soy_id,      20,  'ml',    FALSE, NULL),
    (v_r9, v_spinach_id,  0.5, 'bunch', FALSE, NULL),
    (v_r9, v_pepper_id,   1,   'piece', FALSE, 'diced'),
    (v_r9, v_broccoli_id, 1,   'piece', FALSE, 'florets'),

    -- ── TIER 4: Banana Egg Pancakes (eggs✓, milk✓, banana✗, flour✗, butter✗) = 2/5 = 40%
    (v_r10, v_egg_id,    2,   'piece', FALSE, NULL),
    (v_r10, v_milk_id,   100, 'ml',    FALSE, NULL),
    (v_r10, v_banana_id, 2,   'piece', FALSE, 'mashed'),
    (v_r10, v_flour_id,  150, 'g',     FALSE, NULL),
    (v_r10, v_butter_id, 30,  'g',     FALSE, 'for griddle'),

    -- ── TIER 4: Tomato Egg Stir-Fry (eggs✓, soy✓, tomato✗, garlic✗, onion✗) = 2/5 = 40%
    (v_r11, v_egg_id,    3,   'piece', FALSE, 'beaten'),
    (v_r11, v_soy_id,    15,  'ml',    FALSE, NULL),
    (v_r11, v_tomato_id, 3,   'piece', FALSE, 'wedged'),
    (v_r11, v_garlic_id, 2,   'piece', FALSE, 'minced'),
    (v_r11, v_onion_id,  1,   'piece', FALSE, 'diced'),

    -- ── TIER 4: Chicken Broccoli Bake (chicken✓, broccoli✗, cheese✗, garlic✗, butter✗) = 1/5... wait
    -- Fix: (chicken✓, eggs✓, broccoli✗, cheese✗, garlic✗) = 2/5 = 40%
    (v_r12, v_chicken_id,  300, 'g',     FALSE, 'cubed'),
    (v_r12, v_egg_id,      1,   'piece', FALSE, 'binder'),
    (v_r12, v_broccoli_id, 1,   'piece', FALSE, 'florets'),
    (v_r12, v_cheese_id,   100, 'g',     FALSE, 'melted on top'),
    (v_r12, v_garlic_id,   3,   'piece', FALSE, 'minced'),

    -- ── TIER 5: Tofu Veggie Stir-Fry (tofu✗, broccoli✗, carrot✗, garlic✗, ginger✗) = 0/5 = 0%
    (v_r13, v_tofu_id,     200, 'g',     FALSE, 'pressed, cubed'),
    (v_r13, v_broccoli_id, 1,   'piece', FALSE, 'florets'),
    (v_r13, v_carrot_id,   1,   'piece', FALSE, 'julienned'),
    (v_r13, v_garlic_id,   3,   'piece', FALSE, 'minced'),
    (v_r13, v_ginger_id,   10,  'g',     FALSE, 'grated'),

    -- ── TIER 5: Classic Banana Bread (banana✗, flour✗, sugar✗, butter✗) = 0/4 = 0%
    (v_r14, v_banana_id, 3,   'piece', FALSE, 'overripe, mashed'),
    (v_r14, v_flour_id,  250, 'g',     FALSE, NULL),
    (v_r14, v_sugar_id,  100, 'g',     FALSE, NULL),
    (v_r14, v_butter_id, 80,  'g',     FALSE, 'melted'),

    -- ── TIER 5: Cheese Tomato Tart (tomato✗, cheese✗, onion✗, flour✗, olive_oil✗) = 0/5 = 0%
    (v_r15, v_tomato_id,    3,   'piece', FALSE, 'sliced'),
    (v_r15, v_cheese_id,    120, 'g',     FALSE, 'grated'),
    (v_r15, v_onion_id,     1,   'piece', FALSE, 'rings'),
    (v_r15, v_flour_id,     200, 'g',     FALSE, 'pastry crust'),
    (v_r15, v_olive_oil_id, 30,  'ml',    FALSE, 'drizzle');

RAISE NOTICE 'Added 12 ingredients + 15 recipes (3 per tier) for demo user %', v_demo_user_id;

END $$;
