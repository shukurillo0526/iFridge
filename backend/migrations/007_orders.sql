-- I-Fridge — Phase 1: Orders Table
-- ===================================
-- Supports mobile ordering (pickup + delivery).
-- Used by: iFridge consumer app, future iFridge Business dashboard.
--
-- Run in Supabase SQL Editor or via migration tool.

-- ── Orders Table ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS orders (
    id              UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id         UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    restaurant_id   UUID NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
    
    -- Order details
    type            TEXT NOT NULL DEFAULT 'pickup' CHECK (type IN ('pickup', 'delivery')),
    status          TEXT NOT NULL DEFAULT 'confirmed' CHECK (status IN (
        'confirmed',       -- Order placed, payment pending/done
        'preparing',       -- Restaurant is cooking
        'ready',           -- Ready for pickup / waiting for driver
        'picked_up',       -- Driver picked up (delivery only)
        'delivering',      -- En route to customer (delivery only)
        'completed',       -- Customer received order
        'cancelled'        -- Cancelled by customer or restaurant
    )),
    pickup_code     TEXT,           -- e.g. "AB742" — shown at counter
    
    -- Items (JSONB array of {menu_item_id, name, price, quantity, special_instructions, subtotal})
    items           JSONB NOT NULL DEFAULT '[]',
    
    -- Pricing
    subtotal        DECIMAL(12,2) NOT NULL DEFAULT 0,
    delivery_fee    DECIMAL(12,2) NOT NULL DEFAULT 0,
    total           DECIMAL(12,2) NOT NULL DEFAULT 0,
    
    -- Timing
    estimated_minutes INT DEFAULT 20,
    created_at      TIMESTAMPTZ DEFAULT now(),
    confirmed_at    TIMESTAMPTZ,
    ready_at        TIMESTAMPTZ,
    completed_at    TIMESTAMPTZ,
    cancelled_at    TIMESTAMPTZ,
    
    -- Delivery (nullable — only for delivery orders)
    delivery_address    TEXT,
    delivery_latitude   DOUBLE PRECISION,
    delivery_longitude  DOUBLE PRECISION,
    driver_id           UUID,           -- future: references drivers table
    
    -- Notes
    customer_note   TEXT,
    cancel_reason   TEXT
);

-- ── Indexes ──────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_restaurant_id ON orders(restaurant_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON orders(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_orders_pickup_code ON orders(pickup_code);

-- ── RLS (Row-Level Security) ─────────────────────────────────────
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

-- Users can read their own orders
CREATE POLICY "Users can read own orders"
    ON orders FOR SELECT
    USING (auth.uid() = user_id);

-- Users can create orders
CREATE POLICY "Users can create orders"
    ON orders FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Users can cancel their own orders (update status to 'cancelled')
CREATE POLICY "Users can update own orders"
    ON orders FOR UPDATE
    USING (auth.uid() = user_id);

-- Service role can do anything (for backend API)
CREATE POLICY "Service role full access"
    ON orders FOR ALL
    USING (auth.role() = 'service_role');

-- ── Function: Get user's order history ───────────────────────────
CREATE OR REPLACE FUNCTION get_user_orders(
    p_user_id UUID,
    p_limit INT DEFAULT 20,
    p_offset INT DEFAULT 0
)
RETURNS TABLE (
    id UUID,
    restaurant_id UUID,
    restaurant_name TEXT,
    type TEXT,
    status TEXT,
    pickup_code TEXT,
    items JSONB,
    subtotal DECIMAL,
    delivery_fee DECIMAL,
    total DECIMAL,
    estimated_minutes INT,
    created_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        o.id,
        o.restaurant_id,
        r.name AS restaurant_name,
        o.type,
        o.status,
        o.pickup_code,
        o.items,
        o.subtotal,
        o.delivery_fee,
        o.total,
        o.estimated_minutes,
        o.created_at,
        o.completed_at
    FROM orders o
    LEFT JOIN restaurants r ON r.id = o.restaurant_id
    WHERE o.user_id = p_user_id
    ORDER BY o.created_at DESC
    LIMIT p_limit
    OFFSET p_offset;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
