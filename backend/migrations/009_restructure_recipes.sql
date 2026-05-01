-- Migration: 009_restructure_recipes
-- Description: Flattens recipe ingredients and steps into JSONB columns for mass import simplicity.

-- 1. Add JSONB columns to recipes
ALTER TABLE public.recipes 
ADD COLUMN IF NOT EXISTS ingredients JSONB DEFAULT '[]'::jsonb,
ADD COLUMN IF NOT EXISTS steps JSONB DEFAULT '[]'::jsonb;

-- 2. Drop the old relational tables (WARNING: Data loss if not migrated!)
DROP TABLE IF EXISTS public.recipe_ingredients CASCADE;
DROP TABLE IF EXISTS public.recipe_steps CASCADE;

-- 3. Update the recipe_translations table schema to match
DROP TABLE IF EXISTS public.recipe_translations CASCADE;
CREATE TABLE public.recipe_translations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    recipe_id UUID NOT NULL REFERENCES public.recipes(id) ON DELETE CASCADE,
    language_code TEXT NOT NULL,
    title_translated TEXT NOT NULL,
    ingredients_translated JSONB NOT NULL,
    steps_translated JSONB NOT NULL,
    translated_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(recipe_id, language_code)
);

-- Enable RLS for translations
ALTER TABLE public.recipe_translations ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Translations are viewable by everyone" ON public.recipe_translations FOR SELECT USING (true);
