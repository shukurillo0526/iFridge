-- ============================================================
-- I-Fridge — Recipe Steps Seed Data (Phase 6)
-- ============================================================
-- Run AFTER additional_seed_data.sql in Supabase SQL Editor.
-- Adds 3–5 cooking steps for all 15 recipes from Phase 4b.
-- ============================================================

DO $$
DECLARE
    v_r1  UUID;  v_r2  UUID;  v_r3  UUID;  v_r4  UUID;  v_r5  UUID;
    v_r6  UUID;  v_r7  UUID;  v_r8  UUID;  v_r9  UUID;  v_r10 UUID;
    v_r11 UUID;  v_r12 UUID;  v_r13 UUID;  v_r14 UUID;  v_r15 UUID;
BEGIN

-- ── Look up recipe IDs by title ──────────────────────────────────
SELECT id INTO v_r1  FROM public.recipes WHERE title = 'Soy-Glazed Chicken Bites';
SELECT id INTO v_r2  FROM public.recipes WHERE title = 'Creamy Spinach Egg Bowl';
SELECT id INTO v_r3  FROM public.recipes WHERE title = 'Chicken Dumpling Hot Pot';
SELECT id INTO v_r4  FROM public.recipes WHERE title = 'Chicken Fried Rice';
SELECT id INTO v_r5  FROM public.recipes WHERE title = 'Teriyaki Chicken Bowl';
SELECT id INTO v_r6  FROM public.recipes WHERE title = 'Spinach Chicken Milk Soup';
SELECT id INTO v_r7  FROM public.recipes WHERE title = 'Chicken Apple Waldorf';
SELECT id INTO v_r8  FROM public.recipes WHERE title = 'Creamy Spinach Frittata';
SELECT id INTO v_r9  FROM public.recipes WHERE title = 'Egg Vegetable Stir-Fry';
SELECT id INTO v_r10 FROM public.recipes WHERE title = 'Banana Egg Pancakes';
SELECT id INTO v_r11 FROM public.recipes WHERE title = 'Tomato Egg Stir-Fry';
SELECT id INTO v_r12 FROM public.recipes WHERE title = 'Chicken Broccoli Bake';
SELECT id INTO v_r13 FROM public.recipes WHERE title = 'Tofu Veggie Stir-Fry';
SELECT id INTO v_r14 FROM public.recipes WHERE title = 'Classic Banana Bread';
SELECT id INTO v_r15 FROM public.recipes WHERE title = 'Cheese Tomato Tart';

-- ============================================================
-- TIER 1 STEPS
-- ============================================================

-- R1: Soy-Glazed Chicken Bites
INSERT INTO public.recipe_steps (recipe_id, step_number, human_text, robot_action, estimated_seconds, requires_attention) VALUES
(v_r1, 1, 'Cut chicken breast into bite-sized cubes.',
 '{"action": "CUT", "target": "chicken_breast", "params": {"style": "cubes", "size": "bite"}}'::JSONB, 120, TRUE),
(v_r1, 2, 'Beat one egg in a bowl and toss the chicken cubes to coat.',
 '{"action": "MIX", "target": "chicken", "params": {"add": ["egg"]}}'::JSONB, 60, TRUE),
(v_r1, 3, 'Heat a pan over medium-high heat with a drizzle of oil.',
 '{"action": "HEAT", "target": "pan", "params": {"temp_c": 190}}'::JSONB, 60, FALSE),
(v_r1, 4, 'Pan-sear chicken cubes for 5 minutes, turning until golden on all sides.',
 '{"action": "FRY", "target": "chicken", "params": {"duration_s": 300, "stir": true}}'::JSONB, 300, TRUE),
(v_r1, 5, 'Pour soy sauce over chicken, toss for 30 seconds until glazed. Serve.',
 '{"action": "SEASON_PLATE", "target": "chicken", "params": {"add": ["soy_sauce"]}}'::JSONB, 60, FALSE);

-- R2: Creamy Spinach Egg Bowl
INSERT INTO public.recipe_steps (recipe_id, step_number, human_text, robot_action, estimated_seconds, requires_attention) VALUES
(v_r2, 1, 'Heat a non-stick pan over medium-low heat.',
 '{"action": "HEAT", "target": "pan", "params": {"temp_c": 140}}'::JSONB, 30, FALSE),
(v_r2, 2, 'Add spinach leaves and wilt for 1 minute.',
 '{"action": "SAUTE", "target": "spinach", "params": {"duration_s": 60}}'::JSONB, 60, TRUE),
