-- ============================================================
-- I-Fridge — Cleanup: Remove duplicate inventory items
-- ============================================================
-- Run this ONCE if you have duplicate entries from before the
-- upsert fix. Keeps the row with the highest quantity.
-- ============================================================

DELETE FROM public.inventory_items
WHERE id NOT IN (
    SELECT DISTINCT ON (user_id, ingredient_id, location) id
    FROM public.inventory_items
    ORDER BY user_id, ingredient_id, location, quantity DESC
);
