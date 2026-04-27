-- ═══════════════════════════════════════════════════════════════
-- iFridge Social Media Tables — Migration
-- Run this in Supabase SQL Editor (https://supabase.com/dashboard)
-- ═══════════════════════════════════════════════════════════════

-- 1. FOLLOWS (Social Graph)
CREATE TABLE IF NOT EXISTS follows (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  follower_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  following_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(follower_id, following_id)
);

CREATE INDEX IF NOT EXISTS idx_follows_follower ON follows(follower_id);
CREATE INDEX IF NOT EXISTS idx_follows_following ON follows(following_id);

-- 2. POST LIKES
CREATE TABLE IF NOT EXISTS post_likes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(post_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_post_likes_post ON post_likes(post_id);
CREATE INDEX IF NOT EXISTS idx_post_likes_user ON post_likes(user_id);

-- 3. COMMENTS
CREATE TABLE IF NOT EXISTS post_comments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  author_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  body TEXT NOT NULL,
  parent_comment_id UUID REFERENCES post_comments(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_comments_post ON post_comments(post_id);
CREATE INDEX IF NOT EXISTS idx_comments_author ON post_comments(author_id);

-- 4. STORIES (24h ephemeral)
CREATE TABLE IF NOT EXISTS stories (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  author_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  media_url TEXT NOT NULL,
  media_type TEXT DEFAULT 'image',
  caption TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  expires_at TIMESTAMPTZ DEFAULT (now() + INTERVAL '24 hours')
);

CREATE TABLE IF NOT EXISTS story_views (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  story_id UUID NOT NULL REFERENCES stories(id) ON DELETE CASCADE,
  viewer_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  viewed_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(story_id, viewer_id)
);

CREATE INDEX IF NOT EXISTS idx_stories_author ON stories(author_id);
CREATE INDEX IF NOT EXISTS idx_stories_expires ON stories(expires_at);

-- 5. BUSINESS ACCOUNTS (for Order mode restaurant content)
CREATE TABLE IF NOT EXISTS business_accounts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  business_name TEXT NOT NULL,
  business_type TEXT DEFAULT 'restaurant',
  is_verified BOOLEAN DEFAULT false,
  logo_url TEXT,
  cover_url TEXT,
  description TEXT,
  location_name TEXT,
  location_lat DOUBLE PRECISION,
  location_lng DOUBLE PRECISION,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id)
);

-- 6. ENHANCE EXISTING `posts` TABLE
-- Add columns for media, location, and visibility
DO $$
BEGIN
  -- Media URLs array (Supabase Storage URLs)
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='posts' AND column_name='media_urls') THEN
    ALTER TABLE posts ADD COLUMN media_urls TEXT[] DEFAULT '{}';
  END IF;

  -- Location info
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='posts' AND column_name='location_name') THEN
    ALTER TABLE posts ADD COLUMN location_name TEXT;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='posts' AND column_name='location_lat') THEN
    ALTER TABLE posts ADD COLUMN location_lat DOUBLE PRECISION;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='posts' AND column_name='location_lng') THEN
    ALTER TABLE posts ADD COLUMN location_lng DOUBLE PRECISION;
  END IF;

  -- Recipe link
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='posts' AND column_name='recipe_id') THEN
    ALTER TABLE posts ADD COLUMN recipe_id UUID;
  END IF;

  -- Restaurant link
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='posts' AND column_name='restaurant_id') THEN
    ALTER TABLE posts ADD COLUMN restaurant_id UUID;
  END IF;

  -- Visibility (public, friends, private)
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='posts' AND column_name='visibility') THEN
    ALTER TABLE posts ADD COLUMN visibility TEXT DEFAULT 'public';
  END IF;

  -- Comment count (denormalized for performance)
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='posts' AND column_name='comment_count') THEN
    ALTER TABLE posts ADD COLUMN comment_count INTEGER DEFAULT 0;
  END IF;
END $$;

-- 7. RLS (Row Level Security) Policies
-- Allow authenticated users to read all public posts
ALTER TABLE follows ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE stories ENABLE ROW LEVEL SECURITY;
ALTER TABLE story_views ENABLE ROW LEVEL SECURITY;
ALTER TABLE business_accounts ENABLE ROW LEVEL SECURITY;

-- Follows: anyone can read, authenticated can manage their own
CREATE POLICY "follows_read" ON follows FOR SELECT USING (true);
CREATE POLICY "follows_insert" ON follows FOR INSERT WITH CHECK (auth.uid() = follower_id);
CREATE POLICY "follows_delete" ON follows FOR DELETE USING (auth.uid() = follower_id);

-- Post likes: anyone can read, authenticated can manage their own
CREATE POLICY "likes_read" ON post_likes FOR SELECT USING (true);
CREATE POLICY "likes_insert" ON post_likes FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "likes_delete" ON post_likes FOR DELETE USING (auth.uid() = user_id);

-- Comments: anyone can read, authenticated can create/delete their own
CREATE POLICY "comments_read" ON post_comments FOR SELECT USING (true);
CREATE POLICY "comments_insert" ON post_comments FOR INSERT WITH CHECK (auth.uid() = author_id);
CREATE POLICY "comments_delete" ON post_comments FOR DELETE USING (auth.uid() = author_id);

-- Stories: anyone can read non-expired, authenticated can create their own
CREATE POLICY "stories_read" ON stories FOR SELECT USING (expires_at > now());
CREATE POLICY "stories_insert" ON stories FOR INSERT WITH CHECK (auth.uid() = author_id);
CREATE POLICY "stories_delete" ON stories FOR DELETE USING (auth.uid() = author_id);

-- Story views: anyone can read, authenticated can create
CREATE POLICY "story_views_read" ON story_views FOR SELECT USING (true);
CREATE POLICY "story_views_insert" ON story_views FOR INSERT WITH CHECK (auth.uid() = viewer_id);

-- Business accounts: anyone can read, owner can manage
CREATE POLICY "business_read" ON business_accounts FOR SELECT USING (true);
CREATE POLICY "business_manage" ON business_accounts FOR ALL USING (auth.uid() = user_id);

-- 8. Helper function: get follower count
CREATE OR REPLACE FUNCTION get_follower_count(target_user_id UUID)
RETURNS INTEGER AS $$
  SELECT COUNT(*)::INTEGER FROM follows WHERE following_id = target_user_id;
$$ LANGUAGE SQL STABLE;

-- 9. Helper function: get following count
CREATE OR REPLACE FUNCTION get_following_count(target_user_id UUID)
RETURNS INTEGER AS $$
  SELECT COUNT(*)::INTEGER FROM follows WHERE follower_id = target_user_id;
$$ LANGUAGE SQL STABLE;

-- 10. Create storage bucket for post media
-- NOTE: Run this separately or via Supabase Dashboard → Storage → New Bucket
-- Bucket name: post-media
-- Public: true
-- Max file size: 10MB
-- Allowed MIME types: image/jpeg, image/png, image/webp, video/mp4