(v_r2, 3, 'Crack eggs into the pan, add a splash of milk, and scramble gently.',
 '{"action": "SCRAMBLE", "target": "eggs", "params": {"add": ["milk"], "duration_s": 120}}'::JSONB, 120, TRUE),
(v_r2, 4, 'Transfer to a bowl and season with salt and pepper. Serve warm.',
 '{"action": "PLATE", "target": "egg_bowl", "params": {}}'::JSONB, 30, FALSE);

-- R3: Chicken Dumpling Hot Pot
INSERT INTO public.recipe_steps (recipe_id, step_number, human_text, robot_action, estimated_seconds, requires_attention) VALUES
(v_r3, 1, 'Bring 4 cups of water to a boil in a pot. Add soy sauce.',
 '{"action": "BOIL", "target": "pot", "params": {"water_ml": 1000, "add": ["soy_sauce"]}}'::JSONB, 180, FALSE),
(v_r3, 2, 'Add sliced chicken breast and simmer for 5 minutes.',
 '{"action": "SIMMER", "target": "chicken", "params": {"duration_s": 300}}'::JSONB, 300, TRUE),
(v_r3, 3, 'Drop in frozen dumplings and cook for 6 minutes.',
 '{"action": "BOIL", "target": "dumplings", "params": {"duration_s": 360}}'::JSONB, 360, TRUE),
(v_r3, 4, 'Beat eggs and drizzle into the broth in a thin stream for egg ribbons.',
 '{"action": "MIX", "target": "eggs", "params": {"technique": "egg_drop"}}'::JSONB, 60, TRUE),
(v_r3, 5, 'Add spinach, stir once, and serve immediately.',
 '{"action": "ADD_PLATE", "target": "spinach", "params": {}}'::JSONB, 30, FALSE);

-- ============================================================
-- TIER 2 STEPS
-- ============================================================

-- R4: Chicken Fried Rice
INSERT INTO public.recipe_steps (recipe_id, step_number, human_text, robot_action, estimated_seconds, requires_attention) VALUES
(v_r4, 1, 'Heat oil in a wok over high heat.',
 '{"action": "HEAT", "target": "wok", "params": {"temp_c": 220}}'::JSONB, 60, FALSE),
(v_r4, 2, 'Scramble eggs in the wok and set aside.',
 '{"action": "SCRAMBLE", "target": "eggs", "params": {"duration_s": 60}}'::JSONB, 60, TRUE),
(v_r4, 3, 'Stir-fry diced chicken for 4 minutes until cooked through.',
 '{"action": "FRY", "target": "chicken", "params": {"duration_s": 240}}'::JSONB, 240, TRUE),
(v_r4, 4, 'Add day-old rice and spinach. Toss on high heat for 3 minutes.',
 '{"action": "FRY", "target": "rice", "params": {"add": ["spinach"], "duration_s": 180}}'::JSONB, 180, TRUE),
(v_r4, 5, 'Add soy sauce and scrambled egg. Toss to combine and serve.',
 '{"action": "SEASON_PLATE", "target": "fried_rice", "params": {"add": ["soy_sauce", "egg"]}}'::JSONB, 60, FALSE);

-- R5: Teriyaki Chicken Bowl
INSERT INTO public.recipe_steps (recipe_id, step_number, human_text, robot_action, estimated_seconds, requires_attention) VALUES
(v_r5, 1, 'Mix soy sauce with a teaspoon of sugar and grated ginger for teriyaki glaze.',
 '{"action": "MIX", "target": "sauce", "params": {"ingredients": ["soy_sauce", "sugar", "ginger"]}}'::JSONB, 60, TRUE),
(v_r5, 2, 'Grill or pan-sear chicken slices for 5 minutes per side.',
 '{"action": "GRILL", "target": "chicken", "params": {"duration_s": 600}}'::JSONB, 600, TRUE),
(v_r5, 3, 'Brush teriyaki glaze over chicken in the last minute of cooking.',
 '{"action": "GLAZE", "target": "chicken", "params": {"sauce": "teriyaki"}}'::JSONB, 60, TRUE),
(v_r5, 4, 'Soft-boil the egg: boil for 6.5 minutes, then ice bath.',
 '{"action": "BOIL", "target": "egg", "params": {"duration_s": 390}}'::JSONB, 390, TRUE),
(v_r5, 5, 'Arrange spinach in a bowl, top with sliced chicken and halved egg.',
 '{"action": "PLATE", "target": "bowl", "params": {}}'::JSONB, 60, FALSE);

