-- ═══════════════════════════════════════════════════════════════════
-- I-Fridge — Video Feeds Schema
-- ═══════════════════════════════════════════════════════════════════
-- Stores YouTube video metadata for Cook and Order feed tabs.
-- Each video has an embedded YouTube link, AI-extracted recipe (cook),
-- or linked restaurant (order).
-- ═══════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS video_feeds (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  youtube_id text NOT NULL UNIQUE,
  tab_type text NOT NULL CHECK (tab_type IN ('cook', 'order')),
  title text NOT NULL,
  description text,
  thumbnail_url text NOT NULL,
  embed_url text NOT NULL,
  author_name text DEFAULT 'Unknown',
  tags text[] DEFAULT '{}',
  recipe_json jsonb DEFAULT NULL, -- AI-extracted recipe (cook tab only)
  restaurant_id uuid REFERENCES restaurants(id) DEFAULT NULL, -- linked restaurant (order tab)
  likes int DEFAULT 0,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);

-- Index for fast tab filtering
CREATE INDEX IF NOT EXISTS idx_video_feeds_tab ON video_feeds(tab_type);

-- ═══════════════════════════════════════════════════════════════════
-- COOK TAB VIDEOS (10 cooking recipe shorts)
-- ═══════════════════════════════════════════════════════════════════

INSERT INTO video_feeds (youtube_id, tab_type, title, description, author_name, thumbnail_url, embed_url, tags, likes, recipe_json) VALUES

-- 1. Uzbek Plov
('6004eSUefz8', 'cook',
 'Uzbek Pilaf (Plov)',
 'Traditional Uzbek plov recipe — the king of Central Asian cuisine. Rice, lamb, carrots, and aromatic spices.',
 'Uzbek Kitchen',
 'https://img.youtube.com/vi/6004eSUefz8/hqdefault.jpg',
 'https://www.youtube.com/embed/6004eSUefz8',
 ARRAY['plov', 'uzbek', 'rice', 'lamb', 'traditional'],
 2450,
 '{"title": "Uzbek Plov (Pilaf)", "servings": 6, "prep_time": "20 min", "cook_time": "1.5 hours", "difficulty": "Medium", "ingredients": ["1 kg lamb (shoulder)", "600g rice (devzira or basmati)", "500g carrots", "3 onions", "150ml vegetable oil", "1 head garlic", "2 tsp cumin seeds", "1 tsp turmeric", "Salt to taste", "Hot water as needed"], "steps": ["Cut lamb into large chunks, slice carrots into matchsticks, dice onions.", "Heat oil in kazan until smoking. Sear lamb on all sides.", "Add onions, cook until golden. Add carrots, stir 5 min.", "Add cumin, turmeric, salt. Pour hot water to cover.", "Simmer 40 min for zirvak. Wash rice, spread over zirvak.", "Add water 2cm above rice. Push whole garlic into center.", "Cover, cook on low heat 25-30 min until rice absorbs water.", "Fluff gently and serve on a large plate."]}'
),

-- 2. Traditional Plov
('8OLH-vzDQ1U', 'cook',
 'Traditional Uzbek PLOV Recipe',
 'Step-by-step authentic plov preparation with devzira rice and lamb.',
 'Central Asian Recipes',
 'https://img.youtube.com/vi/8OLH-vzDQ1U/hqdefault.jpg',
 'https://www.youtube.com/embed/8OLH-vzDQ1U',
 ARRAY['plov', 'traditional', 'devzira', 'authentic'],
 1890,
 '{"title": "Traditional Uzbek Plov", "servings": 8, "prep_time": "30 min", "cook_time": "2 hours", "difficulty": "Medium", "ingredients": ["1.5 kg lamb ribs", "1 kg devzira rice", "600g yellow carrots", "4 onions", "200ml cottonseed oil", "2 heads garlic", "3 tsp cumin", "Chickpeas (soaked)", "Salt, black pepper"], "steps": ["Soak rice in warm water 1 hour. Soak chickpeas overnight.", "Heat oil in kazan, fry onions until caramelized.", "Add lamb, sear until browned on all sides.", "Add carrots, cook 10 min. Season with cumin and salt.", "Add chickpeas and hot water. Simmer 45 min.", "Drain rice, spread evenly over zirvak.", "Add water, nestle garlic heads. Cover tightly.", "Cook low heat 30 min. Rest 10 min before serving."]}'
),

