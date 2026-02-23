-- ============================================================
-- Supabase Trigger: Auto-Initialize User Profiles
-- ============================================================

-- Function to handle new user signups from Supabase Auth
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  -- Insert into public.users
  INSERT INTO public.users (id, email, display_name)
  VALUES (new.id, new.email, COALESCE(new.raw_user_meta_data->>'full_name', split_part(new.email, '@', 1)));

  -- Initialize Gamification Stats (Level 1, 0 XP)
  INSERT INTO public.gamification_stats (user_id)
  VALUES (new.id);

  -- Initialize default Flavor Profile
  INSERT INTO public.user_flavor_profile (user_id)
  VALUES (new.id);

  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger watching for new auth.users
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
