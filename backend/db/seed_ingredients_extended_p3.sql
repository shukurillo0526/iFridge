-- ============================================================
-- I-Fridge — Extended Ingredient Seed (Part 3: Fruits, Oils, Legumes, Nuts, Beverages)
-- ============================================================

-- ── FRUITS ──────────────────────────────────────────────────

INSERT INTO ingredients(canonical_name,display_name_en,display_name_ko,category,sub_category,default_unit,sealed_shelf_life_days,opened_shelf_life_days,storage_zone,calories_per_100g,unit_conversions) VALUES
('apple','Apple','사과','fruit','pome','piece',21,5,'fridge',52,'{"piece_to_g":180}'),
('banana','Banana','바나나','fruit','tropical','piece',7,2,'pantry',89,'{"piece_to_g":120}'),
('orange','Orange','오렌지','fruit','citrus','piece',21,3,'fridge',47,'{"piece_to_g":130}'),
('lemon','Lemon','레몬','fruit','citrus','piece',30,5,'fridge',29,'{"piece_to_g":60,"tbsp_juice":15}'),
('lime','Lime','라임','fruit','citrus','piece',21,5,'fridge',30,'{"piece_to_g":50}'),
('strawberry','Strawberry','딸기','fruit','berry','g',5,2,'fridge',32,'{"piece_to_g":12,"cup_to_g":150}'),
('blueberry','Blueberry','블루베리','fruit','berry','g',10,3,'fridge',57,'{"cup_to_g":145}'),
('raspberry','Raspberry','라즈베리','fruit','berry','g',3,1,'fridge',52,'{"cup_to_g":125}'),
('grape','Grape','포도','fruit','vine','g',7,3,'fridge',69,'{"cup_to_g":150}'),
('watermelon','Watermelon','수박','fruit','melon','g',14,3,'fridge',30,'{"cup_to_g":155}'),
('melon','Melon','멜론','fruit','melon','piece',7,3,'fridge',34,'{"piece_to_g":1500}'),
('peach','Peach','복숭아','fruit','stone','piece',5,2,'fridge',39,'{"piece_to_g":150}'),
('plum','Plum','자두','fruit','stone','piece',5,2,'fridge',46,'{"piece_to_g":66}'),
('pineapple','Pineapple','파인애플','fruit','tropical','piece',7,3,'fridge',50,'{"piece_to_g":900,"cup_to_g":165}'),
('mango','Mango','망고','fruit','tropical','piece',7,3,'fridge',60,'{"piece_to_g":200,"cup_to_g":165}'),
('avocado','Avocado','아보카도','fruit','tropical','piece',5,2,'fridge',160,'{"piece_to_g":200}'),
('coconut','Coconut','코코넛','fruit','tropical','piece',30,5,'pantry',354,'{"piece_to_g":400}'),
('kiwi','Kiwi','키위','fruit','berry','piece',14,3,'fridge',61,'{"piece_to_g":75}'),
('pear','Pear','배','fruit','pome','piece',14,3,'fridge',57,'{"piece_to_g":180}'),
('cherry','Cherry','체리','fruit','stone','g',5,2,'fridge',50,'{"cup_to_g":155}'),
('pomegranate','Pomegranate','석류','fruit','berry','piece',30,5,'fridge',83,'{"piece_to_g":280}'),
('fig','Fig','무화과','fruit','tropical','piece',3,1,'fridge',74,'{"piece_to_g":50}'),
('date','Date','대추','fruit','palm','piece',180,30,'pantry',277,'{"piece_to_g":8}'),
('raisin','Raisin','건포도','fruit','dried','g',365,90,'pantry',299,'{"cup_to_g":145}'),
('dried_cranberry','Dried Cranberry','말린 크랜베리','fruit','dried','g',365,90,'pantry',308,'{"cup_to_g":120}'),
('coconut_milk','Coconut Milk','코코넛밀크','fruit','extract','ml',365,3,'pantry',230,'{"cup_to_ml":240}')
ON CONFLICT (canonical_name) DO UPDATE SET
  display_name_ko=EXCLUDED.display_name_ko, sub_category=EXCLUDED.sub_category,
  sealed_shelf_life_days=EXCLUDED.sealed_shelf_life_days, opened_shelf_life_days=EXCLUDED.opened_shelf_life_days,
  calories_per_100g=EXCLUDED.calories_per_100g, unit_conversions=EXCLUDED.unit_conversions;

