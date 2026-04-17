-- ═══════════════════════════════════════════════════════════════════
-- I-Fridge — Foreign Video Feeds (Addendum)
-- ═══════════════════════════════════════════════════════════════════
-- Adds 20 more videos (10 cook + 10 order) in 3 languages:
-- 6 English, 2 Korean, 2 Russian per tab.
-- Run AFTER 004_video_feeds.sql
-- ═══════════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════════
-- COOK TAB — 10 foreign cooking recipe videos
-- ═══════════════════════════════════════════════════════════════════

INSERT INTO video_feeds (youtube_id, tab_type, title, description, author_name, thumbnail_url, embed_url, tags, likes, recipe_json) VALUES

-- ── English (6) ──────────────────────────────────────────────────

-- 1. Gordon Ramsay Scrambled Eggs
('PUP7U5vTMM0', 'cook',
 'Gordon Ramsay''s Perfect Scrambled Eggs',
 'The legendary scrambled eggs technique that went viral worldwide. Creamy, silky perfection.',
 'Gordon Ramsay',
 'https://img.youtube.com/vi/PUP7U5vTMM0/hqdefault.jpg',
 'https://www.youtube.com/embed/PUP7U5vTMM0',
 ARRAY['eggs', 'gordon-ramsay', 'breakfast', 'viral', 'english'],
 15200,
 '{"title": "Gordon Ramsay Scrambled Eggs", "servings": 2, "prep_time": "2 min", "cook_time": "5 min", "difficulty": "Easy", "ingredients": ["6 eggs", "Butter (cold, cubed)", "1 tbsp crème fraîche", "Chives (chopped)", "Salt & pepper", "Sourdough toast"], "steps": ["Crack 6 eggs into a cold pan with cold butter cubes.", "Place on medium heat, stirring constantly with a spatula.", "After 30 seconds, take OFF heat, keep stirring.", "Back on heat 10 sec, off 10 sec — repeat 3 times.", "When almost set, add crème fraîche. Season.", "Serve immediately on toast. Garnish with chives."]}'
),

-- 2. 15-Second Pasta Aglio e Olio
('bJUiWdM__Qw', 'cook',
 'Pasta Aglio e Olio — 15 Minute Recipe',
 'The simplest and most elegant Italian pasta. Just garlic, olive oil, chili, and parsley.',
 'Italia Squisita',
 'https://img.youtube.com/vi/bJUiWdM__Qw/hqdefault.jpg',
 'https://www.youtube.com/embed/bJUiWdM__Qw',
 ARRAY['pasta', 'italian', 'aglio-olio', 'quick', 'english'],
 8900,
 '{"title": "Pasta Aglio e Olio", "servings": 2, "prep_time": "5 min", "cook_time": "12 min", "difficulty": "Easy", "ingredients": ["200g spaghetti", "6 cloves garlic (sliced thin)", "60ml extra virgin olive oil", "1 tsp red chili flakes", "Fresh parsley (chopped)", "Parmesan cheese", "Pasta water", "Salt"], "steps": ["Boil pasta in well-salted water until al dente.", "Slowly cook sliced garlic in olive oil on low heat until golden.", "Add chili flakes, cook 30 seconds.", "Add 1/2 cup pasta water to the pan.", "Toss drained pasta in the garlic oil. Mix vigorously.", "Serve with parsley and parmesan."]}'
),

-- 3. One-Pan Chicken Thighs
('FzniSCw2vKA', 'cook',
 'Crispy Chicken Thighs — One Pan Wonder',
 'Juicy, crispy-skinned chicken thighs with roasted vegetables. One pan, zero effort.',
 'Joshua Weissman',
 'https://img.youtube.com/vi/FzniSCw2vKA/hqdefault.jpg',
 'https://www.youtube.com/embed/FzniSCw2vKA',
 ARRAY['chicken', 'one-pan', 'easy', 'crispy', 'english'],
 6700,
 '{"title": "One-Pan Crispy Chicken", "servings": 4, "prep_time": "10 min", "cook_time": "30 min", "difficulty": "Easy", "ingredients": ["8 chicken thighs (bone-in, skin-on)", "400g baby potatoes (halved)", "200g cherry tomatoes", "1 lemon (quartered)", "4 cloves garlic", "Fresh rosemary", "Olive oil", "Salt & pepper", "Paprika"], "steps": ["Season chicken with salt, pepper, paprika.", "Heat oven to 220°C. Place chicken skin-down in cold pan.", "Turn on medium heat, cook 8 min until skin is golden.", "Flip chicken. Add potatoes, tomatoes, garlic, lemon, rosemary.", "Transfer to oven, roast 25 min.", "Rest 5 min before serving."]}'
),

