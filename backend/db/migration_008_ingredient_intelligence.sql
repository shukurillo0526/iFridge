-- ============================================================
-- I-Fridge — Migration 008: Ingredient Intelligence
-- ============================================================
-- Adds unit conversions, calorie data, and multilingual names
-- to the ingredients table for the Ingredient Intelligence Engine.
-- ============================================================

-- Unit conversion data (e.g., piece_to_g, cup_to_g)
ALTER TABLE ingredients ADD COLUMN IF NOT EXISTS unit_conversions JSONB DEFAULT '{}';

-- Calorie data per 100g for nutrition features
ALTER TABLE ingredients ADD COLUMN IF NOT EXISTS calories_per_100g INT;

-- Multilingual display names
ALTER TABLE ingredients ADD COLUMN IF NOT EXISTS display_name_uz TEXT;
ALTER TABLE ingredients ADD COLUMN IF NOT EXISTS display_name_ru TEXT;