-- R6: Spinach Chicken Milk Soup
INSERT INTO public.recipe_steps (recipe_id, step_number, human_text, robot_action, estimated_seconds, requires_attention) VALUES
(v_r6, 1, 'Sauté minced garlic in a pot until fragrant.',
 '{"action": "SAUTE", "target": "garlic", "params": {"duration_s": 60}}'::JSONB, 60, TRUE),
(v_r6, 2, 'Add shredded chicken and cook for 3 minutes.',
 '{"action": "FRY", "target": "chicken", "params": {"duration_s": 180}}'::JSONB, 180, TRUE),
(v_r6, 3, 'Pour in milk and 1 cup water. Bring to a gentle simmer.',
 '{"action": "SIMMER", "target": "soup", "params": {"add": ["milk", "water"]}}'::JSONB, 180, FALSE),
(v_r6, 4, 'Add spinach and whisk in a beaten egg. Cook 2 minutes.',
 '{"action": "ADD_MIX", "target": "spinach_egg", "params": {"duration_s": 120}}'::JSONB, 120, TRUE),
(v_r6, 5, 'Season with salt and pepper. Ladle into bowls.',
 '{"action": "SEASON_PLATE", "target": "soup", "params": {}}'::JSONB, 30, FALSE);

-- ============================================================
-- TIER 3 STEPS
-- ============================================================

-- R7: Chicken Apple Waldorf
INSERT INTO public.recipe_steps (recipe_id, step_number, human_text, robot_action, estimated_seconds, requires_attention) VALUES
(v_r7, 1, 'Grill or pan-sear chicken breast for 6 minutes per side. Let rest, then slice.',
 '{"action": "GRILL", "target": "chicken", "params": {"duration_s": 720}}'::JSONB, 720, TRUE),
(v_r7, 2, 'Thinly slice apples and onion.',
 '{"action": "CUT", "target": "apple_onion", "params": {"style": "thin_slices"}}'::JSONB, 120, TRUE),
(v_r7, 3, 'Arrange spinach on a plate, top with apple, onion, and chicken slices.',
 '{"action": "PLATE", "target": "salad", "params": {}}'::JSONB, 60, FALSE),
(v_r7, 4, 'Drizzle with olive oil and season. Toss gently and serve.',
 '{"action": "DRESS", "target": "salad", "params": {"add": ["olive_oil"]}}'::JSONB, 30, FALSE);

-- R8: Creamy Spinach Frittata
INSERT INTO public.recipe_steps (recipe_id, step_number, human_text, robot_action, estimated_seconds, requires_attention) VALUES
(v_r8, 1, 'Preheat oven to 180°C (350°F).',
 '{"action": "PREHEAT", "target": "oven", "params": {"temp_c": 180}}'::JSONB, 600, FALSE),
(v_r8, 2, 'Beat eggs with milk in a large bowl.',
 '{"action": "MIX", "target": "eggs", "params": {"add": ["milk"]}}'::JSONB, 60, TRUE),
(v_r8, 3, 'Melt butter in an oven-safe pan. Sauté spinach for 1 minute.',
 '{"action": "SAUTE", "target": "spinach", "params": {"add": ["butter"], "duration_s": 60}}'::JSONB, 90, TRUE),
(v_r8, 4, 'Pour egg mixture over spinach, sprinkle grated cheddar on top.',
 '{"action": "POUR", "target": "egg_mixture", "params": {"add": ["cheese"]}}'::JSONB, 30, TRUE),
(v_r8, 5, 'Bake for 18–20 minutes until golden and set. Let cool 5 minutes.',
 '{"action": "BAKE", "target": "frittata", "params": {"duration_s": 1200, "temp_c": 180}}'::JSONB, 1200, TRUE);

-- R9: Egg Vegetable Stir-Fry
INSERT INTO public.recipe_steps (recipe_id, step_number, human_text, robot_action, estimated_seconds, requires_attention) VALUES
(v_r9, 1, 'Dice bell pepper and cut broccoli into small florets.',
 '{"action": "CUT", "target": "vegetables", "params": {"style": "dice_florets"}}'::JSONB, 120, TRUE),
(v_r9, 2, 'Heat oil in a wok over high heat.',
 '{"action": "HEAT", "target": "wok", "params": {"temp_c": 210}}'::JSONB, 60, FALSE),
