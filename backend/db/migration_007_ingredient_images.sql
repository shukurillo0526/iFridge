-- ============================================================
-- I-Fridge — Migration 007: Ingredient Images
-- ============================================================
-- Adds an image_url column to the ingredients table so each
-- ingredient can have its own photo instead of a generic icon.
-- ============================================================

ALTER TABLE public.ingredients
    ADD COLUMN IF NOT EXISTS image_url TEXT;

COMMENT ON COLUMN public.ingredients.image_url IS
    'URL or asset path to a photo of this ingredient. '
    'Format: "asset:ingredients/potato.webp" for bundled assets, '
    'or "https://..." for remote URLs.';
