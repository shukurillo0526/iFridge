-- ============================================================
-- I-Fridge — Extended Ingredient Seed (Part 1: Vegetables, Protein, Dairy)
-- ============================================================
-- Uses ON CONFLICT to be re-runnable safely.
-- Run migration_008 first!

-- ── VEGETABLES ──────────────────────────────────────────────

INSERT INTO ingredients(canonical_name,display_name_en,display_name_ko,category,sub_category,default_unit,sealed_shelf_life_days,opened_shelf_life_days,storage_zone,calories_per_100g,unit_conversions) VALUES
('potato','Potato','감자','vegetable','root','piece',21,7,'pantry',77,'{"piece_to_g":150,"cup_to_g":170}'),
('carrot','Carrot','당근','vegetable','root','piece',28,7,'fridge',41,'{"piece_to_g":80,"cup_to_g":130}'),
('onion','Onion','양파','vegetable','allium','piece',60,7,'pantry',40,'{"piece_to_g":150,"cup_to_g":160}'),
('garlic','Garlic','마늘','vegetable','allium','clove',120,14,'pantry',149,'{"clove_to_g":4,"piece_to_g":50}'),
('tomato','Tomato','토마토','vegetable','fruit_veg','piece',7,3,'fridge',18,'{"piece_to_g":180,"cup_to_g":180}'),
('bell_pepper','Bell Pepper','파프리카','vegetable','fruit_veg','piece',14,5,'fridge',31,'{"piece_to_g":120,"cup_to_g":150}'),
('cucumber','Cucumber','오이','vegetable','fruit_veg','piece',7,3,'fridge',15,'{"piece_to_g":300,"cup_to_g":120}'),
('mushroom','Mushroom','버섯','vegetable','fungi','g',7,3,'fridge',22,'{"piece_to_g":20,"cup_to_g":70}'),
('broccoli','Broccoli','브로콜리','vegetable','cruciferous','piece',7,3,'fridge',34,'{"piece_to_g":350,"cup_to_g":90}'),
('spinach','Spinach','시금치','vegetable','leafy','g',5,2,'fridge',23,'{"cup_to_g":30}'),
('lettuce','Lettuce','상추','vegetable','leafy','piece',7,3,'fridge',15,'{"piece_to_g":300,"cup_to_g":50}'),
('cabbage','Cabbage','양배추','vegetable','cruciferous','piece',30,7,'fridge',25,'{"piece_to_g":1000,"cup_to_g":90}'),
('corn','Corn','옥수수','vegetable','grain_veg','piece',5,2,'fridge',96,'{"piece_to_g":150,"cup_to_g":165}'),
('eggplant','Eggplant','가지','vegetable','fruit_veg','piece',7,3,'fridge',25,'{"piece_to_g":500,"cup_to_g":80}'),
('zucchini','Zucchini','주키니','vegetable','fruit_veg','piece',7,3,'fridge',17,'{"piece_to_g":200,"cup_to_g":120}'),
('celery','Celery','셀러리','vegetable','stem','piece',14,7,'fridge',16,'{"piece_to_g":40,"cup_to_g":100}'),
('leek','Leek','대파','vegetable','allium','piece',14,5,'fridge',61,'{"piece_to_g":150,"cup_to_g":90}'),
('green_onion','Green Onion','쪽파','vegetable','allium','piece',7,3,'fridge',32,'{"piece_to_g":15,"cup_to_g":100}'),
('ginger','Ginger','생강','vegetable','root','piece',21,14,'pantry',80,'{"piece_to_g":50,"tbsp_to_g":6}'),
('beet','Beet','비트','vegetable','root','piece',21,5,'fridge',43,'{"piece_to_g":150}'),
('radish','Radish','무','vegetable','root','piece',14,5,'fridge',16,'{"piece_to_g":120}'),
('sweet_potato','Sweet Potato','고구마','vegetable','root','piece',30,5,'pantry',86,'{"piece_to_g":200,"cup_to_g":200}'),
('pumpkin','Pumpkin','호박','vegetable','squash','piece',90,5,'pantry',26,'{"piece_to_g":5000,"cup_to_g":120}'),
('asparagus','Asparagus','아스파라거스','vegetable','stem','piece',5,2,'fridge',20,'{"piece_to_g":16,"cup_to_g":134}'),
('cauliflower','Cauliflower','콜리플라워','vegetable','cruciferous','piece',7,3,'fridge',25,'{"piece_to_g":600,"cup_to_g":100}'),
('kale','Kale','케일','vegetable','leafy','g',7,3,'fridge',49,'{"cup_to_g":70}'),
('green_bean','Green Bean','강낭콩 줄기','vegetable','pod','g',5,3,'fridge',31,'{"cup_to_g":125}'),
('pea','Peas','완두콩','vegetable','pod','g',5,3,'fridge',81,'{"cup_to_g":145}'),
('turnip','Turnip','순무','vegetable','root','piece',21,5,'fridge',28,'{"piece_to_g":120}'),
('parsnip','Parsnip','파스닙','vegetable','root','piece',21,5,'fridge',75,'{"piece_to_g":170}'),
('artichoke','Artichoke','아티초크','vegetable','thistle','piece',7,3,'fridge',47,'{"piece_to_g":300}'),
('fennel','Fennel','회향','vegetable','stem','piece',10,5,'fridge',31,'{"piece_to_g":250}'),
('okra','Okra','오크라','vegetable','pod','g',5,2,'fridge',33,'{"piece_to_g":12,"cup_to_g":100}'),
('jalapeno','Jalapeño','할라피뇨','vegetable','pepper','piece',14,5,'fridge',29,'{"piece_to_g":14}'),
('korean_chili_pepper','Korean Chili Pepper','고추','vegetable','pepper','piece',7,3,'fridge',40,'{"piece_to_g":8}'),
('daikon','Daikon','큰무','vegetable','root','piece',21,5,'fridge',18,'{"piece_to_g":700}'),
('bean_sprouts','Bean Sprouts','콩나물','vegetable','sprout','g',3,1,'fridge',31,'{"cup_to_g":105}'),
('water_chestnut','Water Chestnut','마름','vegetable','aquatic','g',14,5,'fridge',97,'{"cup_to_g":140}'),
('bamboo_shoots','Bamboo Shoots','죽순','vegetable','stem','g',7,3,'fridge',27,'{"cup_to_g":150}')
ON CONFLICT (canonical_name) DO UPDATE SET
  display_name_ko=EXCLUDED.display_name_ko,
  sub_category=EXCLUDED.sub_category,
  sealed_shelf_life_days=EXCLUDED.sealed_shelf_life_days,
  opened_shelf_life_days=EXCLUDED.opened_shelf_life_days,
  calories_per_100g=EXCLUDED.calories_per_100g,
  unit_conversions=EXCLUDED.unit_conversions;