(v_r9, 3, 'Stir-fry broccoli and pepper for 3 minutes. Add spinach last 30 seconds.',
 '{"action": "FRY", "target": "vegetables", "params": {"duration_s": 180}}'::JSONB, 210, TRUE),
(v_r9, 4, 'Push veggies aside, pour beaten eggs in center. Scramble and fold together.',
 '{"action": "SCRAMBLE", "target": "eggs", "params": {"duration_s": 90}}'::JSONB, 90, TRUE),
(v_r9, 5, 'Add soy sauce, toss everything together, and serve hot.',
 '{"action": "SEASON_PLATE", "target": "stir_fry", "params": {"add": ["soy_sauce"]}}'::JSONB, 30, FALSE);

-- ============================================================
-- TIER 4 STEPS
-- ============================================================

-- R10: Banana Egg Pancakes
INSERT INTO public.recipe_steps (recipe_id, step_number, human_text, robot_action, estimated_seconds, requires_attention) VALUES
(v_r10, 1, 'Mash bananas in a bowl. Add eggs, milk, and flour. Whisk until smooth.',
 '{"action": "MIX", "target": "batter", "params": {"ingredients": ["banana", "eggs", "milk", "flour"]}}'::JSONB, 120, TRUE),
(v_r10, 2, 'Melt butter on a griddle or non-stick pan over medium heat.',
 '{"action": "HEAT", "target": "griddle", "params": {"temp_c": 160, "add": ["butter"]}}'::JSONB, 60, FALSE),
(v_r10, 3, 'Pour ¼ cup batter per pancake. Cook until bubbles form on surface (~2 min).',
 '{"action": "FRY", "target": "pancake", "params": {"duration_s": 120}}'::JSONB, 120, TRUE),
(v_r10, 4, 'Flip and cook other side for 1–2 minutes until golden.',
 '{"action": "FLIP_FRY", "target": "pancake", "params": {"duration_s": 90}}'::JSONB, 90, TRUE),
(v_r10, 5, 'Stack pancakes on a plate. Top with sliced banana if desired.',
 '{"action": "PLATE", "target": "pancakes", "params": {}}'::JSONB, 30, FALSE);

-- R11: Tomato Egg Stir-Fry
INSERT INTO public.recipe_steps (recipe_id, step_number, human_text, robot_action, estimated_seconds, requires_attention) VALUES
(v_r11, 1, 'Cut tomatoes into wedges. Dice onion and mince garlic.',
 '{"action": "CUT", "target": "vegetables", "params": {"style": "wedge_dice_mince"}}'::JSONB, 120, TRUE),
(v_r11, 2, 'Heat oil in a wok. Sauté onion and garlic until fragrant.',
 '{"action": "SAUTE", "target": "aromatics", "params": {"duration_s": 60}}'::JSONB, 90, TRUE),
(v_r11, 3, 'Add tomato wedges. Cook for 3 minutes until softened and saucy.',
 '{"action": "FRY", "target": "tomato", "params": {"duration_s": 180}}'::JSONB, 180, TRUE),
(v_r11, 4, 'Pour beaten eggs over tomatoes. Stir gently until eggs are just set.',
 '{"action": "SCRAMBLE", "target": "eggs", "params": {"duration_s": 90}}'::JSONB, 90, TRUE),
(v_r11, 5, 'Add soy sauce, stir once, and serve with rice.',
 '{"action": "SEASON_PLATE", "target": "dish", "params": {"add": ["soy_sauce"]}}'::JSONB, 30, FALSE);

-- R12: Chicken Broccoli Bake
INSERT INTO public.recipe_steps (recipe_id, step_number, human_text, robot_action, estimated_seconds, requires_attention) VALUES
(v_r12, 1, 'Preheat oven to 190°C (375°F).',
 '{"action": "PREHEAT", "target": "oven", "params": {"temp_c": 190}}'::JSONB, 600, FALSE),
(v_r12, 2, 'Cube chicken, mince garlic, and cut broccoli into florets.',
 '{"action": "CUT", "target": "ingredients", "params": {"style": "cube_mince_floret"}}'::JSONB, 180, TRUE),
(v_r12, 3, 'Toss chicken and broccoli with a beaten egg and minced garlic in a baking dish.',
 '{"action": "MIX", "target": "bake_mix", "params": {"add": ["egg", "garlic"]}}'::JSONB, 60, TRUE),
(v_r12, 4, 'Top with grated cheddar cheese.',
 '{"action": "ADD", "target": "cheese", "params": {}}'::JSONB, 30, FALSE),