-- 4. Quick Fried Rice
('_WQOQ9y1eQU', 'cook',
 'Better Than Takeout — Egg Fried Rice',
 'Uncle Roger approved fried rice in under 10 minutes. The secret: day-old rice and high heat.',
 'Wok Star',
 'https://img.youtube.com/vi/_WQOQ9y1eQU/hqdefault.jpg',
 'https://www.youtube.com/embed/_WQOQ9y1eQU',
 ARRAY['fried-rice', 'asian', 'quick', 'wok', 'english'],
 11500,
 '{"title": "Egg Fried Rice", "servings": 2, "prep_time": "5 min", "cook_time": "5 min", "difficulty": "Easy", "ingredients": ["3 cups day-old rice", "3 eggs", "3 green onions (chopped)", "2 tbsp soy sauce", "1 tbsp sesame oil", "2 tbsp vegetable oil", "White pepper", "MSG (optional)"], "steps": ["Beat eggs. Heat wok until smoking.", "Add oil, pour eggs, scramble 30 sec.", "Add cold rice immediately. Break up clumps.", "Toss on maximum heat for 2 min.", "Add soy sauce, sesame oil, white pepper.", "Toss in green onions. Serve immediately."]}'
),

-- 5. Viral Baked Feta Pasta
('PKCnVFTb3e4', 'cook',
 'TikTok Baked Feta Pasta — Viral Recipe',
 'The #1 most viral recipe from TikTok. Baked feta cheese with cherry tomatoes and pasta.',
 'Tasty',
 'https://img.youtube.com/vi/PKCnVFTb3e4/hqdefault.jpg',
 'https://www.youtube.com/embed/PKCnVFTb3e4',
 ARRAY['pasta', 'feta', 'viral', 'tiktok', 'baked', 'english'],
 22000,
 '{"title": "Baked Feta Pasta", "servings": 4, "prep_time": "5 min", "cook_time": "30 min", "difficulty": "Easy", "ingredients": ["400g cherry tomatoes", "200g block feta cheese", "60ml olive oil", "4 cloves garlic", "Red chili flakes", "Fresh basil", "300g penne pasta", "Salt & pepper"], "steps": ["Place cherry tomatoes in baking dish. Nestle feta block in center.", "Drizzle with olive oil, add garlic, chili flakes.", "Bake at 200°C for 25 min until tomatoes burst.", "Cook pasta al dente while feta bakes.", "Mash baked feta into tomatoes. Mix well.", "Toss in pasta, add basil. Season to taste."]}'
),

-- 6. Butter Chicken
('a03U45jFxOI', 'cook',
 'Restaurant-Style Butter Chicken at Home',
 'Rich, creamy butter chicken that tastes better than any restaurant. The secret? Overnight marinade.',
 'Cooking With Chef',
 'https://img.youtube.com/vi/a03U45jFxOI/hqdefault.jpg',
 'https://www.youtube.com/embed/a03U45jFxOI',
 ARRAY['butter-chicken', 'indian', 'curry', 'creamy', 'english'],
 9400,
 '{"title": "Butter Chicken", "servings": 4, "prep_time": "20 min + marinade", "cook_time": "30 min", "difficulty": "Medium", "ingredients": ["600g chicken thighs", "200ml yogurt", "2 tbsp garam masala", "1 can tomatoes (400g)", "100g butter", "200ml cream", "1 onion", "4 cloves garlic", "Ginger", "Kasuri methi", "Salt, sugar"], "steps": ["Marinate chicken in yogurt + spices for 4 hours (or overnight).", "Grill or pan-fry marinated chicken until charred.", "In a pan, sauté onion, garlic, ginger in butter.", "Add canned tomatoes, simmer 15 min. Blend smooth.", "Add cream, kasuri methi, sugar. Simmer 5 min.", "Add chicken pieces. Cook 10 min in sauce. Serve with naan."]}'
),

