-- ============================================================
-- I-Fridge — Inventory Consumption RPC
-- ============================================================
-- Safely decrements the quantity of an inventory item.
-- If the quantity reaches 0, the item is deleted.
-- ============================================================

CREATE OR REPLACE FUNCTION public.consume_inventory_item(
    p_inventory_id UUID,
    p_qty_to_consume NUMERIC
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- 1. Decrement the quantity securely (prevents negative values)
    UPDATE public.inventory_items
    SET quantity = GREATEST(0, quantity - p_qty_to_consume),
        updated_at = NOW()
    WHERE id = p_inventory_id;
    
    -- 2. Cleanup: Delete immediately if quantity hit 0
    DELETE FROM public.inventory_items 
    WHERE id = p_inventory_id AND quantity <= 0;
END;
$$;
