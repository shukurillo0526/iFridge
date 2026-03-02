-- ============================================================
-- I-Fridge — Migration 004: Schema Fixes & Auto-Timestamps
-- ============================================================
-- 1. Reusable `updated_at` trigger function
-- 2. Apply it to all mutable user-scoped tables
-- 3. Fix `ingredients` canonical_name generation for backend upserts
-- 4. Add missing composite indexes for common query patterns
-- ============================================================

-- ────────────────────────────────────────────────────────────
-- 1. Reusable auto-update timestamp function
-- ────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION fn_set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at := now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ────────────────────────────────────────────────────────────
-- 2. Apply updated_at triggers to mutable tables
-- ────────────────────────────────────────────────────────────

-- users
DROP TRIGGER IF EXISTS trg_users_updated_at ON public.users;
CREATE TRIGGER trg_users_updated_at
    BEFORE UPDATE ON public.users
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

-- inventory_items (already has updated_at column)
DROP TRIGGER IF EXISTS trg_inventory_updated_at ON public.inventory_items;
CREATE TRIGGER trg_inventory_updated_at
    BEFORE UPDATE ON public.inventory_items
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

-- gamification_stats
DROP TRIGGER IF EXISTS trg_gamification_updated_at ON public.gamification_stats;
CREATE TRIGGER trg_gamification_updated_at
    BEFORE UPDATE ON public.gamification_stats
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

-- user_flavor_profile
DROP TRIGGER IF EXISTS trg_flavor_updated_at ON public.user_flavor_profile;
CREATE TRIGGER trg_flavor_updated_at
    BEFORE UPDATE ON public.user_flavor_profile
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

-- ────────────────────────────────────────────────────────────
-- 3. Fix canonical_name: default to display_name_en slug
-- ────────────────────────────────────────────────────────────
-- The backend upsert creates ingredients without canonical_name.
-- This sets a default from display_name_en so NOT NULL is satisfied.

CREATE OR REPLACE FUNCTION fn_default_canonical_name()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.canonical_name IS NULL OR NEW.canonical_name = '' THEN
        NEW.canonical_name := lower(regexp_replace(NEW.display_name_en, '\s+', '_', 'g'));
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_default_canonical ON public.ingredients;
CREATE TRIGGER trg_default_canonical
    BEFORE INSERT ON public.ingredients
    FOR EACH ROW EXECUTE FUNCTION fn_default_canonical_name();

-- ────────────────────────────────────────────────────────────
-- 4. Additional composite indexes
-- ────────────────────────────────────────────────────────────

-- Inventory: location + expiry (used by LivingShelfScreen zone tabs)
CREATE INDEX IF NOT EXISTS idx_inventory_user_location
    ON public.inventory_items(user_id, location);

-- Recipe history: recent meals per user
CREATE INDEX IF NOT EXISTS idx_history_user_cooked
    ON public.user_recipe_history(user_id, cooked_at DESC);

-- Shopping list: unchecked items first
CREATE INDEX IF NOT EXISTS idx_shopping_user_purchased
    ON public.shopping_list(user_id, is_purchased);

-- Meal plan: date lookups
CREATE INDEX IF NOT EXISTS idx_meal_plan_upcoming
    ON public.meal_plan(user_id, planned_date);
