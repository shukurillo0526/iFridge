-- ============================================================
-- I-Fridge — Migration 010: Social / Explore Features
-- ============================================================
-- Posts, likes, bookmarks, and creator profile fields.
-- ============================================================

-- Creator profile fields on users
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS is_creator BOOLEAN DEFAULT FALSE;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS creator_bio TEXT;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS follower_count INT DEFAULT 0;

-- Content posts (videos + recipes)
CREATE TABLE IF NOT EXISTS public.posts (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    author_id       UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    recipe_id       UUID REFERENCES public.recipes(id) ON DELETE SET NULL,
    post_type       TEXT NOT NULL DEFAULT 'recipe', -- 'recipe', 'reel', 'tip'
    video_url       TEXT,                           -- external link (YT/TikTok/IG)
    thumbnail_url   TEXT,
    caption         TEXT,
    tags            TEXT[] DEFAULT '{}',
    view_count      INT DEFAULT 0,
    like_count      INT DEFAULT 0,
    bookmark_count  INT DEFAULT 0,
    is_featured     BOOLEAN DEFAULT FALSE,
    created_at      TIMESTAMPTZ DEFAULT now(),
    updated_at      TIMESTAMPTZ DEFAULT now()
);

-- Post likes
CREATE TABLE IF NOT EXISTS public.post_likes (
    user_id     UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    post_id     UUID NOT NULL REFERENCES public.posts(id) ON DELETE CASCADE,
    created_at  TIMESTAMPTZ DEFAULT now(),
    PRIMARY KEY (user_id, post_id)
);

-- Bookmarks / saves
CREATE TABLE IF NOT EXISTS public.post_bookmarks (
    user_id     UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    post_id     UUID NOT NULL REFERENCES public.posts(id) ON DELETE CASCADE,
    created_at  TIMESTAMPTZ DEFAULT now(),
    PRIMARY KEY (user_id, post_id)
);

-- Follows
CREATE TABLE IF NOT EXISTS public.user_follows (
    follower_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    following_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    created_at  TIMESTAMPTZ DEFAULT now(),
    PRIMARY KEY (follower_id, following_id)
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_posts_author ON public.posts(author_id);
CREATE INDEX IF NOT EXISTS idx_posts_created ON public.posts(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_posts_type ON public.posts(post_type);
CREATE INDEX IF NOT EXISTS idx_post_likes_post ON public.post_likes(post_id);
CREATE INDEX IF NOT EXISTS idx_post_bookmarks_post ON public.post_bookmarks(post_id);

-- RLS policies
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.post_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.post_bookmarks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_follows ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Posts are viewable by everyone" ON public.posts FOR SELECT USING (true);
CREATE POLICY "Users can create posts" ON public.posts FOR INSERT WITH CHECK (auth.uid() = author_id);
CREATE POLICY "Users can update own posts" ON public.posts FOR UPDATE USING (auth.uid() = author_id);
CREATE POLICY "Users can delete own posts" ON public.posts FOR DELETE USING (auth.uid() = author_id);

CREATE POLICY "Likes are viewable by everyone" ON public.post_likes FOR SELECT USING (true);
CREATE POLICY "Users can like" ON public.post_likes FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can unlike" ON public.post_likes FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Bookmarks viewable by owner" ON public.post_bookmarks FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can bookmark" ON public.post_bookmarks FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can unbookmark" ON public.post_bookmarks FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Follows viewable by everyone" ON public.user_follows FOR SELECT USING (true);
CREATE POLICY "Users can follow" ON public.user_follows FOR INSERT WITH CHECK (auth.uid() = follower_id);
CREATE POLICY "Users can unfollow" ON public.user_follows FOR DELETE USING (auth.uid() = follower_id);

-- Seed a few sample posts for testing
INSERT INTO public.posts (author_id, post_type, caption, tags, video_url) VALUES
  ((SELECT id FROM public.users LIMIT 1), 'reel', '🍚 Perfect Plov in 30 minutes! Watch the secret technique.', ARRAY['plov', 'uzbek', 'rice'], 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'),
  ((SELECT id FROM public.users LIMIT 1), 'tip', '🧅 Caramelize onions like a pro — low and slow is the key!', ARRAY['tips', 'onions', 'technique'], NULL),
  ((SELECT id FROM public.users LIMIT 1), 'recipe', '🍪 My grandma''s chocolate chip cookies recipe', ARRAY['cookies', 'baking', 'dessert'], NULL)
ON CONFLICT DO NOTHING;