-- ── Korean (2) ───────────────────────────────────────────────────

-- 7. Korean Kimchi Jjigae
('T6GKLMfly14', 'cook',
 '김치찌개 — 엄마표 레시피',
 'Mom''s kimchi jjigae recipe. The ultimate Korean comfort food with aged kimchi and pork belly.',
 '요리하는 엄마',
 'https://img.youtube.com/vi/T6GKLMfly14/hqdefault.jpg',
 'https://www.youtube.com/embed/T6GKLMfly14',
 ARRAY['kimchi-jjigae', 'korean', '한국요리', 'comfort-food', 'stew'],
 4500,
 '{"title": "김치찌개 (Kimchi Jjigae)", "servings": 3, "prep_time": "10 min", "cook_time": "25 min", "difficulty": "Easy", "ingredients": ["300g aged kimchi (sliced)", "200g pork belly (sliced)", "1 block tofu", "2 green onions", "1 tbsp gochugaru", "1 tbsp sesame oil", "2 cups anchovy/kelp stock", "1 tsp sugar", "1 tsp soy sauce"], "steps": ["Sauté pork belly in sesame oil until fat renders.", "Add kimchi, stir-fry 3 min until fragrant.", "Add gochugaru, sugar, soy sauce.", "Pour in stock. Bring to boil.", "Add tofu cubes. Simmer 15 min.", "Garnish with green onions. Serve with rice."]}'
),

-- 8. Korean Tteokbokki
('gMJAX_DXfGo', 'cook',
 '떡볶이 — 매콤달콤 길거리 맛',
 'Spicy-sweet street-style tteokbokki. Korea''s #1 street food, made at home.',
 '백종원의 요리비책',
 'https://img.youtube.com/vi/gMJAX_DXfGo/hqdefault.jpg',
 'https://www.youtube.com/embed/gMJAX_DXfGo',
 ARRAY['tteokbokki', 'korean', '떡볶이', 'street-food', 'spicy'],
 7200,
 '{"title": "떡볶이 (Tteokbokki)", "servings": 2, "prep_time": "10 min", "cook_time": "15 min", "difficulty": "Easy", "ingredients": ["400g rice cakes (tteok)", "3 tbsp gochujang", "1 tbsp gochugaru", "2 tbsp sugar", "1 tbsp soy sauce", "3 cups anchovy stock", "2 fish cakes", "2 boiled eggs", "Green onions"], "steps": ["Soak rice cakes in warm water 10 min if frozen.", "Bring anchovy stock to boil.", "Add gochujang, gochugaru, sugar, soy sauce. Mix well.", "Add rice cakes and fish cakes.", "Boil 10-12 min, stirring occasionally until sauce thickens.", "Add boiled eggs and green onions. Serve hot."]}'
),

-- ── Russian (2) ──────────────────────────────────────────────────

-- 9. Russian Blini
('GzMC0PM93YA', 'cook',
 'Тонкие БЛИНЫ — Бабушкин Рецепт',
 'Grandma''s thin blini (Russian crepes). Perfect for breakfast with sour cream or jam.',
 'Вкусная Кухня',
 'https://img.youtube.com/vi/GzMC0PM93YA/hqdefault.jpg',
 'https://www.youtube.com/embed/GzMC0PM93YA',
 ARRAY['блины', 'blini', 'russian', 'breakfast', 'crepes', 'русская-кухня'],
 5600,
 '{"title": "Тонкие Блины (Russian Blini)", "servings": 15, "prep_time": "10 min", "cook_time": "20 min", "difficulty": "Easy", "ingredients": ["2 eggs", "500ml milk", "200g flour", "2 tbsp sugar", "1/2 tsp salt", "2 tbsp vegetable oil", "Butter for pan"], "steps": ["Beat eggs with sugar and salt.", "Add half the milk, whisk in flour gradually (no lumps!).", "Add remaining milk and oil. Rest batter 15 min.", "Heat pan, brush with butter.", "Pour thin layer of batter, swirl to cover pan.", "Cook 1 min, flip, cook 30 sec. Stack on plate."]}'
),