-- ── OILS ──────────────────────────────────────────────────

INSERT INTO ingredients(canonical_name,display_name_en,display_name_ko,category,sub_category,default_unit,sealed_shelf_life_days,opened_shelf_life_days,storage_zone,calories_per_100g,unit_conversions) VALUES
('cooking_oil','Cooking Oil','식용유','oil','vegetable','tbsp',365,180,'pantry',884,'{"tbsp_to_ml":15,"cup_to_ml":240}'),
('olive_oil','Olive Oil','올리브유','oil','olive','tbsp',365,180,'pantry',884,'{"tbsp_to_ml":15}'),
('sunflower_oil','Sunflower Oil','해바라기유','oil','seed','tbsp',365,180,'pantry',884,'{"tbsp_to_ml":15}'),
('coconut_oil','Coconut Oil','코코넛오일','oil','tropical','tbsp',730,365,'pantry',862,'{"tbsp_to_g":14}'),
('canola_oil','Canola Oil','카놀라유','oil','seed','tbsp',365,180,'pantry',884,'{"tbsp_to_ml":15}'),
('avocado_oil','Avocado Oil','아보카도 오일','oil','fruit','tbsp',365,180,'pantry',884,'{"tbsp_to_ml":15}')
ON CONFLICT (canonical_name) DO UPDATE SET
  display_name_ko=EXCLUDED.display_name_ko, sub_category=EXCLUDED.sub_category,
  sealed_shelf_life_days=EXCLUDED.sealed_shelf_life_days, opened_shelf_life_days=EXCLUDED.opened_shelf_life_days,
  calories_per_100g=EXCLUDED.calories_per_100g, unit_conversions=EXCLUDED.unit_conversions;

-- ── LEGUMES ──────────────────────────────────────────────────

INSERT INTO ingredients(canonical_name,display_name_en,display_name_ko,category,sub_category,default_unit,sealed_shelf_life_days,opened_shelf_life_days,storage_zone,calories_per_100g,unit_conversions) VALUES
('beans','Beans','콩','legume','bean','cup',730,3,'pantry',347,'{"cup_to_g":180}'),
('black_bean','Black Bean','검은콩','legume','bean','cup',730,3,'pantry',341,'{"cup_to_g":185}'),
('kidney_bean','Kidney Bean','강낭콩','legume','bean','cup',730,3,'pantry',333,'{"cup_to_g":180}'),
('chickpea','Chickpea','병아리콩','legume','bean','cup',730,3,'pantry',364,'{"cup_to_g":165}'),
('lentil','Lentil','렌틸콩','legume','lentil','cup',730,5,'pantry',116,'{"cup_to_g":200}'),
('green_lentil','Green Lentil','녹색 렌틸','legume','lentil','cup',730,5,'pantry',116,'{"cup_to_g":200}'),
('red_lentil','Red Lentil','붉은 렌틸','legume','lentil','cup',730,5,'pantry',116,'{"cup_to_g":200}'),
('edamame','Edamame','풋콩','legume','bean','g',365,3,'freezer',121,'{"cup_to_g":155}'),
('mung_bean','Mung Bean','녹두','legume','bean','cup',730,5,'pantry',347,'{"cup_to_g":200}')
ON CONFLICT (canonical_name) DO UPDATE SET
  display_name_ko=EXCLUDED.display_name_ko, sub_category=EXCLUDED.sub_category,
  sealed_shelf_life_days=EXCLUDED.sealed_shelf_life_days, opened_shelf_life_days=EXCLUDED.opened_shelf_life_days,
  calories_per_100g=EXCLUDED.calories_per_100g, unit_conversions=EXCLUDED.unit_conversions;

-- ── NUTS & SEEDS ──────────────────────────────────────────────

