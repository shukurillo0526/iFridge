-- ============================================================
-- I-Fridge — Supabase Database Migration
-- ============================================================
-- Run this in the Supabase SQL Editor to create all tables.
-- Version: 1.0.0
-- ============================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "pg_trgm";      -- Fuzzy text matching
-- CREATE EXTENSION IF NOT EXISTS "vector";     -- Uncomment for Tier 5 pgvector

-- ============================================================
-- TYPES
-- ============================================================

CREATE TYPE item_state AS ENUM (
    'sealed', 'opened', 'partially_used', 'frozen', 'thawed'
);

-- ============================================================
-- TABLES
-- ============================================================

-- 1. Users
CREATE TABLE IF NOT EXISTS public.users (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email           TEXT UNIQUE NOT NULL,
    display_name    TEXT NOT NULL DEFAULT 'Chef',
    avatar_url      TEXT,
    dietary_tags    TEXT[] DEFAULT '{}',
    household_size  SMALLINT DEFAULT 1,
    onboarding_done BOOLEAN DEFAULT FALSE,
    created_at      TIMESTAMPTZ DEFAULT now(),
    updated_at      TIMESTAMPTZ DEFAULT now()
);

-- 2. Ingredients (Canonical Dictionary)
CREATE TABLE IF NOT EXISTS public.ingredients (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    canonical_name          TEXT UNIQUE NOT NULL,
    display_name_en         TEXT NOT NULL,
    display_name_ko         TEXT,
    category                TEXT NOT NULL,
    sub_category            TEXT,
    default_unit            TEXT NOT NULL DEFAULT 'piece',
    sealed_shelf_life_days  INT,
    opened_shelf_life_days  INT,
    avg_weight_grams        NUMERIC(8,2),
    clarifai_concept_ids    TEXT[] DEFAULT '{}',
    is_allergen             BOOLEAN DEFAULT FALSE,
    allergen_group          TEXT,
    storage_zone            TEXT DEFAULT 'fridge',
    created_at              TIMESTAMPTZ DEFAULT now()
);

-- 3. Inventory Items (Digital Twin)
CREATE TABLE IF NOT EXISTS public.inventory_items (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    ingredient_id       UUID NOT NULL REFERENCES public.ingredients(id),
    quantity            NUMERIC(10,2) NOT NULL DEFAULT 1,
    unit                TEXT NOT NULL DEFAULT 'piece',
    item_state          item_state NOT NULL DEFAULT 'sealed',
    state_changed_at    TIMESTAMPTZ,
    purchase_date       DATE DEFAULT CURRENT_DATE,
    manual_expiry_date  DATE,
    computed_expiry     DATE,
    source              TEXT DEFAULT 'manual',
    confidence_score    NUMERIC(3,2),
    location            TEXT DEFAULT 'fridge',
    notes               TEXT,
    created_at          TIMESTAMPTZ DEFAULT now(),
    updated_at          TIMESTAMPTZ DEFAULT now()
);

-- 4. Recipes
CREATE TABLE IF NOT EXISTS public.recipes (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title               TEXT NOT NULL,
    description         TEXT,
    cuisine             TEXT,
    difficulty          SMALLINT CHECK (difficulty BETWEEN 1 AND 5),
    prep_time_minutes   INT,
    cook_time_minutes   INT,
    servings            SMALLINT DEFAULT 2,
    image_url           TEXT,
    tags                TEXT[] DEFAULT '{}',
    flavor_vectors      JSONB DEFAULT '{}',
    is_community        BOOLEAN DEFAULT FALSE,
    author_id           UUID REFERENCES public.users(id),
    created_at          TIMESTAMPTZ DEFAULT now()
);

-- 5. Recipe Ingredients
CREATE TABLE IF NOT EXISTS public.recipe_ingredients (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    recipe_id       UUID NOT NULL REFERENCES public.recipes(id) ON DELETE CASCADE,
    ingredient_id   UUID NOT NULL REFERENCES public.ingredients(id),
    quantity        NUMERIC(10,2) NOT NULL,
    unit            TEXT NOT NULL,
    is_optional     BOOLEAN DEFAULT FALSE,
    prep_note       TEXT
);

-- 6. Recipe Steps (Robot-Ready)
CREATE TABLE IF NOT EXISTS public.recipe_steps (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    recipe_id           UUID NOT NULL REFERENCES public.recipes(id) ON DELETE CASCADE,
    step_number         SMALLINT NOT NULL,
    human_text          TEXT NOT NULL,
    robot_action        JSONB NOT NULL,
    estimated_seconds   INT,
    requires_attention  BOOLEAN DEFAULT TRUE,
    CONSTRAINT uq_recipe_step UNIQUE (recipe_id, step_number)
);

