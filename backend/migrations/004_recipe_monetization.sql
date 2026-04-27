-- ═══════════════════════════════════════════════════════════════
-- iFridge Recipe Monetization — Migration 004
-- Adds premium recipe support: pricing, creator ownership, copies
-- Run in Supabase SQL Editor
-- ═══════════════════════════════════════════════════════════════

-- 1. ENHANCE recipes table with monetization columns
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='recipes' AND column_name='is_premium') THEN
    ALTER TABLE recipes ADD COLUMN is_premium BOOLEAN DEFAULT false;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='recipes' AND column_name='price_cents') THEN
    ALTER TABLE recipes ADD COLUMN price_cents INTEGER DEFAULT 0;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='recipes' AND column_name='creator_id') THEN
    ALTER TABLE recipes ADD COLUMN creator_id UUID REFERENCES auth.users(id);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='recipes' AND column_name='linked_post_id') THEN
    ALTER TABLE recipes ADD COLUMN linked_post_id UUID REFERENCES posts(id);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='recipes' AND column_name='copy_count') THEN
    ALTER TABLE recipes ADD COLUMN copy_count INTEGER DEFAULT 0;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='recipes' AND column_name='calories_per_serving') THEN
    ALTER TABLE recipes ADD COLUMN calories_per_serving INTEGER;
  END IF;
END $$;

-- 2. RECIPE COPIES — tracks who copied/purchased which recipe
CREATE TABLE IF NOT EXISTS recipe_copies (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  recipe_id UUID NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  is_paid BOOLEAN DEFAULT false,
  amount_cents INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(recipe_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_recipe_copies_recipe ON recipe_copies(recipe_id);
CREATE INDEX IF NOT EXISTS idx_recipe_copies_user ON recipe_copies(user_id);

-- 3. RECIPE BOOKMARKS (save to own collection without copying)
CREATE TABLE IF NOT EXISTS recipe_bookmarks (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  recipe_id UUID NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(recipe_id, user_id)
);

-- 4. RLS policies
ALTER TABLE recipe_copies ENABLE ROW LEVEL SECURITY;
CREATE POLICY "copies_read" ON recipe_copies FOR SELECT USING (true);
CREATE POLICY "copies_insert" ON recipe_copies FOR INSERT WITH CHECK (auth.uid() = user_id);

ALTER TABLE recipe_bookmarks ENABLE ROW LEVEL SECURITY;
CREATE POLICY "bookmarks_read" ON recipe_bookmarks FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "bookmarks_insert" ON recipe_bookmarks FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "bookmarks_delete" ON recipe_bookmarks FOR DELETE USING (auth.uid() = user_id);

-- 5. Allow recipe creators to insert/update their own recipes
CREATE POLICY "recipes_creator_insert" ON recipes FOR INSERT WITH CHECK (auth.uid() = creator_id OR auth.uid() = author_id);
CREATE POLICY "recipes_creator_update" ON recipes FOR UPDATE USING (auth.uid() = creator_id OR auth.uid() = author_id);

-- 6. Helper: check if user has access to a premium recipe
CREATE OR REPLACE FUNCTION has_recipe_access(p_recipe_id UUID, p_user_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
  v_premium BOOLEAN;
  v_creator UUID;
  v_has_copy BOOLEAN;
BEGIN
  SELECT is_premium, creator_id INTO v_premium, v_creator FROM recipes WHERE id = p_recipe_id;
  
  -- Free recipes: everyone has access
  IF NOT v_premium THEN RETURN true; END IF;
  
  -- Creator always has access
  IF v_creator = p_user_id THEN RETURN true; END IF;
  
  -- Check if user has a copy
  SELECT EXISTS(SELECT 1 FROM recipe_copies WHERE recipe_id = p_recipe_id AND user_id = p_user_id) INTO v_has_copy;
  RETURN v_has_copy;
END;
$$ LANGUAGE plpgsql STABLE;
