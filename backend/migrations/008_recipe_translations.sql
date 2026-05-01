-- Migration: 008_recipe_translations
-- Description: Adds a table to cache AI-generated recipe translations to save costs and improve speed.

CREATE TABLE IF NOT EXISTS public.recipe_translations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    recipe_id UUID NOT NULL REFERENCES public.recipes(id) ON DELETE CASCADE,
    language_code TEXT NOT NULL,
    title_translated TEXT NOT NULL,
    ingredients_translated JSONB NOT NULL,
    steps_translated JSONB NOT NULL,
    translated_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(recipe_id, language_code)
);

-- Enable RLS
ALTER TABLE public.recipe_translations ENABLE ROW LEVEL SECURITY;

-- Allow anyone to read translations
CREATE POLICY "Translations are viewable by everyone" 
ON public.recipe_translations 
FOR SELECT 
USING (true);

-- Backend (Service Role) handles inserts, so no public INSERT policy is needed