-- 10. Борщ (Borscht)
('kT74CjOL6rQ', 'cook',
 'Настоящий БОРЩ — Классический Рецепт',
 'The real Ukrainian/Russian borscht. Deep red, hearty, served with sour cream and garlic bread.',
 'Кулинарный Канал',
 'https://img.youtube.com/vi/kT74CjOL6rQ/hqdefault.jpg',
 'https://www.youtube.com/embed/kT74CjOL6rQ',
 ARRAY['борщ', 'borscht', 'russian', 'soup', 'beet', 'русская-кухня'],
 8100,
 '{"title": "Борщ (Classic Borscht)", "servings": 6, "prep_time": "20 min", "cook_time": "1.5 hours", "difficulty": "Medium", "ingredients": ["500g beef (bone-in)", "3 beets (grated)", "3 potatoes (cubed)", "1 carrot (grated)", "1 onion (diced)", "200g cabbage (shredded)", "2 tbsp tomato paste", "2 cloves garlic", "Fresh dill", "Bay leaf", "Vinegar (1 tsp)", "Sour cream for serving"], "steps": ["Boil beef in water for 1 hour to make broth. Skim foam.", "Sauté onion and carrot in oil. Add tomato paste.", "In separate pan, simmer grated beets with vinegar 15 min.", "Remove beef from broth. Add potatoes.", "After 10 min, add cabbage.", "Add sautéed vegetables and beets. Simmer 15 min.", "Add garlic and dill. Season. Serve with sour cream."]}'
)
ON CONFLICT (youtube_id) DO NOTHING;


-- ═══════════════════════════════════════════════════════════════════
-- ORDER TAB — 10 foreign food/restaurant shorts
-- ═══════════════════════════════════════════════════════════════════

INSERT INTO video_feeds (youtube_id, tab_type, title, description, author_name, thumbnail_url, embed_url, tags, likes) VALUES

-- ── English (6) ──────────────────────────────────────────────────

-- 1. NYC Street Food
('zfmVjQ-mHBg', 'order',
 '$1 vs $100 Street Food in NYC',
 'Comparing the cheapest and most expensive street food in New York City. Which is worth it?',
 'Food Ranger',
 'https://img.youtube.com/vi/zfmVjQ-mHBg/hqdefault.jpg',
 'https://www.youtube.com/embed/zfmVjQ-mHBg',
 ARRAY['nyc', 'street-food', 'comparison', 'budget', 'english'],
 18500
),

-- 2. Turkish Street Food
('WLuVnqxmnwc', 'order',
 'Turkish Street Food That Broke the Internet',
 'The famous Turkish chef''s incredible knife skills and ice cream tricks.',
 'Best Ever Food Review',
 'https://img.youtube.com/vi/WLuVnqxmnwc/hqdefault.jpg',
 'https://www.youtube.com/embed/WLuVnqxmnwc',
 ARRAY['turkish', 'street-food', 'viral', 'skills', 'english'],
 24000
),

-- 3. Japan Street Food
('rY-FJvRqK0E', 'order',
 'Japanese Street Food — Tsukiji Market Tour',
 'Walking through Tokyo''s famous Tsukiji fish market. The freshest sushi you''ll ever see.',
 'Abroad in Japan',
 'https://img.youtube.com/vi/rY-FJvRqK0E/hqdefault.jpg',
 'https://www.youtube.com/embed/rY-FJvRqK0E',
 ARRAY['japan', 'tsukiji', 'sushi', 'market', 'tokyo', 'english'],
 12400
),

-- 4. Gordon Ramsay Restaurant
('n_DTCX0g3Dw', 'order',
 'I Ate at Gordon Ramsay''s Restaurant',
 'Is the world''s most famous chef''s restaurant actually worth the £200 price tag?',
 'Food Review Club',
 'https://img.youtube.com/vi/n_DTCX0g3Dw/hqdefault.jpg',
 'https://www.youtube.com/embed/n_DTCX0g3Dw',
 ARRAY['gordon-ramsay', 'fine-dining', 'restaurant', 'review', 'english'],
 9800
),

