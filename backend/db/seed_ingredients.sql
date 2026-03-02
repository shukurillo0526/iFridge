-- ============================================================
-- I-Fridge — Seed: Common Ingredients
-- ============================================================
-- 25 everyday ingredients with proper shelf life data.
-- Uses ON CONFLICT to be safely re-runnable.
-- ============================================================

INSERT INTO public.ingredients
    (canonical_name, display_name_en, display_name_ko, category, default_unit,
     sealed_shelf_life_days, opened_shelf_life_days, storage_zone)
VALUES
    ('potato',       'Potato',       '감자',     'vegetable',  'piece', 30,  14, 'pantry'),
    ('carrot',       'Carrot',       '당근',     'vegetable',  'piece', 21,  10, 'fridge'),
    ('onion',        'Onion',        '양파',     'vegetable',  'piece', 60,  10, 'pantry'),
    ('garlic',       'Garlic',       '마늘',     'vegetable',  'clove', 60,  14, 'pantry'),
    ('tomato_paste', 'Tomato Paste', '토마토 페이스트', 'condiment', 'tbsp', 365, 14, 'pantry'),
    ('egg',          'Egg',          '달걀',     'protein',    'piece', 28,   5, 'fridge'),
    ('chicken',      'Chicken',      '닭고기',   'protein',    'g',      3,   2, 'fridge'),
    ('beef',         'Beef',         '소고기',   'protein',    'g',      5,   3, 'fridge'),
    ('rice',         'Rice',         '쌀',       'grain',      'cup',  365,  180, 'pantry'),
    ('bread',        'Bread',        '빵',       'grain',      'slice',  7,   5, 'pantry'),
    ('pasta',        'Pasta',        '파스타',   'grain',      'g',    365,  180, 'pantry'),
    ('flour',        'Flour',        '밀가루',   'baking',     'cup',  365,  180, 'pantry'),
    ('sugar',        'Sugar',        '설탕',     'baking',     'cup',  730,  365, 'pantry'),
    ('baking_soda',  'Baking Soda',  '베이킹 소다', 'baking',  'tsp',  730,  365, 'pantry'),
    ('milk',         'Milk',         '우유',     'dairy',      'ml',    10,   5, 'fridge'),
    ('butter',       'Butter',       '버터',     'dairy',      'g',     30,  14, 'fridge'),
    ('coffee',       'Coffee',       '커피',     'beverage',   'g',    365,  30, 'pantry'),
    ('cooking_oil',  'Cooking Oil',  '식용유',   'oil',        'ml',   365,  180, 'pantry'),
    ('salt',         'Salt',         '소금',     'seasoning',  'tsp', 1825, 1825, 'pantry'),
    ('black_pepper', 'Black Pepper', '후추',     'seasoning',  'tsp',  730,  365, 'pantry'),
    ('soy_sauce',    'Soy Sauce',    '간장',     'condiment',  'ml',   730,  180, 'pantry'),
    ('beans',        'Beans',        '콩',       'legume',     'cup',  365,  5,  'pantry'),
    ('peas',         'Peas',         '완두콩',   'legume',     'cup',  365,  3,  'fridge'),
    ('lentils',      'Lentils',      '렌틸콩',   'legume',     'cup',  365,  5,  'pantry')
ON CONFLICT (canonical_name) DO UPDATE SET
    display_name_en        = EXCLUDED.display_name_en,
    display_name_ko        = EXCLUDED.display_name_ko,
    category               = EXCLUDED.category,
    default_unit           = EXCLUDED.default_unit,
    sealed_shelf_life_days = EXCLUDED.sealed_shelf_life_days,
    opened_shelf_life_days = EXCLUDED.opened_shelf_life_days,
    storage_zone           = EXCLUDED.storage_zone;
