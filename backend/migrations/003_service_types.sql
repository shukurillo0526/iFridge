-- ═══════════════════════════════════════════════════════════════════
-- I-Fridge — Service Types Migration (Addendum)
-- ═══════════════════════════════════════════════════════════════════
-- Run this AFTER 002_order_mode_schema.sql to add service types.
-- Adds has_delivery, has_reservation, has_dine_in columns and
-- sets realistic values per restaurant.
--
-- If you already ran 002 before these columns existed, run this file.
-- If you're starting fresh, 002 already includes the columns.
-- ═══════════════════════════════════════════════════════════════════

-- Add columns if not exist (safe to re-run)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'restaurants' AND column_name = 'has_delivery') THEN
    ALTER TABLE restaurants ADD COLUMN has_delivery boolean DEFAULT true;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'restaurants' AND column_name = 'has_reservation') THEN
    ALTER TABLE restaurants ADD COLUMN has_reservation boolean DEFAULT false;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'restaurants' AND column_name = 'has_dine_in') THEN
    ALTER TABLE restaurants ADD COLUMN has_dine_in boolean DEFAULT true;
  END IF;
END $$;

-- ═══════ Set service types per restaurant ═══════

-- Asaka — delivery + dine-in restaurants (most local places)
UPDATE restaurants SET has_delivery = true, has_reservation = false, has_dine_in = true
WHERE name IN ('Xotambek', 'Al-Aziz', 'Choyxona Sabo', 'Choyxona Turon', 'Café Lagmanni', 'Ahmad Aka Choyxonasi', 'Asaka Burger');

-- Asaka — dine-in + reservation (event venues / fancy)
UPDATE restaurants SET has_delivery = false, has_reservation = true, has_dine_in = true
WHERE name IN ('Huzur Restaurant', 'To''raxon');

-- Asaka — all three (modern cafes)
UPDATE restaurants SET has_delivery = true, has_reservation = true, has_dine_in = true
WHERE name IN ('Palma Café', 'Sharq Restaurant', 'Obi-Rohat');

-- Tashkent — delivery only (fast food / plov centers)  
UPDATE restaurants SET has_delivery = true, has_reservation = false, has_dine_in = true
WHERE name IN ('Osh Markazi', 'Burger Lab', 'Lagman House', 'The Plov Center', 'Mama Dumplings', 'Taco Amigos', 'Tandoor Express', 'Ice Cream Lab', 'Manti Palace', 'Asaka Burger', 'Naan Stop');

-- Tashkent — delivery + reservation (sit-down restaurants)
UPDATE restaurants SET has_delivery = true, has_reservation = true, has_dine_in = true
WHERE name IN ('Kimchi House', 'Seoul BBQ', 'Café Mia', 'Mediterranean Grill', 'Samarkand Kitchen');

-- Tashkent — all three (healthy/modern spots)
UPDATE restaurants SET has_delivery = true, has_reservation = true, has_dine_in = true
WHERE name IN ('Green Bowl Tashkent', 'Sushi Tokyo', 'Bento Box');

-- Tashkent — reservation only (premium / pizza)
UPDATE restaurants SET has_delivery = true, has_reservation = true, has_dine_in = true
WHERE name IN ('Pizza Hut Yunusabad');

-- ═══════ Add single-service restaurants for variety ═══════

-- DELIVERY-ONLY (cloud kitchens, no dine-in)
INSERT INTO restaurants (name, description, cuisine_type, price_range, rating, review_count, location, address, tags, avg_prep_minutes, delivery_fee, has_delivery, has_reservation, has_dine_in, is_open)
VALUES
('Oqtepa Lavash Asaka', 'Delivery-only lavash wraps and combos. Fast and affordable.',
 ARRAY['Fast Food', 'Uzbek'], 1, 4.3, 156,
 ST_MakePoint(72.250, 40.660)::geography, 'Asaka Center',
 ARRAY['delivery-only', 'fast', 'wraps', 'budget'], 10, 3000, true, false, false, true),

('YoKi Sushi Asaka', 'Premium sushi delivery. Fresh rolls and combo sets.',
 ARRAY['Japanese', 'Sushi'], 2, 4.6, 89,
 ST_MakePoint(72.247, 40.664)::geography, 'Asaka',
 ARRAY['delivery-only', 'sushi', 'japanese', 'premium'], 25, 5000, true, false, false, true);