-- 5. Mexican Street Food
('KDOqEbTNIKo', 'order',
 'Mexican Street Tacos at 3AM',
 'The best tacos in Mexico City are served at 3 in the morning. Al pastor from a street cart.',
 'Mark Wiens',
 'https://img.youtube.com/vi/KDOqEbTNIKo/hqdefault.jpg',
 'https://www.youtube.com/embed/KDOqEbTNIKo',
 ARRAY['mexico', 'tacos', 'street-food', 'al-pastor', 'night', 'english'],
 14200
),

-- 6. Indian Street Food
('CY8cjHbV4ME', 'order',
 'India''s CRAZIEST Street Food — Mumbai Edition',
 'Pav bhaji, vada pav, and the legendary Mumbai sandwich. Indian street food is unmatched.',
 'Davidsbeenhere',
 'https://img.youtube.com/vi/CY8cjHbV4ME/hqdefault.jpg',
 'https://www.youtube.com/embed/CY8cjHbV4ME',
 ARRAY['india', 'mumbai', 'street-food', 'pav-bhaji', 'english'],
 11300
),

-- ── Korean (2) ───────────────────────────────────────────────────

-- 7. Korean Fried Chicken
('KcT-54Mhruk', 'order',
 '치킨 먹방 — 양념 치킨 리뷰',
 'Korean fried chicken mukbang. Comparing the top 3 chicken chains: BBQ, Kyochon, and BHC.',
 '먹방TV',
 'https://img.youtube.com/vi/KcT-54Mhruk/hqdefault.jpg',
 'https://www.youtube.com/embed/KcT-54Mhruk',
 ARRAY['치킨', 'mukbang', 'korean', 'fried-chicken', '먹방'],
 16800
),

-- 8. Korean Night Market
('m3xK-ib-v9g', 'order',
 '광장시장 먹방 투어 — 서울 야시장',
 'Seoul''s famous Gwangjang Market night food tour. Bindaetteok, mayak kimbap, and more.',
 '맛있는 서울',
 'https://img.youtube.com/vi/m3xK-ib-v9g/hqdefault.jpg',
 'https://www.youtube.com/embed/m3xK-ib-v9g',
 ARRAY['광장시장', 'seoul', 'night-market', 'korean', 'tour'],
 7500
),

-- ── Russian (2) ──────────────────────────────────────────────────

-- 9. Moscow Food Tour
('6tV_06TQPPo', 'order',
 'Уличная ЕДА в Москве — Что Попробовать?',
 'Moscow street food tour — from blini stalls to Georgian khachapuri. What to eat in Russia.',
 'Еда и Путешествия',
 'https://img.youtube.com/vi/6tV_06TQPPo/hqdefault.jpg',
 'https://www.youtube.com/embed/6tV_06TQPPo',
 ARRAY['москва', 'moscow', 'russian', 'street-food', 'tour', 'русская-кухня'],
 5400
),

-- 10. Russian Market Food
('aDJhSvgKNwQ', 'order',
 'Рынок в Москве — Лучшая ЕДА',
 'Exploring a Russian food market — tasting fresh cheeses, smoked meats, and pickled everything.',
 'Русский Фуд Блог',
 'https://img.youtube.com/vi/aDJhSvgKNwQ/hqdefault.jpg',
 'https://www.youtube.com/embed/aDJhSvgKNwQ',
 ARRAY['рынок', 'market', 'russian', 'cheese', 'food-tour', 'русская-кухня'],
 3900
)
ON CONFLICT (youtube_id) DO NOTHING;

SELECT 'Foreign videos added! Total: ' || count(*) || ' videos (' ||
  (SELECT count(*) FROM video_feeds WHERE tab_type = 'cook') || ' cook, ' ||
  (SELECT count(*) FROM video_feeds WHERE tab_type = 'order') || ' order)' as result
FROM video_feeds;
