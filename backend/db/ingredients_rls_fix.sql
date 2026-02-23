-- Fix Manual Add: Allow authenticated users to insert new ingredients
CREATE POLICY "ingredients_auth_insert" ON public.ingredients
    FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
