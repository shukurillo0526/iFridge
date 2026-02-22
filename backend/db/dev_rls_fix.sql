-- ============================================================
-- I-Fridge — Development RLS Fix
-- ============================================================
-- Run this in Supabase SQL Editor to allow the app to read
-- inventory data without authentication (for development only).
--
-- In production, remove these policies and use proper auth.
-- ============================================================

-- Allow anonymous reads on inventory_items (dev only)
CREATE POLICY "inventory_dev_read" ON public.inventory_items
    FOR SELECT USING (true);

-- Allow anonymous reads on gamification_stats (dev only)
CREATE POLICY "stats_dev_read" ON public.gamification_stats
    FOR SELECT USING (true);

-- Allow anonymous reads on user_flavor_profile (dev only)
CREATE POLICY "profile_dev_read" ON public.user_flavor_profile
    FOR SELECT USING (true);

-- Allow anonymous reads on user_recipe_history (dev only)
CREATE POLICY "history_dev_read" ON public.user_recipe_history
    FOR SELECT USING (true);

-- Allow anonymous reads on users table (dev only)
CREATE POLICY "users_dev_read" ON public.users
    FOR SELECT USING (true);

-- Verify: count inventory rows accessible
SELECT count(*) AS inventory_count FROM public.inventory_items;
