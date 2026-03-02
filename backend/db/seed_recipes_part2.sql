-- ============================================================
-- I-Fridge — Seed: Recipes (Part 2 of 2) — Recipes 26-50
-- ============================================================
-- Run seed_ingredients.sql and seed_recipes_part1.sql FIRST.
-- ============================================================

DO $$
DECLARE
  r_id UUID;
  v_potato UUID;      v_carrot UUID;     v_onion UUID;
  v_garlic UUID;      v_tomato_paste UUID; v_egg UUID;
  v_chicken UUID;     v_beef UUID;       v_rice UUID;
  v_bread UUID;       v_pasta UUID;      v_flour UUID;
  v_sugar UUID;       v_baking_soda UUID; v_milk UUID;
  v_butter UUID;      v_coffee UUID;     v_oil UUID;
  v_salt UUID;        v_pepper UUID;     v_soy UUID;
  v_beans UUID;       v_peas UUID;       v_lentils UUID;
BEGIN
  SELECT id INTO v_potato FROM ingredients WHERE canonical_name='potato';
  SELECT id INTO v_carrot FROM ingredients WHERE canonical_name='carrot';
  SELECT id INTO v_onion FROM ingredients WHERE canonical_name='onion';
  SELECT id INTO v_garlic FROM ingredients WHERE canonical_name='garlic';
  SELECT id INTO v_tomato_paste FROM ingredients WHERE canonical_name='tomato_paste';
  SELECT id INTO v_egg FROM ingredients WHERE canonical_name='egg';
  SELECT id INTO v_chicken FROM ingredients WHERE canonical_name='chicken';
  SELECT id INTO v_beef FROM ingredients WHERE canonical_name='beef';
  SELECT id INTO v_rice FROM ingredients WHERE canonical_name='rice';
  SELECT id INTO v_bread FROM ingredients WHERE canonical_name='bread';
  SELECT id INTO v_pasta FROM ingredients WHERE canonical_name='pasta';
  SELECT id INTO v_flour FROM ingredients WHERE canonical_name='flour';
  SELECT id INTO v_sugar FROM ingredients WHERE canonical_name='sugar';
  SELECT id INTO v_baking_soda FROM ingredients WHERE canonical_name='baking_soda';
  SELECT id INTO v_milk FROM ingredients WHERE canonical_name='milk';
  SELECT id INTO v_butter FROM ingredients WHERE canonical_name='butter';
  SELECT id INTO v_coffee FROM ingredients WHERE canonical_name='coffee';
  SELECT id INTO v_oil FROM ingredients WHERE canonical_name='cooking_oil';
  SELECT id INTO v_salt FROM ingredients WHERE canonical_name='salt';
  SELECT id INTO v_pepper FROM ingredients WHERE canonical_name='black_pepper';
  SELECT id INTO v_soy FROM ingredients WHERE canonical_name='soy_sauce';
  SELECT id INTO v_beans FROM ingredients WHERE canonical_name='beans';
  SELECT id INTO v_peas FROM ingredients WHERE canonical_name='peas';
  SELECT id INTO v_lentils FROM ingredients WHERE canonical_name='lentils';

  -- ── R26: Chicken Soup ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Chicken Noodle Soup','Classic comforting chicken soup with pasta','Western',2,10,30,4,ARRAY['soup','chicken','comfort'])
  RETURNING id INTO r_id;
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v_chicken,300,'g'),(r_id,v_pasta,100,'g'),(r_id,v_carrot,2,'piece'),
    (r_id,v_onion,1,'piece'),(r_id,v_garlic,2,'clove'),(r_id,v_salt,1,'tsp'),(r_id,v_pepper,0.25,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Simmer chicken in 6 cups water for 15 min','{"action":"simmer","item":"chicken","minutes":15}'),
    (r_id,2,'Remove chicken, shred meat, keep broth','{"action":"shred","item":"chicken"}'),
    (r_id,3,'Add diced carrot, onion, garlic to broth','{"action":"add","item":"vegetables"}'),
    (r_id,4,'Simmer 10 min, add pasta, cook 8 more min','{"action":"simmer","minutes":18}'),
    (r_id,5,'Return shredded chicken, season','{"action":"add","item":"chicken,seasoning"}');

  -- ── R27: Sautéed Carrots ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Honey Butter Carrots','Sweet glazed carrots as a side dish','Western',1,5,10,3,ARRAY['side','carrot','quick'])
  RETURNING id INTO r_id;
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v_carrot,4,'piece'),(r_id,v_butter,30,'g'),(r_id,v_sugar,1,'tbsp'),(r_id,v_salt,0.25,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Peel and slice carrots into rounds','{"action":"slice","item":"carrot"}'),
    (r_id,2,'Melt butter in pan, add carrots','{"action":"saute","item":"carrot,butter","minutes":5}'),
    (r_id,3,'Add sugar and salt, cook until glazed','{"action":"glaze","item":"carrot","minutes":3}');

  -- ── R28: Rice Porridge ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Rice Porridge','Soft, comforting rice porridge','Asian',1,2,25,2,ARRAY['rice','comfort','breakfast'])
  RETURNING id INTO r_id;
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v_rice,0.5,'cup'),(r_id,v_egg,1,'piece'),(r_id,v_soy,1,'tbsp'),
    (r_id,v_salt,0.5,'tsp'),(r_id,v_oil,1,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Rinse rice, add to 4 cups water','{"action":"add","item":"rice,water"}'),
    (r_id,2,'Bring to boil then simmer 20 min, stirring often','{"action":"simmer","minutes":20}'),
    (r_id,3,'Stir in beaten egg, drizzle oil, add soy sauce','{"action":"stir","item":"egg,oil,soy"}');

  -- ── R29: Baked Potato ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Loaded Baked Potato','Crispy baked potato with butter topping','Western',1,5,45,2,ARRAY['potato','side'])
  RETURNING id INTO r_id;
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v_potato,2,'piece'),(r_id,v_butter,30,'g'),(r_id,v_oil,1,'tbsp'),
    (r_id,v_salt,0.5,'tsp'),(r_id,v_pepper,0.25,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Preheat oven to 200°C, scrub potatoes','{"action":"preheat","tool":"oven","temp_c":200}'),
    (r_id,2,'Rub with oil and salt, prick with fork','{"action":"prep","item":"potato"}'),
    (r_id,3,'Bake 40-45 min until crispy outside, fluffy inside','{"action":"bake","minutes":43}'),
    (r_id,4,'Split open, add butter, salt, pepper','{"action":"garnish","item":"butter,salt,pepper"}');

  -- ── R30: Chicken Pasta ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Creamy Chicken Pasta','Pasta in a creamy garlic chicken sauce','Italian',2,10,20,3,ARRAY['pasta','chicken'])
  RETURNING id INTO r_id;
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v_pasta,300,'g'),(r_id,v_chicken,300,'g'),(r_id,v_garlic,4,'clove'),
    (r_id,v_butter,30,'g'),(r_id,v_milk,200,'ml'),(r_id,v_flour,1,'tbsp'),
    (r_id,v_salt,1,'tsp'),(r_id,v_pepper,0.25,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Cook pasta, drain, reserve 1/2 cup pasta water','{"action":"boil","item":"pasta","minutes":10}'),
    (r_id,2,'Season and pan-fry chicken until done, slice','{"action":"fry","item":"chicken","minutes":8}'),
    (r_id,3,'Melt butter, sauté garlic 1 min','{"action":"saute","item":"garlic","minutes":1}'),
    (r_id,4,'Whisk in flour, then slowly add milk for sauce','{"action":"whisk","item":"flour,milk"}'),
    (r_id,5,'Toss pasta, chicken in sauce, season','{"action":"toss","item":"pasta,chicken,sauce"}');

  -- ── R31: Egg Curry ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Egg Curry','Hard-boiled eggs in a spiced tomato sauce','Indian',2,5,20,2,ARRAY['egg','indian','curry'])
  RETURNING id INTO r_id;
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v_egg,4,'piece'),(r_id,v_onion,1,'piece'),(r_id,v_garlic,3,'clove'),
    (r_id,v_tomato_paste,2,'tbsp'),(r_id,v_oil,2,'tbsp'),(r_id,v_salt,0.5,'tsp'),(r_id,v_pepper,0.5,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Hard-boil eggs 10 min, peel','{"action":"boil","item":"egg","minutes":10}'),
    (r_id,2,'Sauté diced onion and garlic in oil','{"action":"saute","item":"onion,garlic","minutes":3}'),
    (r_id,3,'Add tomato paste, 1 cup water, spices, simmer','{"action":"simmer","item":"sauce","minutes":10}'),
    (r_id,4,'Add halved eggs to sauce, cook 5 min','{"action":"cook","item":"eggs_in_sauce","minutes":5}');

  -- ── R32: Fried Potatoes ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Crispy Fried Potatoes','Golden pan-fried potato cubes','Western',1,10,15,3,ARRAY['potato','side','quick'])
  RETURNING id INTO r_id;
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v_potato,4,'piece'),(r_id,v_oil,3,'tbsp'),(r_id,v_salt,1,'tsp'),
    (r_id,v_pepper,0.25,'tsp'),(r_id,v_garlic,2,'clove');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Peel and dice potatoes into 1cm cubes','{"action":"chop","item":"potato","size":"1cm"}'),
    (r_id,2,'Heat oil in a large pan over medium-high heat','{"action":"heat","tool":"pan","temp":"medium-high"}'),
    (r_id,3,'Fry potatoes 12-15 min, turning occasionally','{"action":"fry","item":"potato","minutes":13}'),
    (r_id,4,'Add minced garlic last 2 min, season','{"action":"season","item":"garlic,salt,pepper"}');

  -- ── R33: Bean Salad ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Bean and Onion Salad','Fresh cold bean salad with tangy dressing','Mediterranean',1,10,0,3,ARRAY['beans','salad','quick','no-cook'])
  RETURNING id INTO r_id;
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v_beans,1.5,'cup'),(r_id,v_onion,0.5,'piece'),(r_id,v_oil,2,'tbsp'),
    (r_id,v_salt,0.5,'tsp'),(r_id,v_pepper,0.25,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Drain and rinse canned beans','{"action":"wash","item":"beans"}'),
    (r_id,2,'Finely dice onion','{"action":"chop","item":"onion","size":"fine"}'),
    (r_id,3,'Toss beans and onion with oil, salt, pepper','{"action":"toss","item":"beans,onion,dressing"}');

  -- ── R34: Milk Bread Rolls ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Milk Bread Rolls','Soft fluffy milk bread rolls','Asian',3,20,20,8,ARRAY['baking','bread'])
  RETURNING id INTO r_id;
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v_flour,3,'cup'),(r_id,v_milk,200,'ml'),(r_id,v_egg,1,'piece'),
    (r_id,v_sugar,3,'tbsp'),(r_id,v_butter,40,'g'),(r_id,v_salt,0.5,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Warm milk to 40°C, dissolve sugar in it','{"action":"warm","item":"milk","temp_c":40}'),
    (r_id,2,'Mix flour, salt, egg, and warm milk into dough','{"action":"knead","item":"dough","minutes":10}'),
    (r_id,3,'Add softened butter, knead 5 more minutes','{"action":"knead","item":"dough,butter","minutes":5}'),
    (r_id,4,'Let rise 1 hour until doubled','{"action":"proof","minutes":60}'),
    (r_id,5,'Divide into 8 rolls, place on baking sheet','{"action":"shape","item":"rolls","count":8}'),
    (r_id,6,'Preheat 180°C, bake 18-20 min until golden','{"action":"bake","temp_c":180,"minutes":19}');

  -- ── R35: Chicken Fried Rice ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Chicken Fried Rice','Classic chicken fried rice with egg','Asian',2,10,10,2,ARRAY['chicken','rice','quick'])
  RETURNING id INTO r_id;
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v_chicken,200,'g'),(r_id,v_rice,2,'cup'),(r_id,v_egg,2,'piece'),
    (r_id,v_onion,0.5,'piece'),(r_id,v_carrot,1,'piece'),(r_id,v_soy,2,'tbsp'),
    (r_id,v_oil,2,'tbsp'),(r_id,v_salt,0.25,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Dice chicken, carrot, onion','{"action":"chop","item":"chicken,carrot,onion"}'),
    (r_id,2,'Stir-fry chicken in oil 4 min','{"action":"stir_fry","item":"chicken","minutes":4}'),
    (r_id,3,'Push aside, scramble eggs','{"action":"cook","item":"egg","style":"scramble"}'),
    (r_id,4,'Add vegetables, cook 2 min','{"action":"stir_fry","item":"vegetables","minutes":2}'),
    (r_id,5,'Add rice and soy sauce, toss 3 min','{"action":"toss","item":"rice,soy","minutes":3}');

  -- ── R36: Potato and Carrot Gratin ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Potato Carrot Gratin','Layered potato and carrot bake with creamy sauce','French',3,15,40,4,ARRAY['baking','potato','carrot'])
  RETURNING id INTO r_id;
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v_potato,4,'piece'),(r_id,v_carrot,3,'piece'),(r_id,v_milk,200,'ml'),
    (r_id,v_butter,30,'g'),(r_id,v_flour,1,'tbsp'),(r_id,v_salt,1,'tsp'),(r_id,v_pepper,0.25,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Preheat oven to 180°C, slice potatoes and carrots thin','{"action":"preheat","temp_c":180}'),
    (r_id,2,'Make white sauce: melt butter, whisk flour, add milk','{"action":"whisk","item":"butter,flour,milk"}'),
    (r_id,3,'Layer potato, carrot in baking dish, pour sauce over','{"action":"layer","item":"potato,carrot,sauce"}'),
    (r_id,4,'Bake 35-40 min until golden and bubbly','{"action":"bake","minutes":38}');

  -- ── R37: Soy Butter Rice ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Soy Butter Rice','Korean-inspired umami rice bowl','Korean',1,2,5,1,ARRAY['rice','quick','korean'])
  RETURNING id INTO r_id;
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v_rice,1.5,'cup'),(r_id,v_butter,20,'g'),(r_id,v_soy,1.5,'tbsp'),
    (r_id,v_egg,1,'piece'),(r_id,v_oil,1,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Cook rice or use leftover rice','{"action":"cook","item":"rice"}'),
    (r_id,2,'Fry egg sunny-side up in oil','{"action":"fry","item":"egg","style":"sunny_side_up"}'),
    (r_id,3,'Mix hot rice with butter and soy sauce','{"action":"mix","item":"rice,butter,soy"}'),
    (r_id,4,'Top with fried egg','{"action":"plate","items":"rice,egg"}');

  -- ── R38: Minestrone Soup ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Minestrone Soup','Italian vegetable soup with pasta and beans','Italian',2,10,30,4,ARRAY['soup','italian','beans','pasta'])
  RETURNING id INTO r_id;
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v_pasta,80,'g'),(r_id,v_beans,1,'cup'),(r_id,v_carrot,2,'piece'),
    (r_id,v_potato,1,'piece'),(r_id,v_onion,1,'piece'),(r_id,v_garlic,2,'clove'),
    (r_id,v_tomato_paste,2,'tbsp'),(r_id,v_oil,2,'tbsp'),(r_id,v_salt,1,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Dice all vegetables into small cubes','{"action":"chop","item":"carrot,potato,onion","size":"small"}'),
    (r_id,2,'Sauté onion, garlic in oil 3 min','{"action":"saute","item":"onion,garlic","minutes":3}'),
    (r_id,3,'Add carrot, potato, tomato paste, stir 2 min','{"action":"stir","item":"vegetables,tomato_paste","minutes":2}'),
    (r_id,4,'Add 5 cups water, beans, bring to boil','{"action":"boil","item":"water,beans"}'),
    (r_id,5,'Simmer 15 min, add pasta, cook 10 more min','{"action":"simmer","minutes":25}');

  -- ── R39: Bread Pudding ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Bread Pudding','Classic bread pudding with vanilla custard','Western',2,10,35,6,ARRAY['dessert','baking','bread'])
  RETURNING id INTO r_id;
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v_bread,6,'slice'),(r_id,v_egg,3,'piece'),(r_id,v_milk,400,'ml'),
    (r_id,v_sugar,0.5,'cup'),(r_id,v_butter,30,'g'),(r_id,v_salt,0.1,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Preheat oven to 170°C, butter a baking dish','{"action":"preheat","temp_c":170}'),
    (r_id,2,'Cube bread, place in dish','{"action":"chop","item":"bread","size":"cube"}'),
    (r_id,3,'Whisk eggs, milk, sugar, salt for custard','{"action":"whisk","item":"egg,milk,sugar,salt"}'),
    (r_id,4,'Pour custard over bread, let soak 10 min','{"action":"soak","minutes":10}'),
    (r_id,5,'Dot with butter, bake 30-35 min until set','{"action":"bake","minutes":33}');

  -- ── R40: Lentil and Rice Pilaf ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Lentil Rice Pilaf','Mujaddara — lentils and rice with crispy onions','Middle Eastern',2,10,30,4,ARRAY['lentils','rice','healthy'])
  RETURNING id INTO r_id;
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v_lentils,1,'cup'),(r_id,v_rice,1,'cup'),(r_id,v_onion,2,'piece'),
    (r_id,v_oil,4,'tbsp'),(r_id,v_salt,1,'tsp'),(r_id,v_pepper,0.5,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Cook lentils in 3 cups water for 15 min','{"action":"boil","item":"lentils","minutes":15}'),
    (r_id,2,'Slice onions thinly, fry half in oil until crispy','{"action":"fry","item":"onion","minutes":8}'),
    (r_id,3,'Add rice and remaining onion to lentils, cook 15 min','{"action":"simmer","item":"rice,lentils","minutes":15}'),
    (r_id,4,'Top with crispy onions, season','{"action":"garnish","item":"fried_onion"}');

  -- ── R41: Beef and Onion Stir-Fry ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Beef Onion Stir-Fry','Quick beef and onion wok dish','Asian',2,5,8,2,ARRAY['beef','quick'])
  RETURNING id INTO r_id;
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v_beef,300,'g'),(r_id,v_onion,2,'piece'),(r_id,v_soy,2,'tbsp'),
    (r_id,v_garlic,2,'clove'),(r_id,v_oil,2,'tbsp'),(r_id,v_pepper,0.25,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Thinly slice beef and onions','{"action":"slice","item":"beef,onion","size":"thin"}'),
    (r_id,2,'Stir-fry beef in oil over high heat 3 min','{"action":"stir_fry","item":"beef","minutes":3}'),
    (r_id,3,'Add onions, garlic, cook 3 min','{"action":"stir_fry","item":"onion,garlic","minutes":3}'),
    (r_id,4,'Add soy sauce, toss 1 min','{"action":"toss","item":"soy_sauce","minutes":1}');

  -- ── R42: Pea and Potato Curry ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Pea and Potato Curry','Aloo Matar — spiced potatoes and peas','Indian',2,10,20,3,ARRAY['curry','potato','peas','indian'])
  RETURNING id INTO r_id;
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v_potato,3,'piece'),(r_id,v_peas,1,'cup'),(r_id,v_onion,1,'piece'),
    (r_id,v_garlic,3,'clove'),(r_id,v_tomato_paste,2,'tbsp'),(r_id,v_oil,2,'tbsp'),
    (r_id,v_salt,1,'tsp'),(r_id,v_pepper,0.5,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Peel and cube potatoes','{"action":"chop","item":"potato","size":"2cm"}'),
    (r_id,2,'Sauté onion and garlic in oil','{"action":"saute","item":"onion,garlic","minutes":3}'),
    (r_id,3,'Add tomato paste and spices, stir 1 min','{"action":"stir","item":"tomato_paste,spices"}'),
    (r_id,4,'Add potatoes and 1 cup water, simmer 15 min','{"action":"simmer","item":"potato","minutes":15}'),
    (r_id,5,'Add peas, cook 5 more min','{"action":"cook","item":"peas","minutes":5}');

  -- ── R43: Butter Toast with Egg ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Butter Toast with Egg','Simple toasted bread with a fried egg','Western',1,1,5,1,ARRAY['quick','breakfast','egg'])
  RETURNING id INTO r_id;
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v_bread,2,'slice'),(r_id,v_egg,1,'piece'),(r_id,v_butter,15,'g'),(r_id,v_salt,0.1,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Toast bread, spread with butter','{"action":"toast","item":"bread","minutes":2}'),
    (r_id,2,'Fry egg in remaining butter, season with salt','{"action":"fry","item":"egg","minutes":3}'),
    (r_id,3,'Place egg on toast','{"action":"plate","items":"toast,egg"}');

  -- ── R44: Chicken Garlic Rice ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Garlic Chicken Rice Bowl','Filipino-inspired garlic chicken over rice','Asian',2,5,15,2,ARRAY['chicken','rice','garlic'])
  RETURNING id INTO r_id;
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v_chicken,300,'g'),(r_id,v_rice,2,'cup'),(r_id,v_garlic,6,'clove'),
    (r_id,v_soy,2,'tbsp'),(r_id,v_oil,2,'tbsp'),(r_id,v_salt,0.5,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Cook rice','{"action":"cook","item":"rice","minutes":20}'),
    (r_id,2,'Cook chicken pieces with salt until browned','{"action":"fry","item":"chicken","minutes":8}'),
    (r_id,3,'In same pan, fry sliced garlic until golden','{"action":"fry","item":"garlic","minutes":2}'),
    (r_id,4,'Serve chicken and garlic over rice, drizzle soy','{"action":"plate","items":"rice,chicken,garlic,soy"}');

  -- ── R45: Egg and Potato Hash ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Egg Potato Hash','Crispy potato hash topped with eggs','Western',2,10,15,2,ARRAY['breakfast','potato','egg'])
  RETURNING id INTO r_id;
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v_potato,3,'piece'),(r_id,v_egg,2,'piece'),(r_id,v_onion,0.5,'piece'),
    (r_id,v_oil,3,'tbsp'),(r_id,v_salt,0.5,'tsp'),(r_id,v_pepper,0.25,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Dice potatoes and onion small','{"action":"chop","item":"potato,onion","size":"small"}'),
    (r_id,2,'Fry potatoes in oil 10 min until crispy, add onion','{"action":"fry","item":"potato,onion","minutes":12}'),
    (r_id,3,'Make 2 wells, crack in eggs, cover and cook 4 min','{"action":"cook","item":"eggs","minutes":4}'),
    (r_id,4,'Season with salt and pepper','{"action":"season","item":"salt,pepper"}');

  -- ── R46: Flour Tortillas ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Flour Tortillas','Soft homemade flour tortillas','Latin',2,15,10,6,ARRAY['bread','latin'])
  RETURNING id INTO r_id;
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v_flour,2,'cup'),(r_id,v_oil,3,'tbsp'),(r_id,v_salt,0.5,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Mix flour, salt, oil, and 1/2 cup warm water into dough','{"action":"knead","item":"dough","minutes":5}'),
    (r_id,2,'Rest dough 10 minutes','{"action":"rest","minutes":10}'),
    (r_id,3,'Divide into 6, roll each into thin circle','{"action":"roll","item":"dough","count":6}'),
    (r_id,4,'Cook each on dry hot pan 1 min per side','{"action":"cook","item":"tortilla","minutes":2}');

  -- ── R47: Caramelized Onion Pasta ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Caramelized Onion Pasta','Sweet caramelized onions tossed with pasta','Italian',2,5,25,2,ARRAY['pasta','onion'])
  RETURNING id INTO r_id;
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v_pasta,250,'g'),(r_id,v_onion,3,'piece'),(r_id,v_butter,30,'g'),
    (r_id,v_oil,1,'tbsp'),(r_id,v_salt,0.5,'tsp'),(r_id,v_pepper,0.25,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Thinly slice all onions','{"action":"slice","item":"onion","size":"thin"}'),
    (r_id,2,'Cook onions in butter+oil on low heat 20 min, stirring','{"action":"caramelize","item":"onion","minutes":20}'),
    (r_id,3,'Cook pasta in boiling salted water','{"action":"boil","item":"pasta","minutes":10}'),
    (r_id,4,'Toss pasta with caramelized onions, season','{"action":"toss","item":"pasta,onions"}');

  -- ── R48: Egg and Bean Wrap ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Egg Bean Breakfast Wrap','Protein-packed breakfast wrap','Latin',1,5,8,2,ARRAY['quick','breakfast','beans','egg'])
  RETURNING id INTO r_id;
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v_egg,3,'piece'),(r_id,v_beans,0.5,'cup'),(r_id,v_flour,1,'cup'),
    (r_id,v_oil,2,'tbsp'),(r_id,v_salt,0.25,'tsp'),(r_id,v_pepper,0.1,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Scramble eggs with salt and pepper','{"action":"cook","item":"egg","style":"scramble"}'),
    (r_id,2,'Warm beans in a small pot','{"action":"warm","item":"beans","minutes":3}'),
    (r_id,3,'Warm tortilla or flatbread in pan','{"action":"warm","item":"tortilla","minutes":1}'),
    (r_id,4,'Fill with eggs, beans, roll up','{"action":"assemble","item":"wrap"}');

  -- ── R49: Chicken and Lentil Stew ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Chicken Lentil Stew','Hearty protein-rich stew','Mediterranean',3,10,35,4,ARRAY['stew','chicken','lentils'])
  RETURNING id INTO r_id;
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v_chicken,400,'g'),(r_id,v_lentils,1,'cup'),(r_id,v_onion,1,'piece'),
    (r_id,v_carrot,2,'piece'),(r_id,v_garlic,3,'clove'),(r_id,v_tomato_paste,2,'tbsp'),
    (r_id,v_oil,2,'tbsp'),(r_id,v_salt,1,'tsp'),(r_id,v_pepper,0.5,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Cut chicken into pieces, season','{"action":"chop","item":"chicken"}'),
    (r_id,2,'Brown chicken in oil, remove','{"action":"sear","item":"chicken","minutes":5}'),
    (r_id,3,'Sauté onion, carrot, garlic','{"action":"saute","item":"vegetables","minutes":3}'),
    (r_id,4,'Add tomato paste, lentils, 4 cups water','{"action":"add","item":"tomato_paste,lentils,water"}'),
    (r_id,5,'Return chicken, simmer 25 min','{"action":"simmer","minutes":25}');

  -- ── R50: Quick Bean Soup ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Quick Bean Soup','Fast and filling bean soup','Western',1,5,15,3,ARRAY['soup','beans','quick'])
  RETURNING id INTO r_id;
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v_beans,1.5,'cup'),(r_id,v_onion,1,'piece'),(r_id,v_garlic,2,'clove'),
    (r_id,v_tomato_paste,1,'tbsp'),(r_id,v_oil,1,'tbsp'),(r_id,v_salt,1,'tsp'),(r_id,v_pepper,0.25,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Sauté diced onion and garlic in oil','{"action":"saute","item":"onion,garlic","minutes":2}'),
    (r_id,2,'Add tomato paste, stir 30 sec','{"action":"stir","item":"tomato_paste"}'),
    (r_id,3,'Add beans and 3 cups water, bring to boil','{"action":"boil","item":"beans,water"}'),
    (r_id,4,'Simmer 10 min, partially mash for thickness','{"action":"simmer","minutes":10}'),
    (r_id,5,'Season and serve','{"action":"season","item":"salt,pepper"}');

END $$;
