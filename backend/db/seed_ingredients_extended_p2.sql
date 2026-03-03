-- ============================================================
-- I-Fridge — Extended Ingredient Seed (Part 2: Grains, Baking, Spices, Condiments)
-- ============================================================

-- ── GRAINS & PASTA ──────────────────────────────────────────

INSERT INTO ingredients(canonical_name,display_name_en,display_name_ko,category,sub_category,default_unit,sealed_shelf_life_days,opened_shelf_life_days,storage_zone,calories_per_100g,unit_conversions) VALUES
('rice','Rice','쌀','grain','rice','cup',730,180,'pantry',130,'{"cup_to_g":185}'),
('brown_rice','Brown Rice','현미','grain','rice','cup',365,90,'pantry',111,'{"cup_to_g":190}'),
('basmati_rice','Basmati Rice','바스마티 쌀','grain','rice','cup',730,180,'pantry',121,'{"cup_to_g":185}'),
('glutinous_rice','Glutinous Rice','찹쌀','grain','rice','cup',730,180,'pantry',97,'{"cup_to_g":185}'),
('pasta','Pasta','파스타','grain','pasta','g',730,180,'pantry',131,'{"cup_to_g":140}'),
('spaghetti','Spaghetti','스파게티','grain','pasta','g',730,180,'pantry',131,'{"cup_to_g":140}'),
('penne','Penne','펜네','grain','pasta','g',730,180,'pantry',131,'{"cup_to_g":145}'),
('ramen_noodles','Ramen Noodles','라면','grain','noodle','g',180,1,'pantry',436,'{"piece_to_g":100}'),
('rice_noodles','Rice Noodles','쌀국수','grain','noodle','g',365,90,'pantry',109,'{"cup_to_g":175}'),
('udon','Udon Noodles','우동','grain','noodle','g',3,1,'fridge',99,'{"cup_to_g":176}'),
('bread','Bread','빵','grain','bread','slice',7,3,'pantry',265,'{"slice_to_g":30,"piece_to_g":400}'),
('naan','Naan','난','grain','bread','piece',3,1,'pantry',262,'{"piece_to_g":90}'),
('tortilla','Tortilla','또르띠야','grain','bread','piece',14,5,'pantry',306,'{"piece_to_g":50}'),
('breadcrumbs','Breadcrumbs','빵가루','grain','processed','cup',180,60,'pantry',395,'{"cup_to_g":115}'),
('oats','Oats','귀리','grain','cereal','cup',365,90,'pantry',389,'{"cup_to_g":80}'),
('quinoa','Quinoa','퀴노아','grain','seed','cup',365,180,'pantry',120,'{"cup_to_g":170}'),
('couscous','Couscous','쿠스쿠스','grain','pasta','cup',365,180,'pantry',112,'{"cup_to_g":175}'),
('cornstarch','Cornstarch','전분','grain','starch','tbsp',730,365,'pantry',381,'{"tbsp_to_g":8,"cup_to_g":128}')
ON CONFLICT (canonical_name) DO UPDATE SET
  display_name_ko=EXCLUDED.display_name_ko, sub_category=EXCLUDED.sub_category,
  sealed_shelf_life_days=EXCLUDED.sealed_shelf_life_days, opened_shelf_life_days=EXCLUDED.opened_shelf_life_days,
  calories_per_100g=EXCLUDED.calories_per_100g, unit_conversions=EXCLUDED.unit_conversions;

-- ── BAKING ──────────────────────────────────────────────────

