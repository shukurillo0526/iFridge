-- ============================================================
-- I-Fridge — Seed: Famous World Recipes (Part 4) — R76-R100
-- ============================================================

CREATE OR REPLACE FUNCTION _ensure_ing(p_name TEXT, p_cat TEXT, p_unit TEXT)
RETURNS UUID LANGUAGE plpgsql AS $$
DECLARE
  p_id UUID;
BEGIN
  SELECT id INTO p_id FROM ingredients WHERE canonical_name = lower(replace(p_name,' ','_'));
  IF p_id IS NULL THEN
    INSERT INTO ingredients(canonical_name, display_name_en, category, default_unit)
    VALUES(lower(replace(p_name,' ','_')), p_name, p_cat, p_unit)
    RETURNING id INTO p_id;
  END IF;
  RETURN p_id;
END $$;

DO $$
DECLARE
  r_id UUID;
  v UUID; v2 UUID; v3 UUID; v4 UUID; v5 UUID; v6 UUID; v7 UUID; v8 UUID;
BEGIN

  -- ── R76: Risotto ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Mushroom Risotto','Creamy Italian rice with mushrooms','Italian',3,5,25,2,ARRAY['italian','rice','vegetarian'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Rice','grain','cup'); v2:=_ensure_ing('Mushroom','vegetable','g');
  v3:=_ensure_ing('Onion','vegetable','piece'); v4:=_ensure_ing('Butter','dairy','g');
  v5:=_ensure_ing('Garlic','vegetable','clove'); v6:=_ensure_ing('Salt','seasoning','tsp');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,1.5,'cup'),(r_id,v2,200,'g'),(r_id,v3,0.5,'piece'),(r_id,v4,40,'g'),(r_id,v5,2,'clove'),(r_id,v6,1,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Sauté diced onion and garlic in butter','{"action":"saute","item":"onion,garlic","minutes":2}'),
    (r_id,2,'Add rice, toast 1 min until translucent edges','{"action":"toast","item":"rice","minutes":1}'),
    (r_id,3,'Add hot water 1 ladle at a time, stirring constantly','{"action":"stir","item":"rice,water","minutes":18}'),
    (r_id,4,'Sauté mushrooms separately, add to risotto at end','{"action":"saute","item":"mushroom","minutes":4}'),
    (r_id,5,'Finish with butter, season','{"action":"stir","item":"butter,salt"}');

  -- ── R77: Chicken Quesadilla ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Chicken Quesadilla','Crispy tortilla filled with chicken and cheese','Mexican',1,5,8,2,ARRAY['mexican','chicken','quick','cheese'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Chicken','protein','g'); v2:=_ensure_ing('Flour','baking','cup');
  v3:=_ensure_ing('Cheese','dairy','g'); v4:=_ensure_ing('Cooking Oil','oil','tbsp');
  v5:=_ensure_ing('Salt','seasoning','tsp');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,200,'g'),(r_id,v2,1,'cup'),(r_id,v3,100,'g'),(r_id,v4,1,'tbsp'),(r_id,v5,0.5,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Shred or dice cooked chicken','{"action":"shred","item":"chicken"}'),
    (r_id,2,'Place chicken and cheese on one half of tortilla, fold','{"action":"assemble","item":"quesadilla"}'),
    (r_id,3,'Cook in dry pan 3 min per side until crispy','{"action":"cook","item":"quesadilla","minutes":6}'),
    (r_id,4,'Cut into triangles, serve','{"action":"slice","item":"quesadilla"}');

  -- ── R78: Korean Japchae ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Japchae','Korean sweet potato glass noodles with vegetables','Korean',2,10,15,3,ARRAY['korean','noodles','vegetarian'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Rice Noodles','grain','g'); v2:=_ensure_ing('Carrot','vegetable','piece');
  v3:=_ensure_ing('Onion','vegetable','piece'); v4:=_ensure_ing('Soy Sauce','condiment','tbsp');
  v5:=_ensure_ing('Sugar','baking','tbsp'); v6:=_ensure_ing('Cooking Oil','oil','tbsp');
  v7:=_ensure_ing('Garlic','vegetable','clove');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,200,'g'),(r_id,v2,1,'piece'),(r_id,v3,0.5,'piece'),(r_id,v4,3,'tbsp'),
    (r_id,v5,1.5,'tbsp'),(r_id,v6,2,'tbsp'),(r_id,v7,3,'clove');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Cook noodles per package, drain, cut with scissors','{"action":"boil","item":"noodles","minutes":5}'),
    (r_id,2,'Julienne carrot and onion, stir-fry separately 2 min each','{"action":"stir_fry","item":"vegetables","minutes":4}'),
    (r_id,3,'Toss noodles with soy sauce, sugar, garlic, oil','{"action":"toss","item":"noodles,sauce"}'),
    (r_id,4,'Combine everything, serve warm or cold','{"action":"mix","item":"noodles,vegetables"}');

  -- ── R79: Waffles ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Classic Waffles','Crispy golden waffles for breakfast','American',2,10,10,4,ARRAY['breakfast','baking','american'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Flour','baking','cup'); v2:=_ensure_ing('Egg','protein','piece');
  v3:=_ensure_ing('Milk','dairy','ml'); v4:=_ensure_ing('Butter','dairy','g');
  v5:=_ensure_ing('Sugar','baking','tbsp'); v6:=_ensure_ing('Baking Soda','baking','tsp');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,2,'cup'),(r_id,v2,2,'piece'),(r_id,v3,350,'ml'),(r_id,v4,60,'g'),(r_id,v5,2,'tbsp'),(r_id,v6,2,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Mix flour, sugar, baking soda, salt','{"action":"mix","item":"dry"}'),
    (r_id,2,'Whisk eggs, milk, melted butter separately','{"action":"whisk","item":"wet"}'),
    (r_id,3,'Combine, do not overmix','{"action":"fold","item":"batter"}'),
    (r_id,4,'Preheat waffle iron, cook until golden','{"action":"cook","item":"waffle","minutes":4}');

  -- ── R80: Tom Yum Soup ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Tom Yum Soup','Thai hot and sour shrimp soup','Thai',3,10,15,2,ARRAY['thai','soup','seafood','spicy'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Shrimp','seafood','g'); v2:=_ensure_ing('Mushroom','vegetable','g');
  v3:=_ensure_ing('Garlic','vegetable','clove'); v4:=_ensure_ing('Lemon','fruit','piece');
  v5:=_ensure_ing('Salt','seasoning','tsp'); v6:=_ensure_ing('Cooking Oil','oil','tbsp');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,250,'g'),(r_id,v2,100,'g'),(r_id,v3,3,'clove'),(r_id,v4,1,'piece'),(r_id,v5,1,'tsp'),(r_id,v6,1,'tbsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Bring 3 cups water to boil with garlic','{"action":"boil","item":"water,garlic"}'),
    (r_id,2,'Add mushrooms, cook 3 min','{"action":"simmer","item":"mushroom","minutes":3}'),
    (r_id,3,'Add shrimp, cook 3 min until pink','{"action":"cook","item":"shrimp","minutes":3}'),
    (r_id,4,'Squeeze lemon juice, season with salt, serve hot','{"action":"season","item":"lemon,salt"}');

  -- ── R81: Korean Tteokbokki ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Tteokbokki','Spicy Korean rice cakes in chili sauce','Korean',2,5,15,2,ARRAY['korean','spicy','snack'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Rice','grain','g'); v2:=_ensure_ing('Korean Chili Flakes','seasoning','tbsp');
  v3:=_ensure_ing('Sugar','baking','tbsp'); v4:=_ensure_ing('Soy Sauce','condiment','tbsp');
  v5:=_ensure_ing('Garlic','vegetable','clove'); v6:=_ensure_ing('Egg','protein','piece');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,300,'g'),(r_id,v2,2,'tbsp'),(r_id,v3,1,'tbsp'),(r_id,v4,1,'tbsp'),(r_id,v5,2,'clove'),(r_id,v6,2,'piece');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Soak rice cakes in warm water if dried','{"action":"soak","item":"rice_cakes","minutes":10}'),
    (r_id,2,'Boil 2 cups water with garlic, chili, soy, sugar','{"action":"boil","item":"sauce"}'),
    (r_id,3,'Add rice cakes, simmer 10 min until soft and sauce thickens','{"action":"simmer","item":"rice_cakes","minutes":10}'),
    (r_id,4,'Add hard-boiled eggs, serve','{"action":"add","item":"egg"}');

  -- ── R82: Chicken Nuggets ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Chicken Nuggets','Crispy homemade chicken nuggets','American',2,15,10,4,ARRAY['american','chicken','fried','snack'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Chicken','protein','g'); v2:=_ensure_ing('Flour','baking','cup');
  v3:=_ensure_ing('Egg','protein','piece'); v4:=_ensure_ing('Bread','grain','slice');
  v5:=_ensure_ing('Cooking Oil','oil','ml'); v6:=_ensure_ing('Salt','seasoning','tsp');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,400,'g'),(r_id,v2,0.5,'cup'),(r_id,v3,1,'piece'),(r_id,v4,4,'slice'),(r_id,v5,300,'ml'),(r_id,v6,1,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Cut chicken into bite-sized pieces','{"action":"chop","item":"chicken","size":"bite"}'),
    (r_id,2,'Make breadcrumbs from bread slices','{"action":"blend","item":"bread"}'),
    (r_id,3,'Dredge: flour, beaten egg, breadcrumbs','{"action":"bread","item":"chicken"}'),
    (r_id,4,'Fry in hot oil 4-5 min until golden','{"action":"fry","item":"nuggets","minutes":5}');

  -- ── R83: Pasta Aglio e Olio ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Pasta Aglio e Olio','Simple Italian garlic and oil pasta','Italian',1,3,12,2,ARRAY['italian','pasta','quick','vegetarian'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Pasta','grain','g'); v2:=_ensure_ing('Garlic','vegetable','clove');
  v3:=_ensure_ing('Cooking Oil','oil','tbsp'); v4:=_ensure_ing('Salt','seasoning','tsp');
  v5:=_ensure_ing('Black Pepper','seasoning','tsp');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,250,'g'),(r_id,v2,6,'clove'),(r_id,v3,4,'tbsp'),(r_id,v4,1,'tsp'),(r_id,v5,0.5,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Cook pasta in salty water until al dente, save 1 cup water','{"action":"boil","item":"pasta","minutes":10}'),
    (r_id,2,'Thinly slice garlic, cook slowly in oil until just golden','{"action":"saute","item":"garlic","minutes":3}'),
    (r_id,3,'Add pasta and splash of pasta water, toss vigorously','{"action":"toss","item":"pasta,garlic_oil","minutes":1}');

  -- ── R84: Chicken Katsu Curry ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Chicken Katsu Curry','Japanese crispy chicken with curry sauce','Japanese',3,15,20,2,ARRAY['japanese','chicken','curry','fried'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Chicken','protein','g'); v2:=_ensure_ing('Flour','baking','cup');
  v3:=_ensure_ing('Egg','protein','piece'); v4:=_ensure_ing('Bread','grain','slice');
  v5:=_ensure_ing('Cooking Oil','oil','ml'); v6:=_ensure_ing('Onion','vegetable','piece');
  v7:=_ensure_ing('Carrot','vegetable','piece'); v8:=_ensure_ing('Rice','grain','cup');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,300,'g'),(r_id,v2,0.5,'cup'),(r_id,v3,1,'piece'),(r_id,v4,3,'slice'),
    (r_id,v5,300,'ml'),(r_id,v6,1,'piece'),(r_id,v7,1,'piece'),(r_id,v8,2,'cup');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Cook rice','{"action":"cook","item":"rice","minutes":20}'),
    (r_id,2,'Make curry sauce: sauté onion+carrot, add flour+water, simmer','{"action":"simmer","item":"curry_sauce","minutes":10}'),
    (r_id,3,'Bread chicken: flour, egg, breadcrumbs','{"action":"bread","item":"chicken"}'),
    (r_id,4,'Deep fry chicken 5 min until golden','{"action":"fry","item":"chicken","minutes":5}'),
    (r_id,5,'Slice katsu, serve over rice with curry sauce','{"action":"plate","items":"rice,katsu,curry"}');

  -- ── R85: Bruschetta ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Bruschetta','Italian toasted bread with tomato topping','Italian',1,10,3,4,ARRAY['italian','appetizer','quick','vegetarian'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Bread','grain','slice'); v2:=_ensure_ing('Tomato Paste','condiment','tbsp');
  v3:=_ensure_ing('Garlic','vegetable','clove'); v4:=_ensure_ing('Cooking Oil','oil','tbsp');
  v5:=_ensure_ing('Salt','seasoning','tsp');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,8,'slice'),(r_id,v2,4,'tbsp'),(r_id,v3,2,'clove'),(r_id,v4,3,'tbsp'),(r_id,v5,0.5,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Toast bread slices until golden','{"action":"toast","item":"bread","minutes":2}'),
    (r_id,2,'Rub toast with cut garlic','{"action":"rub","item":"garlic,bread"}'),
    (r_id,3,'Top with tomato paste mixed with oil and salt','{"action":"top","item":"tomato,oil,salt"}');

  -- ── R86: Egg Fried Noodles ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Egg Fried Noodles','Quick Chinese-style stir-fried noodles','Chinese',1,5,8,2,ARRAY['chinese','noodles','quick','egg'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Ramen Noodles','grain','g'); v2:=_ensure_ing('Egg','protein','piece');
  v3:=_ensure_ing('Soy Sauce','condiment','tbsp'); v4:=_ensure_ing('Cooking Oil','oil','tbsp');
  v5:=_ensure_ing('Onion','vegetable','piece'); v6:=_ensure_ing('Carrot','vegetable','piece');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,200,'g'),(r_id,v2,2,'piece'),(r_id,v3,2,'tbsp'),(r_id,v4,2,'tbsp'),(r_id,v5,0.5,'piece'),(r_id,v6,1,'piece');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Cook noodles, drain','{"action":"boil","item":"noodles","minutes":3}'),
    (r_id,2,'Stir-fry diced vegetables in oil 2 min','{"action":"stir_fry","item":"vegetables","minutes":2}'),
    (r_id,3,'Push aside, scramble eggs','{"action":"cook","item":"egg","style":"scramble"}'),
    (r_id,4,'Add noodles and soy sauce, toss 2 min','{"action":"toss","item":"noodles,sauce","minutes":2}');

  -- ── R87: Potato Wedges ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Crispy Potato Wedges','Oven-baked seasoned potato wedges','American',1,5,30,3,ARRAY['american','potato','side','baking'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Potato','vegetable','piece'); v2:=_ensure_ing('Cooking Oil','oil','tbsp');
  v3:=_ensure_ing('Salt','seasoning','tsp'); v4:=_ensure_ing('Black Pepper','seasoning','tsp');
  v5:=_ensure_ing('Garlic','vegetable','clove');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,4,'piece'),(r_id,v2,3,'tbsp'),(r_id,v3,1,'tsp'),(r_id,v4,0.5,'tsp'),(r_id,v5,2,'clove');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Preheat oven to 220°C, cut potatoes into wedges','{"action":"preheat","temp_c":220}'),
    (r_id,2,'Toss with oil, minced garlic, salt, pepper','{"action":"toss","item":"wedges,oil,seasoning"}'),
    (r_id,3,'Spread on baking sheet, bake 25-30 min, flip halfway','{"action":"bake","minutes":28}');

  -- ── R88: Korean Egg Roll ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Gyeran-mari (Korean Egg Roll)','Korean rolled omelette with vegetables','Korean',2,5,8,2,ARRAY['korean','egg','side','quick'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Egg','protein','piece'); v2:=_ensure_ing('Carrot','vegetable','piece');
  v3:=_ensure_ing('Onion','vegetable','piece'); v4:=_ensure_ing('Salt','seasoning','tsp');
  v5:=_ensure_ing('Cooking Oil','oil','tbsp');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,4,'piece'),(r_id,v2,0.5,'piece'),(r_id,v3,0.25,'piece'),(r_id,v4,0.25,'tsp'),(r_id,v5,1,'tbsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Beat eggs with salt, mix in finely diced carrot and onion','{"action":"whisk","item":"egg,carrot,onion,salt"}'),
    (r_id,2,'Pour thin layer in oiled pan, cook until nearly set','{"action":"cook","item":"egg_layer","minutes":1}'),
    (r_id,3,'Roll up, push to one side, pour another layer, repeat','{"action":"roll","item":"egg_roll"}'),
    (r_id,4,'Slice into rounds and serve','{"action":"slice","item":"egg_roll"}');

  -- ── R89: Chicken Wrap ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Grilled Chicken Wrap','Healthy chicken wrap with vegetables','American',1,10,8,2,ARRAY['american','chicken','quick','healthy'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Chicken','protein','g'); v2:=_ensure_ing('Flour','baking','cup');
  v3:=_ensure_ing('Lettuce','vegetable','piece'); v4:=_ensure_ing('Carrot','vegetable','piece');
  v5:=_ensure_ing('Cooking Oil','oil','tbsp'); v6:=_ensure_ing('Salt','seasoning','tsp');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,250,'g'),(r_id,v2,1,'cup'),(r_id,v3,0.5,'piece'),(r_id,v4,1,'piece'),(r_id,v5,1,'tbsp'),(r_id,v6,0.5,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Season and grill chicken until done, slice','{"action":"grill","item":"chicken","minutes":8}'),
    (r_id,2,'Shred lettuce, grate carrot','{"action":"prep","item":"lettuce,carrot"}'),
    (r_id,3,'Warm tortilla, fill with chicken and veggies, roll tight','{"action":"assemble","item":"wrap"}');

  -- ── R90: French Onion Soup ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'French Onion Soup','Rich caramelized onion soup','French',3,10,45,4,ARRAY['french','soup','onion'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Onion','vegetable','piece'); v2:=_ensure_ing('Butter','dairy','g');
  v3:=_ensure_ing('Bread','grain','slice'); v4:=_ensure_ing('Cheese','dairy','g');
  v5:=_ensure_ing('Salt','seasoning','tsp'); v6:=_ensure_ing('Black Pepper','seasoning','tsp');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,5,'piece'),(r_id,v2,40,'g'),(r_id,v3,4,'slice'),(r_id,v4,100,'g'),(r_id,v5,1,'tsp'),(r_id,v6,0.5,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Thinly slice all onions','{"action":"slice","item":"onion","size":"thin"}'),
    (r_id,2,'Cook in butter over low heat 30 min until deeply caramelized','{"action":"caramelize","item":"onion","minutes":30}'),
    (r_id,3,'Add 4 cups water, salt, pepper, simmer 10 min','{"action":"simmer","item":"soup","minutes":10}'),
    (r_id,4,'Ladle into bowls, top with bread and cheese, broil 3 min','{"action":"broil","item":"soup,bread,cheese","minutes":3}');

  -- ── R91: Beef Bulgogi ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Beef Bulgogi','Korean marinated grilled beef','Korean',2,20,8,3,ARRAY['korean','beef','grilled'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Beef','protein','g'); v2:=_ensure_ing('Soy Sauce','condiment','tbsp');
  v3:=_ensure_ing('Sugar','baking','tbsp'); v4:=_ensure_ing('Garlic','vegetable','clove');
  v5:=_ensure_ing('Onion','vegetable','piece'); v6:=_ensure_ing('Cooking Oil','oil','tbsp');
  v7:=_ensure_ing('Black Pepper','seasoning','tsp'); v8:=_ensure_ing('Rice','grain','cup');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,400,'g'),(r_id,v2,4,'tbsp'),(r_id,v3,2,'tbsp'),(r_id,v4,4,'clove'),
    (r_id,v5,0.5,'piece'),(r_id,v6,1,'tbsp'),(r_id,v7,0.5,'tsp'),(r_id,v8,2,'cup');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Thinly slice beef against the grain','{"action":"slice","item":"beef","size":"thin"}'),
    (r_id,2,'Mix marinade: soy sauce, sugar, minced garlic, grated onion, pepper','{"action":"mix","item":"marinade"}'),
    (r_id,3,'Marinate beef 15 min','{"action":"marinate","item":"beef","minutes":15}'),
    (r_id,4,'Grill or pan-fry on high heat 2-3 min per side','{"action":"grill","item":"beef","minutes":5}'),
    (r_id,5,'Serve with rice','{"action":"plate","items":"beef,rice"}');

  -- ── R92: Stuffed Bell Peppers ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Stuffed Bell Peppers','Peppers filled with rice and beef, baked','American',3,15,35,4,ARRAY['american','beef','baking'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Bell Pepper','vegetable','piece'); v2:=_ensure_ing('Beef','protein','g');
  v3:=_ensure_ing('Rice','grain','cup'); v4:=_ensure_ing('Tomato Paste','condiment','tbsp');
  v5:=_ensure_ing('Onion','vegetable','piece'); v6:=_ensure_ing('Salt','seasoning','tsp');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,4,'piece'),(r_id,v2,300,'g'),(r_id,v3,1,'cup'),(r_id,v4,2,'tbsp'),(r_id,v5,1,'piece'),(r_id,v6,1,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Cut tops off peppers, remove seeds','{"action":"prep","item":"peppers"}'),
    (r_id,2,'Cook rice, brown beef with diced onion','{"action":"cook","item":"rice,beef,onion","minutes":10}'),
    (r_id,3,'Mix rice, beef, tomato paste, salt for filling','{"action":"mix","item":"filling"}'),
    (r_id,4,'Stuff peppers, place in baking dish','{"action":"stuff","item":"peppers"}'),
    (r_id,5,'Bake at 190°C for 30 min','{"action":"bake","temp_c":190,"minutes":30}');

  -- ── R93: Egg Sandwich ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Egg Sandwich','Quick breakfast sandwich','American',1,2,5,1,ARRAY['american','breakfast','egg','quick'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Egg','protein','piece'); v2:=_ensure_ing('Bread','grain','slice');
  v3:=_ensure_ing('Butter','dairy','g'); v4:=_ensure_ing('Salt','seasoning','tsp');
  v5:=_ensure_ing('Black Pepper','seasoning','tsp');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,2,'piece'),(r_id,v2,2,'slice'),(r_id,v3,10,'g'),(r_id,v4,0.1,'tsp'),(r_id,v5,0.1,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Fry eggs in butter, season','{"action":"fry","item":"egg","minutes":3}'),
    (r_id,2,'Toast bread','{"action":"toast","item":"bread","minutes":2}'),
    (r_id,3,'Assemble sandwich','{"action":"assemble","item":"sandwich"}');

  -- ── R94: Lemon Garlic Shrimp ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Lemon Garlic Shrimp','Quick pan-seared shrimp in lemon butter','Mediterranean',1,5,7,2,ARRAY['seafood','quick','mediterranean'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Shrimp','seafood','g'); v2:=_ensure_ing('Garlic','vegetable','clove');
  v3:=_ensure_ing('Butter','dairy','g'); v4:=_ensure_ing('Lemon','fruit','piece');
  v5:=_ensure_ing('Salt','seasoning','tsp');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,300,'g'),(r_id,v2,4,'clove'),(r_id,v3,30,'g'),(r_id,v4,1,'piece'),(r_id,v5,0.5,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Sauté garlic in butter 30 sec','{"action":"saute","item":"garlic"}'),
    (r_id,2,'Add shrimp, cook 2 min per side','{"action":"cook","item":"shrimp","minutes":4}'),
    (r_id,3,'Squeeze lemon, toss, serve','{"action":"season","item":"lemon"}');

  -- ── R95: Baked Beans ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Baked Beans','Sweet and smoky baked beans','British',2,5,30,4,ARRAY['british','beans','side','baking'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Beans','legume','cup'); v2:=_ensure_ing('Tomato Paste','condiment','tbsp');
  v3:=_ensure_ing('Sugar','baking','tbsp'); v4:=_ensure_ing('Onion','vegetable','piece');
  v5:=_ensure_ing('Salt','seasoning','tsp');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,2,'cup'),(r_id,v2,3,'tbsp'),(r_id,v3,2,'tbsp'),(r_id,v4,1,'piece'),(r_id,v5,0.5,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Sauté diced onion until soft','{"action":"saute","item":"onion","minutes":3}'),
    (r_id,2,'Add beans, tomato paste, sugar, 1 cup water','{"action":"add","item":"beans,sauce,water"}'),
    (r_id,3,'Simmer 25 min until thick and glossy','{"action":"simmer","minutes":25}');

  -- ── R96: Avocado Toast ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Avocado Toast','Trendy smashed avocado on toast','American',1,3,2,1,ARRAY['american','breakfast','quick','healthy','vegetarian'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Avocado','fruit','piece'); v2:=_ensure_ing('Bread','grain','slice');
  v3:=_ensure_ing('Egg','protein','piece'); v4:=_ensure_ing('Salt','seasoning','tsp');
  v5:=_ensure_ing('Lemon','fruit','piece');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,1,'piece'),(r_id,v2,2,'slice'),(r_id,v3,1,'piece'),(r_id,v4,0.25,'tsp'),(r_id,v5,0.25,'piece');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Toast bread','{"action":"toast","item":"bread","minutes":2}'),
    (r_id,2,'Mash avocado with salt and lemon juice','{"action":"mash","item":"avocado,salt,lemon"}'),
    (r_id,3,'Spread on toast, top with fried egg','{"action":"plate","items":"toast,avocado,egg"}');

  -- ── R97: Fried Chicken ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Southern Fried Chicken','Crispy, juicy fried chicken','American',3,15,15,4,ARRAY['american','chicken','fried'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Chicken','protein','g'); v2:=_ensure_ing('Flour','baking','cup');
  v3:=_ensure_ing('Egg','protein','piece'); v4:=_ensure_ing('Milk','dairy','ml');
  v5:=_ensure_ing('Cooking Oil','oil','ml'); v6:=_ensure_ing('Salt','seasoning','tsp');
  v7:=_ensure_ing('Black Pepper','seasoning','tsp');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,800,'g'),(r_id,v2,1.5,'cup'),(r_id,v3,1,'piece'),(r_id,v4,200,'ml'),
    (r_id,v5,500,'ml'),(r_id,v6,2,'tsp'),(r_id,v7,1,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Mix flour with salt and pepper','{"action":"mix","item":"seasoned_flour"}'),
    (r_id,2,'Whisk egg and milk for egg wash','{"action":"whisk","item":"egg,milk"}'),
    (r_id,3,'Dip chicken: flour, egg wash, flour again','{"action":"bread","item":"chicken"}'),
    (r_id,4,'Fry in 180°C oil 12-15 min until golden','{"action":"fry","item":"chicken","minutes":13}');

  -- ── R98: Corn on the Cob ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Butter Corn on the Cob','Boiled corn with butter and salt','American',1,2,10,4,ARRAY['american','side','vegetarian','quick'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Corn','vegetable','piece'); v2:=_ensure_ing('Butter','dairy','g');
  v3:=_ensure_ing('Salt','seasoning','tsp');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,4,'piece'),(r_id,v2,40,'g'),(r_id,v3,1,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Boil water with a pinch of sugar','{"action":"boil","item":"water"}'),
    (r_id,2,'Add corn, cook 8-10 min until tender','{"action":"boil","item":"corn","minutes":9}'),
    (r_id,3,'Drain, slather with butter, sprinkle salt','{"action":"garnish","item":"butter,salt"}');

  -- ── R99: Chocolate Chip Cookies ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Chocolate Chip Cookies','Classic chewy chocolate chip cookies','American',2,15,12,24,ARRAY['american','baking','dessert'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Flour','baking','cup'); v2:=_ensure_ing('Butter','dairy','g');
  v3:=_ensure_ing('Sugar','baking','cup'); v4:=_ensure_ing('Egg','protein','piece');
  v5:=_ensure_ing('Baking Soda','baking','tsp'); v6:=_ensure_ing('Salt','seasoning','tsp');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,2.25,'cup'),(r_id,v2,115,'g'),(r_id,v3,0.75,'cup'),(r_id,v4,1,'piece'),(r_id,v5,1,'tsp'),(r_id,v6,0.5,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Preheat oven to 190°C','{"action":"preheat","temp_c":190}'),
    (r_id,2,'Cream butter and sugar until fluffy','{"action":"cream","item":"butter,sugar"}'),
    (r_id,3,'Beat in egg, then mix in flour, baking soda, salt','{"action":"mix","item":"dough"}'),
    (r_id,4,'Drop spoonfuls onto baking sheet','{"action":"shape","item":"cookies","count":24}'),
    (r_id,5,'Bake 10-12 min until edges are golden','{"action":"bake","minutes":11}');

  -- ── R100: Korean Doenjang Jjigae ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Doenjang Jjigae','Korean fermented soybean paste stew','Korean',2,10,20,3,ARRAY['korean','soup','stew','comfort'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Tofu','protein','g'); v2:=_ensure_ing('Potato','vegetable','piece');
  v3:=_ensure_ing('Onion','vegetable','piece'); v4:=_ensure_ing('Garlic','vegetable','clove');
  v5:=_ensure_ing('Soy Sauce','condiment','tbsp'); v6:=_ensure_ing('Korean Chili Flakes','seasoning','tsp');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,200,'g'),(r_id,v2,1,'piece'),(r_id,v3,0.5,'piece'),(r_id,v4,3,'clove'),
    (r_id,v5,1,'tbsp'),(r_id,v6,1,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Cube potato and tofu, dice onion','{"action":"chop","item":"potato,tofu,onion"}'),
    (r_id,2,'Bring 3 cups water to boil, add potato, cook 8 min','{"action":"boil","item":"potato","minutes":8}'),
    (r_id,3,'Add soy sauce, garlic, chili flakes, stir','{"action":"season","item":"soy,garlic,chili"}'),
    (r_id,4,'Add tofu, simmer 5 more min','{"action":"simmer","item":"tofu","minutes":5}'),
    (r_id,5,'Serve bubbling hot with rice','{"action":"plate","items":"stew,rice"}');

END $$;

-- Cleanup helper
DROP FUNCTION IF EXISTS _ensure_ing(TEXT,TEXT,TEXT);