-- ── PROTEIN ──────────────────────────────────────────────────

INSERT INTO ingredients(canonical_name,display_name_en,display_name_ko,category,sub_category,default_unit,sealed_shelf_life_days,opened_shelf_life_days,storage_zone,calories_per_100g,unit_conversions) VALUES
('chicken','Chicken','닭고기','protein','poultry','g',3,2,'fridge',239,'{"piece_to_g":250}'),
('chicken_breast','Chicken Breast','닭가슴살','protein','poultry','g',3,2,'fridge',165,'{"piece_to_g":200}'),
('chicken_thigh','Chicken Thigh','닭다리','protein','poultry','g',3,2,'fridge',209,'{"piece_to_g":150}'),
('chicken_wing','Chicken Wing','닭날개','protein','poultry','g',3,2,'fridge',203,'{"piece_to_g":80}'),
('beef','Beef','소고기','protein','red_meat','g',5,2,'fridge',250,'{}'),
('beef_ground','Ground Beef','소고기 다짐','protein','red_meat','g',3,1,'fridge',254,'{"cup_to_g":225}'),
('beef_steak','Beef Steak','소고기 스테이크','protein','red_meat','g',5,2,'fridge',271,'{"piece_to_g":225}'),
('lamb','Lamb','양고기','protein','red_meat','g',5,2,'fridge',294,'{}'),
('pork','Pork','돼지고기','protein','red_meat','g',5,2,'fridge',242,'{}'),
('pork_belly','Pork Belly','삼겹살','protein','red_meat','g',4,2,'fridge',518,'{}'),
('bacon','Bacon','베이컨','protein','processed','g',14,7,'fridge',417,'{"slice_to_g":12}'),
('sausage','Sausage','소시지','protein','processed','piece',14,5,'fridge',301,'{"piece_to_g":60}'),
('ham','Ham','햄','protein','processed','g',30,7,'fridge',145,'{"slice_to_g":30}'),
('turkey','Turkey','칠면조','protein','poultry','g',3,2,'fridge',189,'{}'),
('duck','Duck','오리','protein','poultry','g',3,2,'fridge',337,'{}'),
('tofu','Tofu','두부','protein','plant','g',7,3,'fridge',76,'{"piece_to_g":340,"cup_to_g":250}'),
('egg','Egg','계란','protein','egg','piece',28,3,'fridge',155,'{"piece_to_g":60}'),
('quail_egg','Quail Egg','메추리알','protein','egg','piece',21,3,'fridge',158,'{"piece_to_g":10}')
ON CONFLICT (canonical_name) DO UPDATE SET
  display_name_ko=EXCLUDED.display_name_ko,
  sub_category=EXCLUDED.sub_category,
  sealed_shelf_life_days=EXCLUDED.sealed_shelf_life_days,
  opened_shelf_life_days=EXCLUDED.opened_shelf_life_days,
  calories_per_100g=EXCLUDED.calories_per_100g,
  unit_conversions=EXCLUDED.unit_conversions;