INSERT INTO ingredients(canonical_name,display_name_en,display_name_ko,category,sub_category,default_unit,sealed_shelf_life_days,opened_shelf_life_days,storage_zone,calories_per_100g,unit_conversions) VALUES
('flour','Flour','밀가루','baking','flour','cup',365,180,'pantry',364,'{"cup_to_g":125,"tbsp_to_g":8}'),
('whole_wheat_flour','Whole Wheat Flour','통밀가루','baking','flour','cup',180,90,'pantry',340,'{"cup_to_g":120}'),
('sugar','Sugar','설탕','baking','sweetener','cup',730,365,'pantry',387,'{"cup_to_g":200,"tbsp_to_g":13,"tsp_to_g":4}'),
('brown_sugar','Brown Sugar','흑설탕','baking','sweetener','cup',730,180,'pantry',380,'{"cup_to_g":220}'),
('powdered_sugar','Powdered Sugar','슈가파우더','baking','sweetener','cup',730,365,'pantry',389,'{"cup_to_g":120}'),
('honey','Honey','꿀','baking','sweetener','tbsp',730,365,'pantry',304,'{"tbsp_to_g":21,"cup_to_g":340}'),
('maple_syrup','Maple Syrup','메이플시럽','baking','sweetener','tbsp',365,180,'pantry',260,'{"tbsp_to_g":20}'),
('baking_soda','Baking Soda','베이킹소다','baking','leavener','tsp',730,365,'pantry',0,'{"tsp_to_g":5}'),
('baking_powder','Baking Powder','베이킹파우더','baking','leavener','tsp',365,180,'pantry',53,'{"tsp_to_g":5}'),
('yeast','Yeast','이스트','baking','leavener','tsp',365,90,'pantry',325,'{"tsp_to_g":4}'),
('vanilla_extract','Vanilla Extract','바닐라 엑기스','baking','extract','tsp',730,365,'pantry',288,'{"tsp_to_g":4}'),
('cocoa_powder','Cocoa Powder','코코아 파우더','baking','powder','tbsp',730,365,'pantry',228,'{"tbsp_to_g":5,"cup_to_g":85}'),
('chocolate','Chocolate','초콜릿','baking','chocolate','g',365,30,'pantry',546,'{}'),
('gelatin','Gelatin','젤라틴','baking','gelling','g',730,180,'pantry',335,'{"tsp_to_g":3}')
ON CONFLICT (canonical_name) DO UPDATE SET
  display_name_ko=EXCLUDED.display_name_ko, sub_category=EXCLUDED.sub_category,
  sealed_shelf_life_days=EXCLUDED.sealed_shelf_life_days, opened_shelf_life_days=EXCLUDED.opened_shelf_life_days,
  calories_per_100g=EXCLUDED.calories_per_100g, unit_conversions=EXCLUDED.unit_conversions;

-- ── SPICES & SEASONINGS ─────────────────────────────────────

INSERT INTO ingredients(canonical_name,display_name_en,display_name_ko,category,sub_category,default_unit,sealed_shelf_life_days,opened_shelf_life_days,storage_zone,calories_per_100g,unit_conversions) VALUES
('salt','Salt','소금','seasoning','mineral','tsp',1825,1825,'pantry',0,'{"tsp_to_g":6,"tbsp_to_g":18}'),
('black_pepper','Black Pepper','후추','seasoning','ground','tsp',730,365,'pantry',251,'{"tsp_to_g":2}'),
('white_pepper','White Pepper','흰 후추','seasoning','ground','tsp',730,365,'pantry',296,'{"tsp_to_g":2}'),
('cumin','Cumin','쿠민','seasoning','ground','tsp',730,365,'pantry',375,'{"tsp_to_g":2}'),
('paprika','Paprika','파프리카 파우더','seasoning','ground','tsp',730,365,'pantry',282,'{"tsp_to_g":2}'),
('turmeric','Turmeric','강황','seasoning','ground','tsp',730,365,'pantry',354,'{"tsp_to_g":3}'),
('cinnamon','Cinnamon','시나몬','seasoning','ground','tsp',730,365,'pantry',247,'{"tsp_to_g":3}'),
('nutmeg','Nutmeg','넛맥','seasoning','ground','tsp',730,365,'pantry',525,'{"tsp_to_g":2}'),
('oregano','Oregano','오레가노','seasoning','dried_herb','tsp',730,365,'pantry',265,'{"tsp_to_g":2}'),
('basil','Basil','바질','seasoning','fresh_herb','g',5,2,'fridge',23,'{"cup_to_g":24}'),
('parsley','Parsley','파슬리','seasoning','fresh_herb','g',7,3,'fridge',36,'{"cup_to_g":60}'),
('cilantro','Cilantro','고수','seasoning','fresh_herb','g',5,2,'fridge',23,'{"cup_to_g":16}'),
('rosemary','Rosemary','로즈마리','seasoning','fresh_herb','g',14,5,'fridge',131,'{"tsp_to_g":1}'),
('thyme','Thyme','타임','seasoning','dried_herb','tsp',730,365,'pantry',276,'{"tsp_to_g":1}'),
('bay_leaf','Bay Leaf','월계수잎','seasoning','whole','piece',730,365,'pantry',313,'{"piece_to_g":1}'),
('chili_flakes','Chili Flakes','고춧가루','seasoning','ground','tsp',365,180,'pantry',282,'{"tsp_to_g":2,"tbsp_to_g":5}'),
('korean_chili_flakes','Korean Chili Flakes','고춧가루','seasoning','ground','tbsp',365,180,'pantry',282,'{"tbsp_to_g":5}'),
('curry_powder','Curry Powder','카레 파우더','seasoning','blend','tsp',730,365,'pantry',325,'{"tsp_to_g":2}'),
('five_spice','Five Spice','오향분','seasoning','blend','tsp',730,365,'pantry',0,'{"tsp_to_g":2}'),
('msg','MSG','미원','seasoning','enhancer','tsp',1825,1825,'pantry',0,'{"tsp_to_g":5}'),
('coriander','Coriander Seeds','코리앤더','seasoning','whole','tsp',730,365,'pantry',298,'{"tsp_to_g":2}'),
('cardamom','Cardamom','카다몸','seasoning','whole','piece',730,365,'pantry',311,'{"piece_to_g":2}'),
('star_anise','Star Anise','팔각','seasoning','whole','piece',730,365,'pantry',337,'{"piece_to_g":3}'),
('clove','Clove','정향','seasoning','whole','piece',730,365,'pantry',274,'{"piece_to_g":1}'),
('dill','Dill','딜','seasoning','fresh_herb','g',5,2,'fridge',43,'{"cup_to_g":10}'),
('mint','Mint','민트','seasoning','fresh_herb','g',5,2,'fridge',44,'{"cup_to_g":10}')
ON CONFLICT (canonical_name) DO UPDATE SET
  display_name_ko=EXCLUDED.display_name_ko, sub_category=EXCLUDED.sub_category,
  sealed_shelf_life_days=EXCLUDED.sealed_shelf_life_days, opened_shelf_life_days=EXCLUDED.opened_shelf_life_days,
  calories_per_100g=EXCLUDED.calories_per_100g, unit_conversions=EXCLUDED.unit_conversions;