-- 3. Plov Better Than Fried Rice
('lYmhl_d3M-M', 'cook',
 'Uzbek Pilaf — Better Than Any Fried Rice',
 'Quick and flavorful plov that will change how you think about rice dishes.',
 'Food Fusion',
 'https://img.youtube.com/vi/lYmhl_d3M-M/hqdefault.jpg',
 'https://www.youtube.com/embed/lYmhl_d3M-M',
 ARRAY['plov', 'quick', 'rice', 'easy'],
 3200,
 '{"title": "Quick Uzbek Plov", "servings": 4, "prep_time": "15 min", "cook_time": "45 min", "difficulty": "Easy", "ingredients": ["500g beef", "400g long grain rice", "3 carrots", "2 onions", "Oil", "Cumin", "Turmeric", "Salt"], "steps": ["Dice beef, julienne carrots, chop onions.", "Brown beef in hot oil. Add onions until golden.", "Add carrots, cook 5 min. Season.", "Add water, simmer 20 min.", "Add washed rice, water to cover.", "Cook covered on low 20 min."]}'
),

-- 4. How to Make Plov
('8Vnr64SCmjw', 'cook',
 'How to Make UZBEK PILAF (PLOV)',
 'Complete tutorial for beginners — master the art of Uzbek plov.',
 'Easy Uzbek Cooking',
 'https://img.youtube.com/vi/8Vnr64SCmjw/hqdefault.jpg',
 'https://www.youtube.com/embed/8Vnr64SCmjw',
 ARRAY['plov', 'tutorial', 'beginner', 'howto'],
 1560,
 '{"title": "Beginner Uzbek Plov", "servings": 4, "prep_time": "20 min", "cook_time": "1 hour", "difficulty": "Easy", "ingredients": ["700g lamb", "500g basmati rice", "4 carrots", "2 onions", "100ml oil", "1 garlic head", "Cumin", "Salt"], "steps": ["Prep all vegetables. Wash rice.", "Heat oil, cook onions, then meat.", "Add carrots and spices.", "Pour water, simmer 30 min.", "Add rice and water. Cook covered.", "Rest 10 min before serving."]}'
),

-- 5. Plov Short Recipe
('BiUSdr1PWJo', 'cook',
 'Uzbek Pilaf — Quick Recipe',
 'Fast-paced plov recipe showing traditional preparation method.',
 'Plov Master',
 'https://img.youtube.com/vi/BiUSdr1PWJo/hqdefault.jpg',
 'https://www.youtube.com/embed/BiUSdr1PWJo',
 ARRAY['plov', 'quick-recipe', 'short', 'pilaf'],
 980,
 '{"title": "Express Plov", "servings": 4, "prep_time": "10 min", "cook_time": "50 min", "difficulty": "Easy", "ingredients": ["500g meat", "400g rice", "3 carrots", "2 onions", "Oil", "Spices"], "steps": ["Fry meat in oil.", "Add onions and carrots.", "Season and add water.", "Add rice, cook covered."]}'
),

-- 6. Easy Plov Short
('zNOKrKhJcTg', 'cook',
 'Delicious & Easy Uzbek Plov',
 'Simple yet delicious plov recipe anyone can follow.',
 'Home Chef UZ',
 'https://img.youtube.com/vi/zNOKrKhJcTg/hqdefault.jpg',
 'https://www.youtube.com/embed/zNOKrKhJcTg',
 ARRAY['plov', 'easy', 'delicious', 'home-cooking'],
 1120,
 '{"title": "Easy Home Plov", "servings": 3, "prep_time": "10 min", "cook_time": "40 min", "difficulty": "Easy", "ingredients": ["400g chicken thighs", "300g rice", "2 carrots", "1 onion", "Oil", "Cumin", "Salt"], "steps": ["Brown chicken pieces in oil.", "Sauté onions and carrots.", "Add spices and water.", "Layer rice on top. Cook 25 min."]}'
),