-- 7. User Recipe History
CREATE TABLE IF NOT EXISTS public.user_recipe_history (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    recipe_id   UUID NOT NULL REFERENCES public.recipes(id),
    cooked_at   TIMESTAMPTZ DEFAULT now(),
    rating      SMALLINT CHECK (rating BETWEEN 1 AND 5),
    tier_used   SMALLINT CHECK (tier_used BETWEEN 1 AND 5),
    waste_score NUMERIC(3,2),
    notes       TEXT
);

-- 8. User Flavor Profile
CREATE TABLE IF NOT EXISTS public.user_flavor_profile (
    user_id             UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
    sweet               NUMERIC(3,2) DEFAULT 0.50,
    salty               NUMERIC(3,2) DEFAULT 0.50,
    sour                NUMERIC(3,2) DEFAULT 0.50,
    bitter              NUMERIC(3,2) DEFAULT 0.50,
    umami               NUMERIC(3,2) DEFAULT 0.50,
    spicy               NUMERIC(3,2) DEFAULT 0.50,
    preferred_cuisines  TEXT[] DEFAULT '{}',
    disliked_ingredients UUID[] DEFAULT '{}',
    updated_at          TIMESTAMPTZ DEFAULT now()
);

-- 9. Vision Corrections
CREATE TABLE IF NOT EXISTS public.vision_corrections (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             UUID NOT NULL REFERENCES public.users(id),
    original_prediction TEXT NOT NULL,
    corrected_to        UUID REFERENCES public.ingredients(id),
    clarifai_concept_id TEXT,
    confidence          NUMERIC(3,2),
    image_storage_path  TEXT,
    created_at          TIMESTAMPTZ DEFAULT now()
);

-- 10. Gamification Stats
CREATE TABLE IF NOT EXISTS public.gamification_stats (
    user_id             UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
    total_meals_cooked  INT DEFAULT 0,
    tier1_meals         INT DEFAULT 0,
    tier2_meals         INT DEFAULT 0,
    items_saved         INT DEFAULT 0,
    items_wasted        INT DEFAULT 0,
    current_streak      INT DEFAULT 0,
    longest_streak      INT DEFAULT 0,
    xp_points           INT DEFAULT 0,
    level               SMALLINT DEFAULT 1,
    badges              JSONB DEFAULT '[]',
    updated_at          TIMESTAMPTZ DEFAULT now()
);

-- ============================================================
-- INDEXES
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_ingredients_category    ON public.ingredients(category);
CREATE INDEX IF NOT EXISTS idx_ingredients_canonical   ON public.ingredients(canonical_name);
CREATE INDEX IF NOT EXISTS idx_inventory_user          ON public.inventory_items(user_id);
CREATE INDEX IF NOT EXISTS idx_inventory_expiry        ON public.inventory_items(user_id, computed_expiry);
CREATE INDEX IF NOT EXISTS idx_inventory_ingredient    ON public.inventory_items(ingredient_id);
CREATE INDEX IF NOT EXISTS idx_recipes_tags            ON public.recipes USING GIN(tags);
CREATE INDEX IF NOT EXISTS idx_recipes_flavor          ON public.recipes USING GIN(flavor_vectors);
CREATE INDEX IF NOT EXISTS idx_ri_recipe               ON public.recipe_ingredients(recipe_id);
CREATE INDEX IF NOT EXISTS idx_ri_ingredient           ON public.recipe_ingredients(ingredient_id);
CREATE INDEX IF NOT EXISTS idx_steps_recipe            ON public.recipe_steps(recipe_id);
CREATE INDEX IF NOT EXISTS idx_history_user            ON public.user_recipe_history(user_id);
CREATE INDEX IF NOT EXISTS idx_history_recipe          ON public.user_recipe_history(user_id, recipe_id);

-- ============================================================
-- TRIGGERS: Auto-compute expiry on inventory changes
-- ============================================================

CREATE OR REPLACE FUNCTION fn_compute_expiry()
RETURNS TRIGGER AS $$
DECLARE
    v_sealed_days INT;
    v_opened_days INT;
    v_base_date   DATE;