-- ── CONDIMENTS & SAUCES ─────────────────────────────────────

INSERT INTO ingredients(canonical_name,display_name_en,display_name_ko,category,sub_category,default_unit,sealed_shelf_life_days,opened_shelf_life_days,storage_zone,calories_per_100g,unit_conversions) VALUES
('soy_sauce','Soy Sauce','간장','condiment','sauce','tbsp',730,180,'pantry',53,'{"tbsp_to_ml":15,"cup_to_ml":240}'),
('fish_sauce','Fish Sauce','액젓','condiment','sauce','tbsp',730,180,'pantry',35,'{"tbsp_to_ml":15}'),
('oyster_sauce','Oyster Sauce','굴소스','condiment','sauce','tbsp',365,90,'fridge',51,'{"tbsp_to_ml":15}'),
('sesame_oil','Sesame Oil','참기름','condiment','oil','tsp',365,90,'pantry',884,'{"tsp_to_ml":5,"tbsp_to_ml":15}'),
('rice_vinegar','Rice Vinegar','식초','condiment','vinegar','tbsp',730,365,'pantry',18,'{"tbsp_to_ml":15}'),
('vinegar','Vinegar','식초','condiment','vinegar','tbsp',1825,730,'pantry',18,'{"tbsp_to_ml":15}'),
('tomato_paste','Tomato Paste','토마토 페이스트','condiment','paste','tbsp',365,7,'fridge',82,'{"tbsp_to_g":16}'),
('ketchup','Ketchup','케첩','condiment','sauce','tbsp',365,30,'fridge',112,'{"tbsp_to_g":17}'),
('mustard','Mustard','머스타드','condiment','sauce','tsp',365,90,'fridge',66,'{"tsp_to_g":5}'),
('mayonnaise','Mayonnaise','마요네즈','condiment','sauce','tbsp',365,60,'fridge',680,'{"tbsp_to_g":14}'),
('hot_sauce','Hot Sauce','핫소스','condiment','sauce','tsp',730,180,'pantry',11,'{"tsp_to_ml":5}'),
('gochujang','Gochujang','고추장','condiment','paste','tbsp',365,90,'fridge',228,'{"tbsp_to_g":17}'),
('doenjang','Doenjang','된장','condiment','paste','tbsp',365,90,'fridge',128,'{"tbsp_to_g":18}'),
('miso','Miso','미소','condiment','paste','tbsp',365,90,'fridge',199,'{"tbsp_to_g":17}'),
('worcestershire','Worcestershire Sauce','우스터 소스','condiment','sauce','tsp',730,180,'pantry',78,'{"tsp_to_ml":5}'),
('sriracha','Sriracha','스리라차','condiment','sauce','tsp',365,180,'pantry',93,'{"tsp_to_g":7}'),
('tahini','Tahini','타히니','condiment','paste','tbsp',365,30,'pantry',595,'{"tbsp_to_g":15}'),
('peanut_butter','Peanut Butter','땅콩버터','condiment','paste','tbsp',365,90,'pantry',588,'{"tbsp_to_g":16}'),
('barbecue_sauce','BBQ Sauce','바베큐소스','condiment','sauce','tbsp',365,30,'fridge',172,'{"tbsp_to_g":17}')
ON CONFLICT (canonical_name) DO UPDATE SET
  display_name_ko=EXCLUDED.display_name_ko, sub_category=EXCLUDED.sub_category,
  sealed_shelf_life_days=EXCLUDED.sealed_shelf_life_days, opened_shelf_life_days=EXCLUDED.opened_shelf_life_days,
  calories_per_100g=EXCLUDED.calories_per_100g, unit_conversions=EXCLUDED.unit_conversions;