-- 7. Beef Plov
('ZX3gH0BSTR4', 'cook',
 'Uzbekistan Food — Beef Plov',
 'Hearty beef plov with rich flavors and perfect rice texture.',
 'Uzbekistan Cuisine',
 'https://img.youtube.com/vi/ZX3gH0BSTR4/hqdefault.jpg',
 'https://www.youtube.com/embed/ZX3gH0BSTR4',
 ARRAY['plov', 'beef', 'uzbekistan', 'hearty'],
 2100,
 '{"title": "Beef Plov", "servings": 6, "prep_time": "20 min", "cook_time": "1.5 hours", "difficulty": "Medium", "ingredients": ["1 kg beef chuck", "800g rice", "500g carrots", "3 onions", "150ml oil", "Garlic", "Cumin", "Barberries", "Salt"], "steps": ["Sear beef in smoking oil.", "Cook onions until dark golden.", "Add julienned carrots.", "Season, add water, simmer 45 min.", "Add rice, garlic, barberries.", "Cook covered 30 min."]}'
),

-- 8. Samsa Recipe
('4LO5uVOWOxY', 'cook',
 'Uzbek Samsa Recipe',
 'Flaky pastry filled with seasoned lamb and onions — baked in tandoor.',
 'Eastern Flavors',
 'https://img.youtube.com/vi/4LO5uVOWOxY/hqdefault.jpg',
 'https://www.youtube.com/embed/4LO5uVOWOxY',
 ARRAY['samsa', 'somsa', 'pastry', 'lamb', 'baked'],
 1750,
 '{"title": "Uzbek Samsa (Somsa)", "servings": 12, "prep_time": "45 min", "cook_time": "25 min", "difficulty": "Medium", "ingredients": ["500g flour", "200ml water", "100g butter", "500g lamb mince", "4 onions (diced)", "Cumin", "Black pepper", "Salt", "1 egg yolk", "Sesame seeds"], "steps": ["Make dough: flour + water + salt. Knead 10 min, rest 30 min.", "Mix lamb, onions, cumin, pepper, salt for filling.", "Roll dough thin, brush with melted butter, fold layers.", "Cut squares, place filling, fold into triangles.", "Place on baking sheet, brush with egg yolk.", "Sprinkle sesame seeds. Bake 220°C for 25 min."]}'
),

-- 9. Fried Lagman
('XAXO8Q2S9SA', 'cook',
 'Fried Lagman — Personal Favorite',
 'Stir-fried hand-pulled noodles with vegetables and tender beef.',
 'Noodle Master',
 'https://img.youtube.com/vi/XAXO8Q2S9SA/hqdefault.jpg',
 'https://www.youtube.com/embed/XAXO8Q2S9SA',
 ARRAY['lagman', 'noodles', 'fried', 'stir-fry', 'beef'],
 2680,
 '{"title": "Fried Lagman", "servings": 4, "prep_time": "30 min", "cook_time": "20 min", "difficulty": "Medium", "ingredients": ["400g handmade noodles (or thick udon)", "300g beef sliced thin", "2 bell peppers", "2 tomatoes", "3 cloves garlic", "1 onion", "Soy sauce", "1 daikon radish", "Oil", "Chili flakes"], "steps": ["Cook noodles until al dente, drain and oil lightly.", "Stir-fry beef on very high heat until seared.", "Add onions, peppers, radish. Cook 3 min.", "Add tomatoes and garlic. Season with soy sauce.", "Toss in noodles, stir-fry 2 min.", "Garnish with herbs and chili flakes."]}'
),