(v_r12, 5, 'Bake for 25 minutes until chicken is cooked and cheese is bubbly.',
 '{"action": "BAKE", "target": "casserole", "params": {"duration_s": 1500, "temp_c": 190}}'::JSONB, 1500, TRUE);

-- ============================================================
-- TIER 5 STEPS
-- ============================================================

-- R13: Tofu Veggie Stir-Fry
INSERT INTO public.recipe_steps (recipe_id, step_number, human_text, robot_action, estimated_seconds, requires_attention) VALUES
(v_r13, 1, 'Press tofu for 10 minutes, then cut into cubes.',
 '{"action": "PREP", "target": "tofu", "params": {"technique": "press", "duration_s": 600}}'::JSONB, 720, TRUE),
(v_r13, 2, 'Mince garlic and grate ginger. Cut broccoli into florets, julienne carrot.',
 '{"action": "CUT", "target": "aromatics_veggies", "params": {}}'::JSONB, 180, TRUE),
(v_r13, 3, 'Heat oil in a wok. Pan-fry tofu cubes until golden on all sides (~4 min).',
 '{"action": "FRY", "target": "tofu", "params": {"duration_s": 240}}'::JSONB, 240, TRUE),
(v_r13, 4, 'Add garlic, ginger, broccoli, and carrot. Stir-fry for 3 minutes.',
 '{"action": "FRY", "target": "vegetables", "params": {"duration_s": 180}}'::JSONB, 180, TRUE),
(v_r13, 5, 'Add a splash of soy sauce, toss to combine, and serve.',
 '{"action": "SEASON_PLATE", "target": "stir_fry", "params": {}}'::JSONB, 30, FALSE);

-- R14: Classic Banana Bread
INSERT INTO public.recipe_steps (recipe_id, step_number, human_text, robot_action, estimated_seconds, requires_attention) VALUES
(v_r14, 1, 'Preheat oven to 175°C (350°F). Grease a loaf pan.',
 '{"action": "PREHEAT", "target": "oven", "params": {"temp_c": 175}}'::JSONB, 600, FALSE),
(v_r14, 2, 'Mash bananas in a bowl. Mix in melted butter and sugar.',
 '{"action": "MIX", "target": "wet_ingredients", "params": {"ingredients": ["banana", "butter", "sugar"]}}'::JSONB, 120, TRUE),
(v_r14, 3, 'Fold in flour until just combined. Do not overmix.',
 '{"action": "FOLD", "target": "batter", "params": {"add": ["flour"]}}'::JSONB, 60, TRUE),
(v_r14, 4, 'Pour batter into the loaf pan.',
 '{"action": "POUR", "target": "loaf_pan", "params": {}}'::JSONB, 30, FALSE),
(v_r14, 5, 'Bake for 50–55 minutes. Test with a toothpick — it should come out clean.',
 '{"action": "BAKE", "target": "banana_bread", "params": {"duration_s": 3300, "temp_c": 175}}'::JSONB, 3300, TRUE);

-- R15: Cheese Tomato Tart
INSERT INTO public.recipe_steps (recipe_id, step_number, human_text, robot_action, estimated_seconds, requires_attention) VALUES
(v_r15, 1, 'Preheat oven to 200°C (400°F).',
 '{"action": "PREHEAT", "target": "oven", "params": {"temp_c": 200}}'::JSONB, 600, FALSE),
(v_r15, 2, 'Mix flour with olive oil and water to form a rough dough. Press into a tart pan.',
 '{"action": "MIX", "target": "dough", "params": {"ingredients": ["flour", "olive_oil", "water"]}}'::JSONB, 300, TRUE),
(v_r15, 3, 'Slice tomatoes and onion into rings.',
 '{"action": "CUT", "target": "tomato_onion", "params": {"style": "slices_rings"}}'::JSONB, 120, TRUE),
(v_r15, 4, 'Layer grated cheese, tomato slices, and onion rings on the crust.',
 '{"action": "LAYER", "target": "tart", "params": {"order": ["cheese", "tomato", "onion"]}}'::JSONB, 60, TRUE),
(v_r15, 5, 'Drizzle with olive oil. Bake for 25–30 minutes until golden and bubbly.',
 '{"action": "BAKE", "target": "tart", "params": {"duration_s": 1800, "temp_c": 200}}'::JSONB, 1800, TRUE);

RAISE NOTICE 'Added cooking steps for all 15 recipes.';

END $$;