BEGIN
    SELECT sealed_shelf_life_days, opened_shelf_life_days
      INTO v_sealed_days, v_opened_days
      FROM public.ingredients
     WHERE id = NEW.ingredient_id;

    IF NEW.manual_expiry_date IS NOT NULL THEN
        NEW.computed_expiry := NEW.manual_expiry_date;
        RETURN NEW;
    END IF;

    v_base_date := COALESCE(NEW.purchase_date, CURRENT_DATE);

    IF NEW.item_state IN ('opened', 'partially_used', 'thawed') THEN
        v_base_date := COALESCE(NEW.state_changed_at::DATE, CURRENT_DATE);
        NEW.computed_expiry := v_base_date + COALESCE(v_opened_days, 3);
    ELSIF NEW.item_state = 'frozen' THEN
        NEW.computed_expiry := v_base_date + 90;
    ELSE
        NEW.computed_expiry := v_base_date + COALESCE(v_sealed_days, 7);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_compute_expiry
    BEFORE INSERT OR UPDATE ON public.inventory_items
    FOR EACH ROW EXECUTE FUNCTION fn_compute_expiry();

-- ============================================================
-- FUNCTIONS: Fuzzy ingredient matching (for vision pipeline)
-- ============================================================

CREATE OR REPLACE FUNCTION fuzzy_match_ingredient(
    search_name     TEXT,
    min_similarity  FLOAT DEFAULT 0.3,
    max_results     INT DEFAULT 5
)
RETURNS TABLE (
    id              UUID,
    canonical_name  TEXT,
    display_name_en TEXT,
    similarity_score FLOAT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        i.id,
        i.canonical_name,
        i.display_name_en,
        similarity(i.display_name_en, search_name)::FLOAT AS similarity_score
    FROM public.ingredients i
    WHERE similarity(i.display_name_en, search_name) > min_similarity
    ORDER BY similarity_score DESC
    LIMIT max_results;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
CREATE POLICY "users_self" ON public.users
    USING (auth.uid() = id) WITH CHECK (auth.uid() = id);

ALTER TABLE public.inventory_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "inventory_owner" ON public.inventory_items
    USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

ALTER TABLE public.user_recipe_history ENABLE ROW LEVEL SECURITY;
CREATE POLICY "history_owner" ON public.user_recipe_history
    USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

ALTER TABLE public.user_flavor_profile ENABLE ROW LEVEL SECURITY;
CREATE POLICY "profile_owner" ON public.user_flavor_profile
    USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

ALTER TABLE public.gamification_stats ENABLE ROW LEVEL SECURITY;
CREATE POLICY "stats_owner" ON public.gamification_stats
    USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

ALTER TABLE public.vision_corrections ENABLE ROW LEVEL SECURITY;
CREATE POLICY "corrections_owner" ON public.vision_corrections
    USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- Recipes and ingredients are public read
ALTER TABLE public.recipes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "recipes_public_read" ON public.recipes FOR SELECT USING (true);

ALTER TABLE public.ingredients ENABLE ROW LEVEL SECURITY;
CREATE POLICY "ingredients_public_read" ON public.ingredients FOR SELECT USING (true);

ALTER TABLE public.recipe_ingredients ENABLE ROW LEVEL SECURITY;
CREATE POLICY "ri_public_read" ON public.recipe_ingredients FOR SELECT USING (true);

ALTER TABLE public.recipe_steps ENABLE ROW LEVEL SECURITY;
CREATE POLICY "steps_public_read" ON public.recipe_steps FOR SELECT USING (true);

-- ============================================================
-- SEED DATA: Sample Ingredients
-- ============================================================

INSERT INTO public.ingredients (canonical_name, display_name_en, display_name_ko, category, sub_category, default_unit, sealed_shelf_life_days, opened_shelf_life_days, storage_zone) VALUES
('whole_milk',       'Whole Milk',       '우유',     'dairy',     'milk',         'L',     14, 3,  'fridge'),
('fuji_apple',       'Fuji Apple',       '후지 사과', 'fruit',     'pome',         'piece', 21, 7,  'fridge'),
('chicken_breast',   'Chicken Breast',   '닭가슴살',  'protein',   'poultry',      'g',     3,  1,  'fridge'),
('egg',              'Egg',              '달걀',     'egg',       NULL,           'piece', 28, 14, 'fridge'),
('spinach',          'Spinach',          '시금치',    'vegetable', 'leafy_green',  'bunch', 7,  3,  'fridge'),
('carrot',           'Carrot',           '당근',     'vegetable', 'root',         'piece', 21, 10, 'fridge'),
('soy_sauce',        'Soy Sauce',        '간장',     'seasoning', 'sauce',        'ml',    730, 365, 'pantry'),
('ginger',           'Ginger',           '생강',     'vegetable', 'root',         'g',     21, 7,  'fridge'),
('bell_pepper',      'Bell Pepper',      '피망',     'vegetable', 'nightshade',   'piece', 10, 5,  'fridge'),
('frozen_dumplings', 'Frozen Dumplings', '만두',     'grain',     'dumpling',     'piece', 180, 3, 'freezer')
ON CONFLICT (canonical_name) DO NOTHING;
