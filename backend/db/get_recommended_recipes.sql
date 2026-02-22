-- I-Fridge — Phase 3: Recommendation Engine RPC
-- 
-- Weighted matching system:
-- 40% Inventory Match (Exact & Semantic fallback)
-- 30% User Preference (pgvector similarity against user_recipe_history flavors)
-- 30% Expiry Urgency (Bonus for recipes using ingredients expiring soon)

CREATE OR REPLACE FUNCTION public.get_recommended_recipes(p_user_id UUID, p_limit INT DEFAULT 20)
RETURNS TABLE (
    recipe_id UUID,
    title TEXT,
    match_score NUMERIC
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    WITH UserInventory AS (
        SELECT i.ingredient_id, m.category, i.expiry_date
        FROM public.inventory_items i
        JOIN public.master_ingredients m ON i.ingredient_id = m.id
        WHERE i.user_id = p_user_id AND i.quantity > 0
    ),
    RecipeScores AS (
        SELECT 
            r.id,
            r.title,
            -- Calculate Inventory Match Score (Subquery)
            (
                SELECT COALESCE(COUNT(ri.ingredient_id)::NUMERIC / NULLIF((SELECT COUNT(*) FROM recipe_ingredients WHERE recipe_id = r.id), 0), 0)
                FROM recipe_ingredients ri
                WHERE ri.recipe_id = r.id AND ri.ingredient_id IN (SELECT ingredient_id FROM UserInventory)
            ) AS inventory_match,
            -- Calculate Expiry Urgency Score (Subquery)
            (
                SELECT COALESCE(COUNT(ri.ingredient_id)::NUMERIC / NULLIF((SELECT COUNT(*) FROM recipe_ingredients WHERE recipe_id = r.id), 0), 0)
                FROM recipe_ingredients ri
                JOIN UserInventory ui ON ri.ingredient_id = ui.ingredient_id
                WHERE ri.recipe_id = r.id AND ui.expiry_date <= CURRENT_DATE + INTERVAL '3 days'
            ) AS expiry_urgency
            
            -- Note: Real pgvector preference logic would be joined here 
            -- (e.g. 1 - (r.flavor_vector <=> UserProfileVector))
        FROM public.recipes r
    )
    SELECT 
        rs.id AS recipe_id,
        rs.title,
        -- Weighted Final Score (Simplified for MVP, assuming vector score = 0.5 static for now)
        ROUND(
            (rs.inventory_match * 0.40) + 
            (0.50 * 0.30) + 
            (rs.expiry_urgency * 0.30)
        , 2) AS match_score
    FROM RecipeScores rs
    ORDER BY match_score DESC
    LIMIT p_limit;
END;
$$;