-- ── SEAFOOD ──────────────────────────────────────────────────

INSERT INTO ingredients(canonical_name,display_name_en,display_name_ko,category,sub_category,default_unit,sealed_shelf_life_days,opened_shelf_life_days,storage_zone,calories_per_100g,unit_conversions) VALUES
('salmon','Salmon','연어','seafood','fish','g',3,1,'fridge',208,'{"piece_to_g":170}'),
('tuna','Tuna','참치','seafood','fish','g',2,1,'fridge',132,'{"piece_to_g":150}'),
('cod','Cod','대구','seafood','fish','g',3,1,'fridge',82,'{"piece_to_g":200}'),
('mackerel','Mackerel','고등어','seafood','fish','g',2,1,'fridge',205,'{"piece_to_g":300}'),
('shrimp','Shrimp','새우','seafood','shellfish','g',3,1,'fridge',99,'{"piece_to_g":8}'),
('squid','Squid','오징어','seafood','mollusk','g',2,1,'fridge',92,'{"piece_to_g":250}'),
('clam','Clam','조개','seafood','shellfish','g',2,1,'fridge',74,'{"piece_to_g":12}'),
('mussel','Mussel','홍합','seafood','shellfish','g',2,1,'fridge',86,'{"piece_to_g":15}'),
('crab','Crab','게','seafood','shellfish','g',2,1,'fridge',97,'{"piece_to_g":500}'),
('anchovy','Anchovy','멸치','seafood','fish','g',365,30,'pantry',131,'{"piece_to_g":4}'),
('sardine','Sardine','정어리','seafood','fish','g',3,1,'fridge',208,'{"piece_to_g":50}'),
('octopus','Octopus','문어','seafood','mollusk','g',2,1,'fridge',82,'{}'),
('seaweed','Seaweed','김','seafood','plant','g',365,90,'pantry',45,'{"sheet_to_g":3}')
ON CONFLICT (canonical_name) DO UPDATE SET
  display_name_ko=EXCLUDED.display_name_ko,
  sub_category=EXCLUDED.sub_category,
  sealed_shelf_life_days=EXCLUDED.sealed_shelf_life_days,
  opened_shelf_life_days=EXCLUDED.opened_shelf_life_days,
  calories_per_100g=EXCLUDED.calories_per_100g,
  unit_conversions=EXCLUDED.unit_conversions;

-- ── DAIRY ──────────────────────────────────────────────────

INSERT INTO ingredients(canonical_name,display_name_en,display_name_ko,category,sub_category,default_unit,sealed_shelf_life_days,opened_shelf_life_days,storage_zone,calories_per_100g,unit_conversions) VALUES
('milk','Milk','우유','dairy','milk','ml',10,5,'fridge',61,'{"cup_to_ml":240}'),
('cream','Heavy Cream','생크림','dairy','cream','ml',21,5,'fridge',340,'{"cup_to_ml":240,"tbsp_to_ml":15}'),
('sour_cream','Sour Cream','사워크림','dairy','cream','g',21,7,'fridge',198,'{"cup_to_g":230,"tbsp_to_g":15}'),
('yogurt','Yogurt','요거트','dairy','fermented','g',21,5,'fridge',59,'{"cup_to_g":245}'),
('butter','Butter','버터','dairy','fat','g',90,30,'fridge',717,'{"tbsp_to_g":14,"cup_to_g":227}'),
('cheese','Cheese','치즈','dairy','cheese','g',60,14,'fridge',402,'{"slice_to_g":28,"cup_to_g":113}'),
('mozzarella','Mozzarella','모짜렐라','dairy','cheese','g',30,7,'fridge',280,'{"cup_to_g":113}'),
('parmesan','Parmesan','파마산','dairy','cheese','g',180,30,'fridge',431,'{"tbsp_to_g":5}'),
('cream_cheese','Cream Cheese','크림치즈','dairy','cheese','g',30,14,'fridge',342,'{"tbsp_to_g":15}'),
('feta','Feta','페타','dairy','cheese','g',30,7,'fridge',264,'{}'),
('condensed_milk','Condensed Milk','연유','dairy','milk','ml',365,14,'pantry',321,'{"tbsp_to_ml":15}'),
('whipped_cream','Whipped Cream','휘핑크림','dairy','cream','ml',14,3,'fridge',257,'{"cup_to_ml":60}')
ON CONFLICT (canonical_name) DO UPDATE SET
  display_name_ko=EXCLUDED.display_name_ko,
  sub_category=EXCLUDED.sub_category,
  sealed_shelf_life_days=EXCLUDED.sealed_shelf_life_days,
  opened_shelf_life_days=EXCLUDED.opened_shelf_life_days,
  calories_per_100g=EXCLUDED.calories_per_100g,
  unit_conversions=EXCLUDED.unit_conversions;