-- 10. Manti Dumplings
('7YEv3_fz7gM', 'cook',
 'Beautiful Uzbek Manti',
 'Steamed dumplings filled with seasoned lamb and pumpkin — beautiful presentation.',
 'Manti House',
 'https://img.youtube.com/vi/7YEv3_fz7gM/hqdefault.jpg',
 'https://www.youtube.com/embed/7YEv3_fz7gM',
 ARRAY['manti', 'dumplings', 'steamed', 'lamb', 'pumpkin'],
 1940,
 '{"title": "Uzbek Manti Dumplings", "servings": 30, "prep_time": "1 hour", "cook_time": "45 min", "difficulty": "Hard", "ingredients": ["500g flour", "250ml warm water", "1 egg", "500g lamb mince", "300g pumpkin (grated)", "3 onions (diced)", "Cumin", "Black pepper", "Salt", "Butter for steamer"], "steps": ["Make dough: flour, egg, water, salt. Knead smooth, rest 30 min.", "Mix lamb, grated pumpkin, diced onions, cumin, pepper.", "Roll dough thin, cut 10cm squares.", "Place filling in center, pinch corners together.", "Grease steamer tiers with butter.", "Place manti in steamer, steam 45 min.", "Serve with yogurt-garlic sauce and sour cream."]}'
)
ON CONFLICT (youtube_id) DO NOTHING;

-- ═══════════════════════════════════════════════════════════════════
-- ORDER TAB VIDEOS (10 food/restaurant/street food shorts)
-- ═══════════════════════════════════════════════════════════════════

INSERT INTO video_feeds (youtube_id, tab_type, title, description, author_name, thumbnail_url, embed_url, tags, likes) VALUES

-- 1. Chorsu Bazaar Food Tour
('1E7sGRO5t1k', 'order',
 'Day 1 of Eating Only Uzbek Food!',
 'Exploring Chorsu Bazaar in Tashkent — trying every local dish from plov to somsa.',
 'Food Explorer',
 'https://img.youtube.com/vi/1E7sGRO5t1k/hqdefault.jpg',
 'https://www.youtube.com/embed/1E7sGRO5t1k',
 ARRAY['food-tour', 'chorsu', 'tashkent', 'bazaar', 'street-food'],
 5400
),

-- 2. Uzbekistan Street Food
('fV-PYfx4nJw', 'order',
 'Uzbekistan Street Food',
 'Quick tour of amazing Uzbek street food — sizzling kebabs, fresh bread, and steaming manti.',
 'Street Food World',
 'https://img.youtube.com/vi/fV-PYfx4nJw/hqdefault.jpg',
 'https://www.youtube.com/embed/fV-PYfx4nJw',
 ARRAY['street-food', 'uzbekistan', 'foodie', 'tour'],
 3200
),

-- 3. Uzbek Street Food
('jOBsmQS-iHM', 'order',
 'UZBEK STREET Food',
 'High-energy tour of Uzbek street food stalls — amazing sights and flavors.',
 'Food Vlogger',
 'https://img.youtube.com/vi/jOBsmQS-iHM/hqdefault.jpg',
 'https://www.youtube.com/embed/jOBsmQS-iHM',
 ARRAY['street-food', 'uzbek', 'vlog', 'energy'],
 2800
),

-- 4. Speed Tries Uzbek Food
('Ym6Ofl8Qelc', 'order',
 'Trying Traditional Uzbek Food — Plov',
 'Reacting to traditional Uzbek plov — the taste test everyone needs to see.',
 'Food Reaction',
 'https://img.youtube.com/vi/Ym6Ofl8Qelc/hqdefault.jpg',
 'https://www.youtube.com/embed/Ym6Ofl8Qelc',
 ARRAY['reaction', 'plov', 'taste-test', 'viral'],
 8900
),

-- 5. Uzbek Restaurant Food
('LG4KS3bvRKc', 'order',
 'Uzbek Restaurant Experience',
 'Inside a traditional Uzbek restaurant — beshbarmak, achichuk, and more.',
 'Uzbek Foodie',
 'https://img.youtube.com/vi/LG4KS3bvRKc/hqdefault.jpg',
 'https://www.youtube.com/embed/LG4KS3bvRKc',
 ARRAY['restaurant', 'beshbarmak', 'uzbek', 'dining'],
 1560
),