-- RESERVATION-ONLY (banquet halls, event venues)
INSERT INTO restaurants (name, description, cuisine_type, price_range, rating, review_count, location, address, tags, avg_prep_minutes, delivery_fee, has_delivery, has_reservation, has_dine_in, is_open)
VALUES
('Milliy Taomlar Saroyi', 'Grand banquet hall for weddings and celebrations. Reservation required.',
 ARRAY['Uzbek', 'Traditional'], 3, 4.7, 320,
 ST_MakePoint(72.242, 40.662)::geography, 'Asaka, Stadion yoni',
 ARRAY['events', 'wedding', 'reservation-only', 'premium'], 45, 0, false, true, false, true),

('Nurafshon To''yxonasi', 'Elegant event hall with traditional Uzbek cuisine. Book in advance.',
 ARRAY['Uzbek', 'Traditional'], 3, 4.5, 245,
 ST_MakePoint(72.253, 40.668)::geography, 'Yangi Turmush ko''chasi, Asaka',
 ARRAY['events', 'banquet', 'reservation-only', 'traditional'], 40, 0, false, true, false, true);

-- DINE-IN ONLY (street food, no delivery or reservation)
INSERT INTO restaurants (name, description, cuisine_type, price_range, rating, review_count, location, address, tags, avg_prep_minutes, delivery_fee, has_delivery, has_reservation, has_dine_in, is_open)
VALUES
('Bozor Somsa', 'Famous bazaar somsa spot. Eat fresh at the counter. No delivery.',
 ARRAY['Uzbek', 'Home Food'], 1, 4.9, 567,
 ST_MakePoint(72.249, 40.666)::geography, 'Asaka Bozori',
 ARRAY['dine-in-only', 'somsa', 'famous', 'bazaar', 'street-food'], 5, 0, false, false, true, true),

('Shashlik Master', 'Open-grill kebab spot near the park. Come and eat on-site.',
 ARRAY['Uzbek', 'BBQ'], 1, 4.7, 412,
 ST_MakePoint(72.244, 40.663)::geography, 'Bogibuston parki, Asaka',
 ARRAY['dine-in-only', 'shashlik', 'bbq', 'outdoor', 'street-food'], 15, 0, false, false, true, true);

-- ═══════ Update the RPC to include service types ═══════
-- Must drop first because return type changed (added 3 new columns)
DROP FUNCTION IF EXISTS nearby_restaurants(float, float, int, text[], int);

CREATE OR REPLACE FUNCTION nearby_restaurants(
  user_lat float,
  user_long float,
  radius_m int DEFAULT 2000,
  cuisine_filter text[] DEFAULT NULL,
  price_filter int DEFAULT NULL
)
RETURNS TABLE (
  id uuid, name text, description text,
  cuisine_type text[], price_range int,
  rating numeric, review_count int,
  address text, image_url text,
  is_open boolean, avg_prep_minutes int,
  delivery_fee numeric, tags text[],
  has_delivery boolean, has_reservation boolean, has_dine_in boolean,
  dist_meters float, latitude float, longitude float
)
LANGUAGE sql STABLE
AS $$
  SELECT
    r.id, r.name, r.description,
    r.cuisine_type, r.price_range,
    r.rating, r.review_count,
    r.address, r.image_url,
    r.is_open, r.avg_prep_minutes,
    r.delivery_fee, r.tags,
    r.has_delivery, r.has_reservation, r.has_dine_in,
    ST_Distance(r.location, ST_MakePoint(user_long, user_lat)::geography)::float as dist_meters,
    ST_Y(r.location::geometry)::float as latitude,
    ST_X(r.location::geometry)::float as longitude
  FROM restaurants r
  WHERE ST_DWithin(r.location, ST_MakePoint(user_long, user_lat)::geography, radius_m)
    AND (cuisine_filter IS NULL OR r.cuisine_type && cuisine_filter)
    AND (price_filter IS NULL OR r.price_range <= price_filter)
  ORDER BY r.location <-> ST_MakePoint(user_long, user_lat)::geography;
$$;

SELECT 'Service types added! ' || count(*) || ' restaurants updated.' as result FROM restaurants WHERE has_delivery IS NOT NULL;
