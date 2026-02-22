-- ============================================================
-- I-Fridge — Seed Data for Testing
-- ============================================================
-- Run this in the Supabase SQL Editor AFTER migration_001_init.sql.
-- Creates a demo user, recipes, inventory, and gamification data.
--
-- NOTE: RLS is active, so we temporarily bypass it for seeding.
-- ============================================================

-- Fixed demo user UUID (matches Flutter app's hardcoded 'demo-user')
-- We generate a deterministic UUID for the demo user.
DO $$
DECLARE
    v_demo_user_id UUID := '00000000-0000-4000-8000-000000000001';
    v_milk_id      UUID;
    v_apple_id     UUID;
    v_chicken_id   UUID;
    v_egg_id       UUID;
    v_spinach_id   UUID;
    v_carrot_id    UUID;
    v_soy_id       UUID;
    v_ginger_id    UUID;
    v_pepper_id    UUID;
    v_dumpling_id  UUID;
    v_recipe1_id   UUID;
    v_recipe2_id   UUID;
    v_recipe3_id   UUID;
    v_recipe4_id   UUID;
    v_recipe5_id   UUID;
BEGIN

-- ── 1. Demo User ──────────────────────────────────────────────

INSERT INTO public.users (id, email, display_name, household_size, onboarding_done)
VALUES (v_demo_user_id, 'demo@ifridge.app', 'Chef Demo', 2, TRUE)
ON CONFLICT (id) DO NOTHING;

-- ── 2. Get Ingredient IDs ─────────────────────────────────────

SELECT id INTO v_milk_id     FROM public.ingredients WHERE canonical_name = 'whole_milk';
SELECT id INTO v_apple_id    FROM public.ingredients WHERE canonical_name = 'fuji_apple';
SELECT id INTO v_chicken_id  FROM public.ingredients WHERE canonical_name = 'chicken_breast';
SELECT id INTO v_egg_id      FROM public.ingredients WHERE canonical_name = 'egg';
SELECT id INTO v_spinach_id  FROM public.ingredients WHERE canonical_name = 'spinach';
SELECT id INTO v_carrot_id   FROM public.ingredients WHERE canonical_name = 'carrot';
SELECT id INTO v_soy_id      FROM public.ingredients WHERE canonical_name = 'soy_sauce';
SELECT id INTO v_ginger_id   FROM public.ingredients WHERE canonical_name = 'ginger';
SELECT id INTO v_pepper_id   FROM public.ingredients WHERE canonical_name = 'bell_pepper';
SELECT id INTO v_dumpling_id FROM public.ingredients WHERE canonical_name = 'frozen_dumplings';

-- ── 3. Inventory Items (Digital Twin) ─────────────────────────

INSERT INTO public.inventory_items (user_id, ingredient_id, quantity, unit, item_state, purchase_date, location, source)
VALUES
    (v_demo_user_id, v_milk_id,     1,    'L',     'opened',  CURRENT_DATE - 5,  'fridge',  'camera'),
    (v_demo_user_id, v_apple_id,    4,    'piece', 'sealed',  CURRENT_DATE - 3,  'fridge',  'camera'),
    (v_demo_user_id, v_chicken_id,  500,  'g',     'sealed',  CURRENT_DATE - 1,  'fridge',  'camera'),
    (v_demo_user_id, v_egg_id,      6,    'piece', 'sealed',  CURRENT_DATE - 10, 'fridge',  'manual'),
    (v_demo_user_id, v_spinach_id,  1,    'bunch', 'opened',  CURRENT_DATE - 4,  'fridge',  'camera'),
    (v_demo_user_id, v_dumpling_id, 20,   'piece', 'frozen',  CURRENT_DATE - 30, 'freezer', 'manual'),
    (v_demo_user_id, v_soy_id,      500,  'ml',    'opened',  CURRENT_DATE - 60, 'pantry',  'manual');

-- ── 4. Recipes ────────────────────────────────────────────────

v_recipe1_id := gen_random_uuid();
v_recipe2_id := gen_random_uuid();
v_recipe3_id := gen_random_uuid();
v_recipe4_id := gen_random_uuid();
v_recipe5_id := gen_random_uuid();

INSERT INTO public.recipes (id, title, description, cuisine, difficulty, prep_time_minutes, cook_time_minutes, servings, tags, flavor_vectors)
VALUES
    (v_recipe1_id, 'Chicken Stir-Fry',
     'Quick and healthy stir-fry with fresh vegetables and tender chicken breast.',
     'Asian', 2, 10, 15, 2,
     ARRAY['quick', 'healthy', 'stir-fry'],
     '{"umami": 0.8, "salty": 0.6, "spicy": 0.3, "sweet": 0.2}'::JSONB),

    (v_recipe2_id, 'Spinach Egg Scramble',
     'Simple and nutritious scrambled eggs with fresh spinach and a touch of soy sauce.',
     'Korean', 1, 5, 8, 1,
     ARRAY['quick', 'breakfast', 'easy'],
     '{"umami": 0.5, "salty": 0.4, "sweet": 0.1}'::JSONB),

    (v_recipe3_id, 'Apple Ginger Smoothie',
     'Refreshing smoothie with Fuji apples, ginger, and milk.',
     'Fusion', 1, 5, 0, 1,
     ARRAY['smoothie', 'breakfast', 'healthy'],
     '{"sweet": 0.8, "sour": 0.3, "spicy": 0.2}'::JSONB),

    (v_recipe4_id, 'Dumpling Soup',
     'Hearty soup with frozen dumplings, egg drop, and vegetables.',
     'Korean', 2, 5, 20, 2,
     ARRAY['soup', 'comfort', 'one-pot'],
     '{"umami": 0.9, "salty": 0.5, "sweet": 0.2}'::JSONB),

    (v_recipe5_id, 'Carrot Ginger Stir-Fry',
     'Vibrant stir-fried carrots and bell peppers with a ginger-soy glaze.',
     'Asian', 1, 10, 10, 2,
     ARRAY['vegan', 'quick', 'healthy'],
     '{"sweet": 0.4, "umami": 0.6, "spicy": 0.4, "salty": 0.5}'::JSONB);

-- ── 5. Recipe Ingredients ─────────────────────────────────────

INSERT INTO public.recipe_ingredients (recipe_id, ingredient_id, quantity, unit, is_optional, prep_note) VALUES
    -- Chicken Stir-Fry
    (v_recipe1_id, v_chicken_id, 300,  'g',     FALSE, 'sliced thin'),
    (v_recipe1_id, v_pepper_id,  1,    'piece', FALSE, 'julienned'),
    (v_recipe1_id, v_carrot_id,  1,    'piece', FALSE, 'julienned'),
    (v_recipe1_id, v_ginger_id,  10,   'g',     FALSE, 'minced'),
    (v_recipe1_id, v_soy_id,     30,   'ml',    FALSE, NULL),

    -- Spinach Egg Scramble
    (v_recipe2_id, v_egg_id,     3,    'piece', FALSE, 'beaten'),
    (v_recipe2_id, v_spinach_id, 0.5,  'bunch', FALSE, 'rough chop'),
    (v_recipe2_id, v_soy_id,     5,    'ml',    TRUE,  'dash'),

    -- Apple Ginger Smoothie
    (v_recipe3_id, v_apple_id,   2,    'piece', FALSE, 'cored, chopped'),
    (v_recipe3_id, v_ginger_id,  5,    'g',     FALSE, 'peeled'),
    (v_recipe3_id, v_milk_id,    0.25, 'L',     FALSE, NULL),

    -- Dumpling Soup
    (v_recipe4_id, v_dumpling_id, 10,  'piece', FALSE, NULL),
    (v_recipe4_id, v_egg_id,      1,   'piece', FALSE, 'beaten for egg drop'),
    (v_recipe4_id, v_spinach_id, 0.5,  'bunch', TRUE,  NULL),
    (v_recipe4_id, v_soy_id,     15,   'ml',    FALSE, NULL),

    -- Carrot Ginger Stir-Fry
    (v_recipe5_id, v_carrot_id,  2,    'piece', FALSE, 'julienned'),
    (v_recipe5_id, v_pepper_id,  1,    'piece', FALSE, 'sliced'),
    (v_recipe5_id, v_ginger_id,  15,   'g',     FALSE, 'minced'),
    (v_recipe5_id, v_soy_id,     20,   'ml',    FALSE, NULL);

-- ── 6. Recipe Steps (Robot-Ready) ─────────────────────────────

INSERT INTO public.recipe_steps (recipe_id, step_number, human_text, robot_action, estimated_seconds, requires_attention) VALUES
    -- Chicken Stir-Fry
    (v_recipe1_id, 1, 'Slice chicken breast into thin strips.',
     '{"action": "CUT", "target": "chicken_breast", "params": {"style": "thin_strips"}}'::JSONB, 120, TRUE),
    (v_recipe1_id, 2, 'Heat oil in a wok over high heat.',
     '{"action": "HEAT", "target": "wok", "params": {"temp_c": 200}}'::JSONB, 60, FALSE),
    (v_recipe1_id, 3, 'Stir-fry chicken for 4 minutes until golden.',
     '{"action": "FRY", "target": "chicken", "params": {"duration_s": 240, "stir": true}}'::JSONB, 240, TRUE),
    (v_recipe1_id, 4, 'Add vegetables and ginger. Cook for 3 minutes.',
     '{"action": "ADD_FRY", "target": "vegetables", "params": {"duration_s": 180}}'::JSONB, 180, TRUE),
    (v_recipe1_id, 5, 'Add soy sauce, toss, and serve.',
     '{"action": "SEASON_PLATE", "target": "stir_fry", "params": {}}'::JSONB, 60, FALSE),

    -- Spinach Egg Scramble
    (v_recipe2_id, 1, 'Beat eggs in a bowl with a dash of soy sauce.',
     '{"action": "MIX", "target": "eggs", "params": {"add": ["soy_sauce"]}}'::JSONB, 30, TRUE),
    (v_recipe2_id, 2, 'Sauté spinach in a pan until wilted.',
     '{"action": "SAUTE", "target": "spinach", "params": {"duration_s": 60}}'::JSONB, 60, TRUE),
    (v_recipe2_id, 3, 'Pour eggs over spinach and scramble gently.',
     '{"action": "SCRAMBLE", "target": "eggs", "params": {"duration_s": 120}}'::JSONB, 120, TRUE);

-- ── 7. User Flavor Profile ────────────────────────────────────

INSERT INTO public.user_flavor_profile (user_id, sweet, salty, sour, bitter, umami, spicy, preferred_cuisines)
VALUES (v_demo_user_id, 0.70, 0.50, 0.30, 0.20, 0.80, 0.60, ARRAY['Korean', 'Asian', 'Fusion'])
ON CONFLICT (user_id) DO NOTHING;

-- ── 8. Gamification Stats ─────────────────────────────────────

INSERT INTO public.gamification_stats (user_id, total_meals_cooked, tier1_meals, tier2_meals, items_saved, items_wasted, current_streak, longest_streak, xp_points, level, badges)
VALUES (v_demo_user_id, 12, 8, 4, 24, 2, 3, 7, 850, 3,
    '[{"id":"first_meal","earned_at":"2026-01-15"},{"id":"waste_fighter","earned_at":"2026-02-01"},{"id":"first_scan","earned_at":"2026-01-15"}]'::JSONB)
ON CONFLICT (user_id) DO NOTHING;

RAISE NOTICE 'Seed data inserted successfully for demo user %', v_demo_user_id;

END $$;