-- 6. Mass Plov Production
('xHaVm9yU8Pc', 'order',
 '2 Tons UZBEK National Food',
 'Massive plov production — watching 2 tons of plov being prepared for a celebration.',
 'Food Production',
 'https://img.youtube.com/vi/xHaVm9yU8Pc/hqdefault.jpg',
 'https://www.youtube.com/embed/xHaVm9yU8Pc',
 ARRAY['mass-cooking', 'plov', 'celebration', 'scale'],
 4500
),

-- 7. Full Day Uzbek Food
('e1MvGrEKOEM', 'order',
 'Eating Uzbekistan Food For The Whole Day!',
 'From breakfast to dinner — every meal is Uzbek cuisine. A full day food adventure.',
 'Food Adventure',
 'https://img.youtube.com/vi/e1MvGrEKOEM/hqdefault.jpg',
 'https://www.youtube.com/embed/e1MvGrEKOEM',
 ARRAY['full-day', 'food-adventure', 'uzbekistan', 'meals'],
 3600
),

-- 8. Kosa Somsa Street Food
('32yefIOM-Os', 'order',
 'Kosa Somsa — Uzbek Street Food',
 'Giant bowl-shaped somsa — crispy, juicy, and absolutely delicious street food.',
 'Street Eats',
 'https://img.youtube.com/vi/32yefIOM-Os/hqdefault.jpg',
 'https://www.youtube.com/embed/32yefIOM-Os',
 ARRAY['somsa', 'kosa', 'street-food', 'crispy'],
 2100
),

-- 9. Traditional Uzbek Kitchen
('FmcAi7P6rUk', 'order',
 'Inside a Traditional Uzbek Kitchen!',
 'Behind the scenes of a traditional Uzbek kitchen — see how master chefs work.',
 'Kitchen Tour',
 'https://img.youtube.com/vi/FmcAi7P6rUk/hqdefault.jpg',
 'https://www.youtube.com/embed/FmcAi7P6rUk',
 ARRAY['kitchen', 'traditional', 'behind-scenes', 'uzbek'],
 1800
),

-- 10. Huge Plov Street Food
('f3Mh1_0m6zY', 'order',
 'HUGE UZBEK PLOV! Street Food in Tashkent',
 'Massive portions of steaming plov served at a busy Tashkent street food stall.',
 'Tashkent Eats',
 'https://img.youtube.com/vi/f3Mh1_0m6zY/hqdefault.jpg',
 'https://www.youtube.com/embed/f3Mh1_0m6zY',
 ARRAY['plov', 'huge', 'tashkent', 'street-food', 'portion'],
 4200
)
ON CONFLICT (youtube_id) DO NOTHING;

-- ═══════════════════════════════════════════════════════════════════
-- RPC: Get video feeds by tab type
-- ═══════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION get_video_feeds(feed_type text DEFAULT 'cook')
RETURNS TABLE (
  id uuid, youtube_id text, tab_type text,
  title text, description text,
  thumbnail_url text, embed_url text,
  author_name text, tags text[],
  recipe_json jsonb, restaurant_id uuid,
  likes int
)
LANGUAGE sql STABLE
AS $$
  SELECT
    v.id, v.youtube_id, v.tab_type,
    v.title, v.description,
    v.thumbnail_url, v.embed_url,
    v.author_name, v.tags,
    v.recipe_json, v.restaurant_id,
    v.likes
  FROM video_feeds v
  WHERE v.tab_type = feed_type AND v.is_active = true
  ORDER BY v.likes DESC;
$$;

SELECT 'Video feeds created: ' || count(*) || ' total (' ||
  (SELECT count(*) FROM video_feeds WHERE tab_type = 'cook') || ' cook, ' ||
  (SELECT count(*) FROM video_feeds WHERE tab_type = 'order') || ' order)' as result
FROM video_feeds;