INSERT INTO ingredients(canonical_name,display_name_en,display_name_ko,category,sub_category,default_unit,sealed_shelf_life_days,opened_shelf_life_days,storage_zone,calories_per_100g,unit_conversions) VALUES
('almond','Almond','아몬드','nut','tree_nut','g',180,30,'pantry',579,'{"cup_to_g":145,"piece_to_g":1}'),
('walnut','Walnut','호두','nut','tree_nut','g',180,30,'pantry',654,'{"cup_to_g":100}'),
('cashew','Cashew','캐슈넛','nut','tree_nut','g',180,30,'pantry',553,'{"cup_to_g":130}'),
('pistachio','Pistachio','피스타치오','nut','tree_nut','g',180,30,'pantry',560,'{"cup_to_g":125}'),
('peanut','Peanut','땅콩','nut','legume_nut','g',180,30,'pantry',567,'{"cup_to_g":145}'),
('pine_nut','Pine Nut','잣','nut','seed','g',90,14,'fridge',673,'{"tbsp_to_g":9}'),
('sesame_seed','Sesame Seeds','참깨','nut','seed','tbsp',365,90,'pantry',573,'{"tbsp_to_g":9}'),
('sunflower_seed','Sunflower Seeds','해바라기씨','nut','seed','g',180,30,'pantry',584,'{"cup_to_g":140}'),
('flax_seed','Flax Seeds','아마씨','nut','seed','tbsp',365,90,'pantry',534,'{"tbsp_to_g":7}'),
('chia_seed','Chia Seeds','치아씨','nut','seed','tbsp',365,90,'pantry',486,'{"tbsp_to_g":10}'),
('poppy_seed','Poppy Seeds','양귀비씨','nut','seed','tsp',365,90,'pantry',525,'{"tsp_to_g":3}')
ON CONFLICT (canonical_name) DO UPDATE SET
  display_name_ko=EXCLUDED.display_name_ko, sub_category=EXCLUDED.sub_category,
  sealed_shelf_life_days=EXCLUDED.sealed_shelf_life_days, opened_shelf_life_days=EXCLUDED.opened_shelf_life_days,
  calories_per_100g=EXCLUDED.calories_per_100g, unit_conversions=EXCLUDED.unit_conversions;

-- ── BEVERAGES ──────────────────────────────────────────────────

INSERT INTO ingredients(canonical_name,display_name_en,display_name_ko,category,sub_category,default_unit,sealed_shelf_life_days,opened_shelf_life_days,storage_zone,calories_per_100g,unit_conversions) VALUES
('coffee','Coffee','커피','beverage','hot','g',365,30,'pantry',0,'{"tsp_to_g":2}'),
('tea','Tea','차','beverage','hot','piece',730,365,'pantry',0,'{"piece_to_g":2}'),
('green_tea','Green Tea','녹차','beverage','hot','piece',730,365,'pantry',0,'{"piece_to_g":2}'),
('orange_juice','Orange Juice','오렌지 주스','beverage','juice','ml',14,5,'fridge',45,'{"cup_to_ml":240}'),
('apple_juice','Apple Juice','사과 주스','beverage','juice','ml',14,5,'fridge',46,'{"cup_to_ml":240}'),
('lemon_juice','Lemon Juice','레몬 즙','beverage','juice','tbsp',365,30,'fridge',22,'{"tbsp_to_ml":15}'),
('wine','Wine','와인','beverage','alcohol','ml',730,5,'pantry',83,'{"cup_to_ml":240}'),
('beer','Beer','맥주','beverage','alcohol','ml',365,1,'fridge',43,'{"cup_to_ml":355}'),
('rice_wine','Rice Wine (Mirin)','미림','beverage','cooking','tbsp',365,90,'pantry',207,'{"tbsp_to_ml":15}')
ON CONFLICT (canonical_name) DO UPDATE SET
  display_name_ko=EXCLUDED.display_name_ko, sub_category=EXCLUDED.sub_category,
  sealed_shelf_life_days=EXCLUDED.sealed_shelf_life_days, opened_shelf_life_days=EXCLUDED.opened_shelf_life_days,
  calories_per_100g=EXCLUDED.calories_per_100g, unit_conversions=EXCLUDED.unit_conversions;
