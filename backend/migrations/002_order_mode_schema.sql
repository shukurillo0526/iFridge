-- ═══════════════════════════════════════════════════════════════════
-- I-Fridge — Order Mode Database Schema
-- ═══════════════════════════════════════════════════════════════════
-- PostGIS-powered tables for geo-filtered restaurant discovery,
-- menu items, food orders, seat bookings, and reviews.
-- 
-- Run this in the Supabase SQL Editor (Dashboard → SQL Editor → New Query)
-- ═══════════════════════════════════════════════════════════════════

-- ── 1. Enable PostGIS ────────────────────────────────────────────
CREATE EXTENSION IF NOT EXISTS postgis;

-- ── 2. Regions ───────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.regions (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  name text NOT NULL,
  name_local text,
  center geography(POINT) NOT NULL,
  city text NOT NULL,
  country text DEFAULT 'UZ',
  created_at timestamptz DEFAULT now()
);

-- ── 3. Restaurants ───────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.restaurants (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  owner_id uuid REFERENCES auth.users(id),
  name text NOT NULL,
  description text,
  cuisine_type text[] DEFAULT '{}',
  price_range int DEFAULT 1 CHECK (price_range >= 1 AND price_range <= 3),
  rating numeric(2,1) DEFAULT 0,
  review_count int DEFAULT 0,
  location geography(POINT) NOT NULL,
  address text,
  region_id uuid REFERENCES regions(id),
  phone text,
  image_url text,
  is_open boolean DEFAULT true,
  opening_hours jsonb,
  avg_prep_minutes int DEFAULT 20,
  delivery_fee numeric(12,2) DEFAULT 0,
  delivery_radius_meters int DEFAULT 5000,
  has_delivery boolean DEFAULT true,
  has_reservation boolean DEFAULT false,
  has_dine_in boolean DEFAULT true,
  tags text[] DEFAULT '{}',
  created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS restaurants_geo_idx ON restaurants USING GIST (location);
CREATE INDEX IF NOT EXISTS restaurants_region_idx ON restaurants(region_id);
CREATE INDEX IF NOT EXISTS restaurants_open_idx ON restaurants(is_open);

-- ── 4. Menu Items ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.menu_items (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  restaurant_id uuid REFERENCES restaurants(id) ON DELETE CASCADE,
  name text NOT NULL,
  description text,
  price numeric(8,2) NOT NULL,
  image_url text,
  category text DEFAULT 'Main',
  is_available boolean DEFAULT true,
  calories int,
  tags text[] DEFAULT '{}',
  sort_order int DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS menu_restaurant_idx ON menu_items(restaurant_id);

-- ── 5. Restaurant Reviews ────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.restaurant_reviews (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  restaurant_id uuid REFERENCES restaurants(id) ON DELETE CASCADE,
  user_id uuid REFERENCES auth.users(id),
  rating int NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment text,
  photo_urls text[] DEFAULT '{}',
  created_at timestamptz DEFAULT now()
);

-- ── 6. Food Orders ──────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.food_orders (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id uuid REFERENCES auth.users(id),
  restaurant_id uuid REFERENCES restaurants(id),
  items jsonb NOT NULL DEFAULT '[]',
  total_amount numeric(10,2) NOT NULL DEFAULT 0,
  delivery_fee numeric(12,2) DEFAULT 0,
  status text DEFAULT 'pending',
  delivery_address text,
  delivery_location geography(POINT),
  estimated_delivery_minutes int,
  notes text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- ── 7. Seat Bookings ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.seat_bookings (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id uuid REFERENCES auth.users(id),
  restaurant_id uuid REFERENCES restaurants(id),
  party_size int NOT NULL DEFAULT 1,
  booking_time timestamptz NOT NULL,
  status text DEFAULT 'pending',
  notes text,
  created_at timestamptz DEFAULT now()
);

-- ── 8. RPC: Nearby Restaurants ──────────────────────────────────
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

-- ── 8b. RPC: Get Regions with Coordinates ───────────────────────
CREATE OR REPLACE FUNCTION get_regions_with_coords()
RETURNS TABLE (
  id uuid, name text, name_local text,
  city text, country text,
  latitude float, longitude float
)
LANGUAGE sql STABLE
AS $$
  SELECT
    r.id, r.name, r.name_local,
    r.city, r.country,
    ST_Y(r.center::geometry)::float as latitude,
    ST_X(r.center::geometry)::float as longitude
  FROM regions r
  ORDER BY r.name;
$$;

-- ── 9. RLS Policies ─────────────────────────────────────────────
ALTER TABLE restaurants ENABLE ROW LEVEL SECURITY;
ALTER TABLE menu_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE restaurant_reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE food_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE seat_bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE regions ENABLE ROW LEVEL SECURITY;

-- Everyone can read restaurants and menus
CREATE POLICY "Anyone can view restaurants" ON restaurants FOR SELECT USING (true);
CREATE POLICY "Anyone can view menu items" ON menu_items FOR SELECT USING (true);
CREATE POLICY "Anyone can view regions" ON regions FOR SELECT USING (true);
CREATE POLICY "Anyone can view reviews" ON restaurant_reviews FOR SELECT USING (true);

-- Users can manage their own orders and bookings
CREATE POLICY "Users manage own orders" ON food_orders FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users manage own bookings" ON seat_bookings FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can write reviews" ON restaurant_reviews FOR INSERT WITH CHECK (auth.uid() = user_id);


-- ═══════════════════════════════════════════════════════════════════
-- SEED DATA: Asaka + Tashkent Restaurants
-- ═══════════════════════════════════════════════════════════════════
-- Restaurants in Asaka (40.6624°N, 72.2482°E) and Tashkent.
-- Asaka restaurants will appear first for users in Asaka.

-- ── Regions ──────────────────────────────────────────────────────
INSERT INTO regions (name, name_local, center, city, country) VALUES
  -- Asaka
  ('Asaka', 'Асака', ST_MakePoint(72.248, 40.662)::geography, 'Asaka', 'UZ'),
  ('Asaka Center', 'Асака Маркази', ST_MakePoint(72.245, 40.665)::geography, 'Asaka', 'UZ'),
  -- Tashkent
  ('Chilanzar', 'Чиланзар', ST_MakePoint(69.219, 41.286)::geography, 'Tashkent', 'UZ'),
  ('Mirzo Ulugbek', 'Мирзо Улуғбек', ST_MakePoint(69.335, 41.338)::geography, 'Tashkent', 'UZ'),
  ('Yunusabad', 'Юнусобод', ST_MakePoint(69.283, 41.358)::geography, 'Tashkent', 'UZ'),
  ('Sergeli', 'Сергели', ST_MakePoint(69.224, 41.237)::geography, 'Tashkent', 'UZ'),
  ('Yakkasaray', 'Яккасарой', ST_MakePoint(69.266, 41.289)::geography, 'Tashkent', 'UZ'),
  ('Shayhontohur', 'Шайхонтоҳур', ST_MakePoint(69.232, 41.326)::geography, 'Tashkent', 'UZ'),
  ('Tashkent City', 'Тошкент Сити', ST_MakePoint(69.279, 41.311)::geography, 'Tashkent', 'UZ')
ON CONFLICT DO NOTHING;

-- ── Restaurants ──────────────────────────────────────────────────
-- Using real Tashkent coordinates spread across different neighborhoods

INSERT INTO restaurants (name, description, cuisine_type, price_range, rating, review_count, location, address, tags, avg_prep_minutes, delivery_fee, has_delivery, has_reservation, has_dine_in, is_open) VALUES

-- ═══════ ASAKA RESTAURANTS ═══════
-- Center: 40.6624°N, 72.2482°E — spread within 2-5km

('Xotambek', 'Open 24/7. One of Asaka''s most popular cafés — plov, lagman, kebab, and more.',
 ARRAY['Uzbek', 'Traditional'], 1, 4.7, 234,
 ST_MakePoint(72.248, 40.663)::geography, 'Imam Bukhari ko''chasi, Asaka',
 ARRAY['budget', 'traditional', '24/7', 'popular'], 15, 5000, true),

('Al-Aziz', 'Cozy restaurant on Amir Temur street. Known for grilled meats and fresh salads.',
 ARRAY['Uzbek', 'BBQ'], 1, 4.5, 178,
 ST_MakePoint(72.250, 40.665)::geography, 'Amir Temur ko''chasi, Asaka',
 ARRAY['budget', 'bbq', 'kebab', 'halal'], 20, 5000, true),

('Palma Café', 'Modern café with Uzbek and European dishes. Great for family dinners.',
 ARRAY['Uzbek', 'European'], 2, 4.4, 156,
 ST_MakePoint(72.252, 40.664)::geography, 'Amir Temur ko''chasi, Asaka',
 ARRAY['cafe', 'family', 'european'], 20, 7000, true),

('Huzur Restaurant', 'Traditional Uzbek restaurant on Umid street. Wedding and event venue.',
 ARRAY['Uzbek', 'Traditional'], 1, 4.6, 201,
 ST_MakePoint(72.244, 40.660)::geography, 'Umid ko''chasi, Asaka',
 ARRAY['traditional', 'events', 'family', 'halal'], 25, 5000, true),

('Choyxona Sabo', 'Traditional teahouse on Fidoiy street. Best shurpa and somsa in town.',
 ARRAY['Uzbek', 'Home Food'], 1, 4.8, 312,
 ST_MakePoint(72.246, 40.668)::geography, 'Fidoiy ko''chasi, Asaka',
 ARRAY['budget', 'traditional', 'tea', 'somsa'], 15, 3000, true),

('Choyxona Turon', 'Classic Asaka choyxona. Relaxing atmosphere with traditional Uzbek meals.',
 ARRAY['Uzbek', 'Traditional'], 1, 4.5, 145,
 ST_MakePoint(72.243, 40.667)::geography, 'Fidoiy ko''chasi, Asaka',
 ARRAY['budget', 'traditional', 'choyxona'], 20, 3000, true),

('Café Lagmanni', 'Famous for hand-pulled lagman noodles. Open 24/7.',
 ARRAY['Uzbek', 'Noodles'], 1, 4.9, 423,
 ST_MakePoint(72.249, 40.661)::geography, 'Asaka Center',
 ARRAY['lagman', 'noodles', 'budget', '24/7', 'famous'], 10, 3000, true),

('Sharq Restaurant', 'Elegant restaurant serving premium Uzbek cuisine. Great for special occasions.',
 ARRAY['Uzbek', 'Regional'], 2, 4.6, 189,
 ST_MakePoint(72.251, 40.666)::geography, 'Asaka',
 ARRAY['premium', 'traditional', 'events'], 25, 7000, true),

('Obi-Rohat', 'Relaxing spot near water. Fresh fish, plov, and grilled dishes.',
 ARRAY['Uzbek', 'Seafood'], 2, 4.3, 134,
 ST_MakePoint(72.240, 40.659)::geography, 'Asaka',
 ARRAY['fish', 'outdoor', 'family'], 30, 5000, true),

('Ahmad Aka Choyxonasi', 'Legendary local choyxona. Try the famous tandir somsa and lamb plov.',
 ARRAY['Uzbek', 'Traditional'], 1, 4.8, 367,
 ST_MakePoint(72.247, 40.670)::geography, 'Asaka',
 ARRAY['budget', 'traditional', 'somsa', 'famous', 'plov'], 15, 3000, true),

('Asaka Burger', 'Modern burger and fast food spot. Crispy chicken, burgers, and fries.',
 ARRAY['Fast Food', 'American'], 1, 4.2, 198,
 ST_MakePoint(72.253, 40.663)::geography, 'Asaka Center',
 ARRAY['fast-food', 'burgers', 'delivery', 'budget'], 10, 5000, true),

('To''raxon', 'Beautiful venue on Sohil bo''yi. Perfect for gatherings with great food.',
 ARRAY['Uzbek', 'Traditional'], 2, 4.5, 156,
 ST_MakePoint(72.238, 40.658)::geography, 'Sohil bo''yi ko''chasi, Asaka',
 ARRAY['events', 'traditional', 'family', 'outdoor'], 25, 7000, true),

-- ═══════ TASHKENT RESTAURANTS ═══════
-- Chilanzar area
('Osh Markazi', 'Authentic Uzbek plov center. Traditional recipe, slow-cooked for 3 hours with tender lamb.', 
 ARRAY['Uzbek', 'Traditional'], 1, 4.8, 342,
 ST_MakePoint(69.219, 41.286)::geography, 'Chilanzar 7, Tashkent',
 ARRAY['budget', 'traditional', 'lunch', 'plov'], 15, 5000, true),

('Choyxona Shifo', 'Traditional teahouse with homestyle Uzbek dishes. Family-friendly atmosphere.',
 ARRAY['Uzbek', 'Home Food'], 1, 4.6, 189,
 ST_MakePoint(69.215, 41.284)::geography, 'Chilanzar 4, Tashkent',
 ARRAY['budget', 'family', 'traditional', 'halal'], 20, 5000, true),

('Burger Lab', 'Gourmet burgers with creative toppings. Best smash burgers in the area.',
 ARRAY['Fast Food', 'American'], 2, 4.4, 256,
 ST_MakePoint(69.222, 41.288)::geography, 'Chilanzar 9, Tashkent',
 ARRAY['fast-food', 'burgers', 'delivery'], 15, 8000, true),

-- Mirzo Ulugbek area
('Kimchi House', 'Korean home cooking with authentic recipes. Bibimbap, kimchi-jjigae, and more.',
 ARRAY['Korean', 'Asian'], 2, 4.7, 198,
 ST_MakePoint(69.335, 41.340)::geography, 'Mirzo Ulugbek, Tashkent',
 ARRAY['korean', 'spicy', 'healthy'], 25, 10000, true),

('Sushi Tokyo', 'Fresh sushi and Japanese cuisine. Salmon rolls, ramen, and bento boxes.',
 ARRAY['Japanese', 'Sushi'], 2, 4.5, 167,
 ST_MakePoint(69.330, 41.335)::geography, 'Mirzo Ulugbek, Tashkent',
 ARRAY['japanese', 'sushi', 'healthy'], 30, 12000, true),

('Green Bowl Tashkent', 'Healthy salads, grain bowls, and smoothies. Under 500 calories per meal.',
 ARRAY['Healthy', 'Salads', 'Vegan'], 2, 4.7, 312,
 ST_MakePoint(69.332, 41.337)::geography, 'Mirzo Ulugbek, Tashkent',
 ARRAY['healthy', 'vegan', 'diet', 'bowls'], 15, 8000, true),

-- Yunusabad area
('Naan Stop', 'Indian and Central Asian fusion. Butter chicken, naan, tandoori, and more.',
 ARRAY['Indian', 'Halal', 'Asian'], 1, 4.5, 145,
 ST_MakePoint(69.280, 41.355)::geography, 'Yunusabad 11, Tashkent',
 ARRAY['indian', 'halal', 'spicy', 'naan'], 25, 7000, true),

('Pizza Hut Yunusabad', 'Classic pizzas with fresh ingredients. Family-size and individual options.',
 ARRAY['Italian', 'Pizza'], 2, 4.2, 423,
 ST_MakePoint(69.285, 41.360)::geography, 'Yunusabad, Tashkent',
 ARRAY['pizza', 'italian', 'family', 'delivery'], 20, 10000, true),

('Lagman House', 'Hand-pulled noodles and traditional Uzbek lagman. Made fresh daily.',
 ARRAY['Uzbek', 'Noodles'], 1, 4.9, 567,
 ST_MakePoint(69.278, 41.352)::geography, 'Yunusabad 7, Tashkent',
 ARRAY['budget', 'lagman', 'noodles', 'traditional'], 15, 5000, true),

-- Yakkasaray / City Center
('The Plov Center', 'Famous city center plov. Large portions, traditional taste. Open from 7 AM.',
 ARRAY['Uzbek', 'Traditional'], 1, 4.9, 890,
 ST_MakePoint(69.268, 41.291)::geography, 'Yakkasaray, Tashkent',
 ARRAY['plov', 'traditional', 'budget', 'famous'], 10, 5000, true),

('Seoul BBQ', 'Korean BBQ with table grills. Premium meats, banchan, and soju.',
 ARRAY['Korean', 'BBQ'], 3, 4.6, 234,
 ST_MakePoint(69.270, 41.293)::geography, 'Yakkasaray, Tashkent',
 ARRAY['korean', 'bbq', 'premium', 'dinner'], 30, 15000, true),

('Mama Dumplings', 'Handmade manti, chuchvara, and samsa. Grandma recipes since 1995.',
 ARRAY['Uzbek', 'Dumplings'], 1, 4.8, 445,
 ST_MakePoint(69.265, 41.288)::geography, 'Yakkasaray, Tashkent',
 ARRAY['dumplings', 'manti', 'samsa', 'budget', 'traditional'], 20, 5000, true),

-- Tashkent City / Downtown
('Café Mia', 'Modern European café with brunch, pasta, and desserts. Instagram-worthy interior.',
 ARRAY['European', 'Café'], 2, 4.4, 178,
 ST_MakePoint(69.280, 41.312)::geography, 'Tashkent City Mall, Tashkent',
 ARRAY['cafe', 'brunch', 'european', 'desserts'], 15, 10000, true),

('Taco Amigos', 'Mexican street food — tacos, burritos, quesadillas, and nachos.',
 ARRAY['Mexican', 'Street Food'], 1, 4.3, 134,
 ST_MakePoint(69.276, 41.309)::geography, 'Tashkent City, Tashkent',
 ARRAY['mexican', 'tacos', 'budget', 'spicy'], 15, 7000, true),

('Samarkand Kitchen', 'Regional Uzbek cuisine from Samarkand. Unique plov recipes and kebabs.',
 ARRAY['Uzbek', 'Regional'], 1, 4.7, 289,
 ST_MakePoint(69.282, 41.314)::geography, 'Amir Temur, Tashkent',
 ARRAY['samarkand', 'plov', 'kebab', 'traditional'], 20, 5000, true),

('Mediterranean Grill', 'Falafel, hummus, shawarma, and grilled meats. Fresh Mediterranean flavors.',
 ARRAY['Mediterranean', 'Middle Eastern'], 2, 4.5, 201,
 ST_MakePoint(69.275, 41.306)::geography, 'Navoi, Tashkent',
 ARRAY['mediterranean', 'halal', 'healthy', 'shawarma'], 20, 8000, true),

-- Shayhontohur area
('Bento Box', 'Japanese bento meals, onigiri, and matcha drinks. Quick and healthy.',
 ARRAY['Japanese', 'Healthy'], 2, 4.6, 156,
 ST_MakePoint(69.235, 41.328)::geography, 'Shayhontohur, Tashkent',
 ARRAY['japanese', 'bento', 'healthy', 'quick'], 10, 8000, true),

('Tandoor Express', 'Fresh from the tandoor — samsa, kebabs, and flatbreads. Made to order.',
 ARRAY['Uzbek', 'BBQ'], 1, 4.8, 378,
 ST_MakePoint(69.230, 41.324)::geography, 'Shayhontohur, Tashkent',
 ARRAY['tandoor', 'samsa', 'kebab', 'budget', 'traditional'], 15, 5000, true),

('Ice Cream Lab', 'Artisan ice cream and gelato. Unique flavors like saffron, pistachio, and rose.',
 ARRAY['Desserts', 'Ice Cream'], 1, 4.9, 523,
 ST_MakePoint(69.238, 41.330)::geography, 'Shayhontohur, Tashkent',
 ARRAY['desserts', 'ice-cream', 'snacks'], 5, 5000, true),

-- Sergeli area  
('Manti Palace', 'Premium manti with various fillings — pumpkin, beef, chicken, potato.',
 ARRAY['Uzbek', 'Dumplings'], 1, 4.7, 267,
 ST_MakePoint(69.220, 41.240)::geography, 'Sergeli, Tashkent',
 ARRAY['manti', 'dumplings', 'budget', 'traditional'], 25, 5000, true)

ON CONFLICT DO NOTHING;


-- ── Menu Items (sample for a few restaurants) ────────────────────
-- Insert menu items for the first few restaurants by name lookup

DO $$
DECLARE
  v_osh_id uuid;
  v_kimchi_id uuid;
  v_green_id uuid;
  v_plov_id uuid;
  v_burger_id uuid;
  v_xotambek_id uuid;
  v_lagmanni_id uuid;
  v_sabo_id uuid;
BEGIN
  SELECT id INTO v_osh_id FROM restaurants WHERE name = 'Osh Markazi' LIMIT 1;
  SELECT id INTO v_kimchi_id FROM restaurants WHERE name = 'Kimchi House' LIMIT 1;
  SELECT id INTO v_green_id FROM restaurants WHERE name = 'Green Bowl Tashkent' LIMIT 1;
  SELECT id INTO v_plov_id FROM restaurants WHERE name = 'The Plov Center' LIMIT 1;
  SELECT id INTO v_burger_id FROM restaurants WHERE name = 'Burger Lab' LIMIT 1;
  SELECT id INTO v_xotambek_id FROM restaurants WHERE name = 'Xotambek' LIMIT 1;
  SELECT id INTO v_lagmanni_id FROM restaurants WHERE name = 'Café Lagmanni' LIMIT 1;
  SELECT id INTO v_sabo_id FROM restaurants WHERE name = 'Choyxona Sabo' LIMIT 1;

  -- Osh Markazi menu
  IF v_osh_id IS NOT NULL THEN
    INSERT INTO menu_items (restaurant_id, name, description, price, category, calories, tags, sort_order) VALUES
      (v_osh_id, 'Classic Lamb Plov', 'Traditional Uzbek plov with tender lamb, carrots, and rice', 35000, 'Main', 650, ARRAY['bestseller', 'traditional'], 1),
      (v_osh_id, 'Wedding Plov', 'Premium plov with raisins, chickpeas, and quail eggs', 45000, 'Main', 750, ARRAY['premium'], 2),
      (v_osh_id, 'Tandir Kebab', 'Slow-roasted lamb in a clay oven', 55000, 'Main', 500, ARRAY['tandoor'], 3),
      (v_osh_id, 'Shurpa', 'Rich lamb soup with vegetables', 25000, 'Soup', 350, ARRAY['soup', 'traditional'], 4),
      (v_osh_id, 'Non (Bread)', 'Freshly baked traditional bread', 5000, 'Side', 250, ARRAY['bread'], 5),
      (v_osh_id, 'Green Tea', 'Traditional green tea', 5000, 'Drink', 0, ARRAY['drink'], 6);
  END IF;

  -- Kimchi House menu
  IF v_kimchi_id IS NOT NULL THEN
    INSERT INTO menu_items (restaurant_id, name, description, price, category, calories, tags, sort_order) VALUES
      (v_kimchi_id, 'Dolsot Bibimbap', 'Sizzling stone pot bibimbap with vegetables and egg', 55000, 'Main', 550, ARRAY['bestseller', 'spicy'], 1),
      (v_kimchi_id, 'Kimchi Jjigae', 'Spicy kimchi stew with pork and tofu', 48000, 'Main', 400, ARRAY['spicy', 'soup'], 2),
      (v_kimchi_id, 'Bulgogi', 'Marinated beef slices with rice', 65000, 'Main', 600, ARRAY['premium'], 3),
      (v_kimchi_id, 'Japchae', 'Sweet potato noodles with vegetables', 42000, 'Side', 350, ARRAY['vegetarian'], 4),
      (v_kimchi_id, 'Mandu (6pcs)', 'Korean dumplings, steamed or fried', 30000, 'Side', 300, ARRAY['dumplings'], 5);
  END IF;

  -- Green Bowl menu
  IF v_green_id IS NOT NULL THEN
    INSERT INTO menu_items (restaurant_id, name, description, price, category, calories, tags, sort_order) VALUES
      (v_green_id, 'Superfood Buddha Bowl', 'Quinoa, avocado, sweet potato, edamame, tahini', 52000, 'Main', 480, ARRAY['bestseller', 'vegan'], 1),
      (v_green_id, 'Grilled Chicken Bowl', 'Brown rice, grilled chicken, greens, lemon dressing', 55000, 'Main', 520, ARRAY['protein', 'healthy'], 2),
      (v_green_id, 'Mediterranean Salad', 'Mixed greens, feta, olives, cherry tomatoes', 38000, 'Salad', 320, ARRAY['vegetarian'], 3),
      (v_green_id, 'Green Smoothie', 'Spinach, banana, mango, chia seeds', 28000, 'Drink', 200, ARRAY['vegan', 'drink'], 4),
      (v_green_id, 'Protein Bar', 'Homemade oat and nut energy bar', 15000, 'Snack', 180, ARRAY['snack', 'protein'], 5);
  END IF;

  -- The Plov Center menu
  IF v_plov_id IS NOT NULL THEN
    INSERT INTO menu_items (restaurant_id, name, description, price, category, calories, tags, sort_order) VALUES
      (v_plov_id, 'Signature Plov', 'The famous city center plov — the recipe that made us famous', 30000, 'Main', 700, ARRAY['bestseller', 'famous'], 1),
      (v_plov_id, 'Plov with Horse Meat', 'Traditional plov with tender horse meat', 40000, 'Main', 720, ARRAY['traditional', 'premium'], 2),
      (v_plov_id, 'Naryn', 'Hand-cut noodles with horse meat', 35000, 'Main', 450, ARRAY['traditional'], 3),
      (v_plov_id, 'Samsa (3pcs)', 'Flaky pastry filled with lamb and onion', 18000, 'Side', 350, ARRAY['pastry'], 4),
      (v_plov_id, 'Ayran', 'Traditional yogurt drink', 8000, 'Drink', 120, ARRAY['drink', 'traditional'], 5);
  END IF;

  -- Burger Lab menu
  IF v_burger_id IS NOT NULL THEN
    INSERT INTO menu_items (restaurant_id, name, description, price, category, calories, tags, sort_order) VALUES
      (v_burger_id, 'Classic Smash Burger', 'Double smashed patty, American cheese, special sauce', 42000, 'Main', 650, ARRAY['bestseller'], 1),
      (v_burger_id, 'Spicy Jalapeño Burger', 'Crispy jalapeños, pepper jack, chipotle mayo', 48000, 'Main', 700, ARRAY['spicy'], 2),
      (v_burger_id, 'Truffle Mushroom Burger', 'Sautéed mushrooms, truffle oil, Swiss cheese', 55000, 'Main', 680, ARRAY['premium'], 3),
      (v_burger_id, 'Loaded Fries', 'Crispy fries with cheese sauce and bacon bits', 25000, 'Side', 450, ARRAY['side'], 4),
      (v_burger_id, 'Milkshake', 'Thick milkshake — vanilla, chocolate, or strawberry', 22000, 'Drink', 350, ARRAY['drink', 'dessert'], 5);
  END IF;

  -- ═══════ ASAKA MENUS ═══════

  -- Xotambek menu
  IF v_xotambek_id IS NOT NULL THEN
    INSERT INTO menu_items (restaurant_id, name, description, price, category, calories, tags, sort_order) VALUES
      (v_xotambek_id, 'Osh (Plov)', 'Classic Uzbek plov with lamb and carrots', 25000, 'Main', 650, ARRAY['bestseller', 'traditional'], 1),
      (v_xotambek_id, 'Lagman', 'Hand-pulled noodles in rich broth with vegetables', 22000, 'Main', 450, ARRAY['noodles', 'traditional'], 2),
      (v_xotambek_id, 'Shashlik (5pcs)', 'Grilled lamb skewers with onions', 35000, 'Main', 400, ARRAY['bbq', 'bestseller'], 3),
      (v_xotambek_id, 'Shurpa', 'Hearty lamb soup with potatoes and vegetables', 20000, 'Soup', 350, ARRAY['soup', 'traditional'], 4),
      (v_xotambek_id, 'Somsa (2pcs)', 'Flaky pastry with lamb and onion filling', 12000, 'Side', 300, ARRAY['pastry', 'budget'], 5),
      (v_xotambek_id, 'Non', 'Fresh tandoor bread', 3000, 'Side', 250, ARRAY['bread'], 6),
      (v_xotambek_id, 'Green Tea (Choynak)', 'Traditional green tea pot', 5000, 'Drink', 0, ARRAY['drink', 'traditional'], 7);
  END IF;

  -- Café Lagmanni menu
  IF v_lagmanni_id IS NOT NULL THEN
    INSERT INTO menu_items (restaurant_id, name, description, price, category, calories, tags, sort_order) VALUES
      (v_lagmanni_id, 'Classic Lagman', 'Signature hand-pulled noodles in rich tomato broth', 20000, 'Main', 450, ARRAY['bestseller', 'famous'], 1),
      (v_lagmanni_id, 'Kovurma Lagman', 'Fried lagman noodles with vegetables and meat', 22000, 'Main', 500, ARRAY['fried', 'popular'], 2),
      (v_lagmanni_id, 'Boso Lagman', 'Thick broth lagman with chunks of lamb', 25000, 'Main', 550, ARRAY['premium'], 3),
      (v_lagmanni_id, 'Chuchvara', 'Small dumplings in clear broth', 18000, 'Main', 350, ARRAY['dumplings', 'traditional'], 4),
      (v_lagmanni_id, 'Manti (5pcs)', 'Steamed dumplings with lamb and pumpkin', 20000, 'Main', 400, ARRAY['dumplings'], 5),
      (v_lagmanni_id, 'Compot', 'Homemade fruit compote', 5000, 'Drink', 80, ARRAY['drink'], 6);
  END IF;

  -- Choyxona Sabo menu
  IF v_sabo_id IS NOT NULL THEN
    INSERT INTO menu_items (restaurant_id, name, description, price, category, calories, tags, sort_order) VALUES
      (v_sabo_id, 'Tandir Somsa', 'Clay-oven baked somsa with lamb — crispy perfection', 8000, 'Main', 350, ARRAY['bestseller', 'famous', 'budget'], 1),
      (v_sabo_id, 'Shurpa', 'Rich lamb soup with fresh vegetables', 18000, 'Soup', 350, ARRAY['soup', 'traditional'], 2),
      (v_sabo_id, 'Dimlama', 'Slow-braised meat and vegetables in own juices', 28000, 'Main', 500, ARRAY['traditional', 'homestyle'], 3),
      (v_sabo_id, 'Qozon Kabob', 'Pan-fried lamb ribs with potatoes', 30000, 'Main', 550, ARRAY['premium', 'bbq'], 4),
      (v_sabo_id, 'Non', 'Freshly baked traditional bread', 3000, 'Side', 250, ARRAY['bread'], 5),
      (v_sabo_id, 'Ko''k Choy', 'Green tea served in traditional style', 4000, 'Drink', 0, ARRAY['drink', 'traditional'], 6);
  END IF;

END $$;

-- Done! 🎉
SELECT 'Schema created and seeded with ' || count(*) || ' restaurants' as result FROM restaurants;
