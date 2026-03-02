-- ============================================================
-- I-Fridge — Seed: Recipes (Part 1 of 2) — 25 Recipes
-- ============================================================
-- Run seed_ingredients.sql FIRST.
-- Uses a DO block to reference ingredient IDs by canonical_name.
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
  -- Resolve ingredient IDs
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

  -- ── R1: Classic Fried Rice ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Classic Fried Rice','Quick and savory fried rice with egg and vegetables','Asian',1,5,10,2,ARRAY['quick','rice'])
  RETURNING id INTO r_id;
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v_rice,2,'cup'),(r_id,v_egg,2,'piece'),(r_id,v_onion,0.5,'piece'),
    (r_id,v_carrot,1,'piece'),(r_id,v_soy,2,'tbsp'),(r_id,v_oil,2,'tbsp'),(r_id,v_salt,0.5,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Cook rice and let it cool (or use leftover rice)','{"action":"cook","item":"rice","minutes":20}'),
    (r_id,2,'Dice onion and carrot into small cubes','{"action":"chop","item":"onion,carrot","size":"small"}'),
    (r_id,3,'Heat oil in a wok over high heat','{"action":"heat","tool":"wok","temp":"high"}'),
    (r_id,4,'Scramble eggs, push to side','{"action":"cook","item":"egg","style":"scramble"}'),
    (r_id,5,'Add vegetables, stir-fry 2 minutes','{"action":"stir_fry","item":"vegetables","minutes":2}'),
    (r_id,6,'Add rice, soy sauce, toss until heated through','{"action":"toss","item":"rice","minutes":3}');

  -- ── R2: Scrambled Eggs on Toast ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Scrambled Eggs on Toast','Creamy scrambled eggs on buttered toast','Western',1,2,5,1,ARRAY['quick','breakfast'])
  RETURNING id INTO r_id;
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v_egg,3,'piece'),(r_id,v_butter,15,'g'),(r_id,v_bread,2,'slice'),
    (r_id,v_milk,30,'ml'),(r_id,v_salt,0.25,'tsp'),(r_id,v_pepper,0.25,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Beat eggs with milk, salt, and pepper','{"action":"whisk","item":"egg,milk,salt,pepper"}'),
    (r_id,2,'Toast bread slices','{"action":"toast","item":"bread","minutes":2}'),
    (r_id,3,'Melt butter in a non-stick pan over low heat','{"action":"heat","tool":"pan","temp":"low"}'),
    (r_id,4,'Pour in egg mixture, gently stir until just set','{"action":"cook","item":"egg","style":"scramble","minutes":3}'),
    (r_id,5,'Serve eggs on toast','{"action":"plate","items":"eggs,toast"}');

  -- ── R3: Chicken Stir-Fry ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Chicken Stir-Fry','Quick chicken and vegetable stir-fry with soy sauce','Asian',2,10,10,2,ARRAY['quick','chicken'])
  RETURNING id INTO r_id;
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v_chicken,300,'g'),(r_id,v_onion,1,'piece'),(r_id,v_carrot,1,'piece'),
    (r_id,v_garlic,3,'clove'),(r_id,v_soy,3,'tbsp'),(r_id,v_oil,2,'tbsp'),(r_id,v_salt,0.5,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Cut chicken into bite-sized pieces','{"action":"chop","item":"chicken","size":"bite"}'),
    (r_id,2,'Slice onion, carrot, and mince garlic','{"action":"chop","item":"onion,carrot,garlic"}'),
    (r_id,3,'Heat oil in wok over high heat, cook chicken 5 min','{"action":"stir_fry","item":"chicken","minutes":5}'),
    (r_id,4,'Add vegetables, stir-fry 3 minutes','{"action":"stir_fry","item":"vegetables","minutes":3}'),
    (r_id,5,'Add soy sauce and salt, toss 1 minute','{"action":"season","item":"soy_sauce,salt"}');

  -- ── R4: Beef and Potato Stew ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Beef and Potato Stew','Hearty slow-cooked beef stew with potatoes and carrots','Western',3,15,60,4,ARRAY['stew','beef','comfort'])
  RETURNING id INTO r_id;
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v_beef,500,'g'),(r_id,v_potato,3,'piece'),(r_id,v_carrot,2,'piece'),
    (r_id,v_onion,1,'piece'),(r_id,v_garlic,4,'clove'),(r_id,v_tomato_paste,2,'tbsp'),
    (r_id,v_oil,2,'tbsp'),(r_id,v_salt,1,'tsp'),(r_id,v_pepper,0.5,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Cut beef into 2cm cubes, season with salt and pepper','{"action":"chop","item":"beef","size":"2cm"}'),
    (r_id,2,'Peel and cube potatoes and carrots','{"action":"chop","item":"potato,carrot","size":"2cm"}'),
    (r_id,3,'Brown beef in oil over high heat, 3-4 minutes','{"action":"sear","item":"beef","minutes":4}'),
    (r_id,4,'Add diced onion and garlic, cook 2 minutes','{"action":"saute","item":"onion,garlic","minutes":2}'),
    (r_id,5,'Add tomato paste, stir 1 minute','{"action":"stir","item":"tomato_paste","minutes":1}'),
    (r_id,6,'Add water to cover, bring to boil, then simmer','{"action":"boil","item":"water"}'),
    (r_id,7,'Add potatoes and carrots, simmer 45 minutes until tender','{"action":"simmer","minutes":45}');

  -- ── R5: Lentil Soup ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Lentil Soup','Thick and nutritious lentil soup','Mediterranean',2,10,30,4,ARRAY['soup','lentils','healthy'])
  RETURNING id INTO r_id;
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v_lentils,1.5,'cup'),(r_id,v_onion,1,'piece'),(r_id,v_carrot,2,'piece'),
    (r_id,v_garlic,3,'clove'),(r_id,v_tomato_paste,1,'tbsp'),(r_id,v_oil,2,'tbsp'),
    (r_id,v_salt,1,'tsp'),(r_id,v_pepper,0.5,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Rinse lentils under cold water','{"action":"wash","item":"lentils"}'),
    (r_id,2,'Dice onion, carrot, mince garlic','{"action":"chop","item":"onion,carrot,garlic"}'),
    (r_id,3,'Sauté onion and garlic in oil until soft','{"action":"saute","item":"onion,garlic","minutes":3}'),
    (r_id,4,'Add carrot and tomato paste, stir 1 minute','{"action":"stir","item":"carrot,tomato_paste"}'),
    (r_id,5,'Add lentils and 4 cups water, bring to boil','{"action":"boil","item":"lentils,water"}'),
    (r_id,6,'Simmer 25 minutes until lentils are tender','{"action":"simmer","minutes":25}');

  -- ── R6: Simple Pancakes ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Simple Pancakes','Fluffy homemade pancakes','Western',1,5,10,4,ARRAY['breakfast','baking'])
  RETURNING id INTO r_id;
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v_flour,1.5,'cup'),(r_id,v_egg,1,'piece'),(r_id,v_milk,250,'ml'),
    (r_id,v_sugar,2,'tbsp'),(r_id,v_baking_soda,1,'tsp'),(r_id,v_butter,30,'g'),(r_id,v_salt,0.25,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Mix flour, sugar, baking soda, and salt in a bowl','{"action":"mix","item":"dry_ingredients"}'),
    (r_id,2,'Whisk egg, milk, and melted butter together','{"action":"whisk","item":"wet_ingredients"}'),
    (r_id,3,'Combine wet and dry ingredients, stir until just mixed','{"action":"mix","item":"batter"}'),
    (r_id,4,'Heat a greased pan over medium heat','{"action":"heat","tool":"pan","temp":"medium"}'),
    (r_id,5,'Pour 1/4 cup batter per pancake, cook until bubbles form','{"action":"cook","item":"pancake","minutes":2}'),
    (r_id,6,'Flip and cook another 1-2 minutes until golden','{"action":"flip","item":"pancake","minutes":2}');

  -- ── R7: Garlic Butter Pasta ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Garlic Butter Pasta','Simple yet delicious garlic and butter pasta','Italian',1,5,15,2,ARRAY['quick','pasta'])
  RETURNING id INTO r_id;
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v_pasta,250,'g'),(r_id,v_garlic,5,'clove'),(r_id,v_butter,50,'g'),
    (r_id,v_oil,1,'tbsp'),(r_id,v_salt,1,'tsp'),(r_id,v_pepper,0.5,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Boil salted water and cook pasta according to package','{"action":"boil","item":"pasta","minutes":10}'),
    (r_id,2,'Thinly slice garlic','{"action":"slice","item":"garlic","size":"thin"}'),
    (r_id,3,'Melt butter with oil in a pan, add garlic, cook 2 min','{"action":"saute","item":"garlic,butter","minutes":2}'),
    (r_id,4,'Toss drained pasta in garlic butter, season','{"action":"toss","item":"pasta","minutes":1}');

  -- ── R8: Bean and Rice Bowl ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Bean and Rice Bowl','Protein-packed beans served over fluffy rice','Latin',1,5,20,2,ARRAY['quick','beans','healthy'])
  RETURNING id INTO r_id;
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v_beans,1,'cup'),(r_id,v_rice,1.5,'cup'),(r_id,v_onion,0.5,'piece'),
    (r_id,v_garlic,2,'clove'),(r_id,v_oil,1,'tbsp'),(r_id,v_salt,0.5,'tsp'),(r_id,v_pepper,0.25,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Cook rice according to package instructions','{"action":"cook","item":"rice","minutes":20}'),
    (r_id,2,'Sauté diced onion and garlic in oil','{"action":"saute","item":"onion,garlic","minutes":3}'),
    (r_id,3,'Add beans (drained if canned), season, heat through','{"action":"cook","item":"beans","minutes":5}'),
    (r_id,4,'Serve beans over rice','{"action":"plate","items":"rice,beans"}');

  -- ── R9: Creamy Potato Soup ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Creamy Potato Soup','Rich and creamy potato soup','Western',2,10,25,4,ARRAY['soup','potato','comfort'])
  RETURNING id INTO r_id;
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v_potato,4,'piece'),(r_id,v_onion,1,'piece'),(r_id,v_garlic,2,'clove'),
    (r_id,v_butter,30,'g'),(r_id,v_milk,200,'ml'),(r_id,v_salt,1,'tsp'),(r_id,v_pepper,0.5,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Peel and dice potatoes into small cubes','{"action":"chop","item":"potato","size":"small"}'),
    (r_id,2,'Sauté diced onion and garlic in butter','{"action":"saute","item":"onion,garlic","minutes":3}'),
    (r_id,3,'Add potatoes and water to cover, boil','{"action":"boil","item":"potato,water"}'),
    (r_id,4,'Simmer 20 minutes until potatoes are very soft','{"action":"simmer","minutes":20}'),
    (r_id,5,'Mash or blend, stir in milk, season to taste','{"action":"blend","item":"soup"}');

  -- ── R10: Egg Fried Bread ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Egg Fried Bread','Golden pan-fried bread dipped in egg — like French toast','Western',1,3,5,2,ARRAY['quick','breakfast'])
  RETURNING id INTO r_id;
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v_bread,4,'slice'),(r_id,v_egg,2,'piece'),(r_id,v_milk,30,'ml'),
    (r_id,v_butter,20,'g'),(r_id,v_sugar,1,'tbsp'),(r_id,v_salt,0.1,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Beat eggs with milk, sugar, and pinch of salt','{"action":"whisk","item":"egg,milk,sugar,salt"}'),
    (r_id,2,'Dip bread slices in egg mixture','{"action":"dip","item":"bread"}'),
    (r_id,3,'Fry in butter over medium heat, 2 min per side','{"action":"fry","item":"bread","minutes":4}');

  -- ── R11: Chicken Rice ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'One-Pot Chicken Rice','Flavorful chicken cooked with rice in one pot','Asian',2,10,25,3,ARRAY['chicken','rice','one-pot'])
  RETURNING id INTO r_id;
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v_chicken,400,'g'),(r_id,v_rice,2,'cup'),(r_id,v_onion,1,'piece'),
    (r_id,v_garlic,3,'clove'),(r_id,v_soy,2,'tbsp'),(r_id,v_oil,1,'tbsp'),
    (r_id,v_salt,0.5,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Season chicken with salt and soy sauce','{"action":"season","item":"chicken"}'),
    (r_id,2,'Sauté diced onion and garlic in oil','{"action":"saute","item":"onion,garlic","minutes":2}'),
    (r_id,3,'Add chicken, brown on both sides','{"action":"sear","item":"chicken","minutes":4}'),
    (r_id,4,'Add rinsed rice and 3 cups water','{"action":"add","item":"rice,water"}'),
    (r_id,5,'Cover, simmer on low 20 minutes until rice is done','{"action":"simmer","minutes":20}');

  -- ── R12: Mashed Potatoes ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Creamy Mashed Potatoes','Smooth, buttery mashed potatoes','Western',1,10,20,4,ARRAY['side','potato'])
  RETURNING id INTO r_id;
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v_potato,5,'piece'),(r_id,v_butter,50,'g'),(r_id,v_milk,100,'ml'),
    (r_id,v_salt,1,'tsp'),(r_id,v_pepper,0.25,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Peel and quarter potatoes','{"action":"chop","item":"potato","size":"quarter"}'),
    (r_id,2,'Boil in salted water 15-20 min until fork-tender','{"action":"boil","item":"potato","minutes":18}'),
    (r_id,3,'Drain and mash with butter and warm milk','{"action":"mash","item":"potato,butter,milk"}'),
    (r_id,4,'Season with salt and pepper','{"action":"season","item":"salt,pepper"}');

  -- ── R13: Soy Garlic Chicken ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Soy Garlic Chicken','Korean-inspired sweet soy garlic glazed chicken','Korean',2,10,20,2,ARRAY['chicken','korean'])
  RETURNING id INTO r_id;
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v_chicken,400,'g'),(r_id,v_soy,3,'tbsp'),(r_id,v_garlic,4,'clove'),
    (r_id,v_sugar,1,'tbsp'),(r_id,v_oil,2,'tbsp'),(r_id,v_pepper,0.25,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Cut chicken into pieces','{"action":"chop","item":"chicken","size":"bite"}'),
    (r_id,2,'Mix soy sauce, minced garlic, sugar for glaze','{"action":"mix","item":"soy,garlic,sugar"}'),
    (r_id,3,'Pan-fry chicken in oil until golden, 8 min','{"action":"fry","item":"chicken","minutes":8}'),
    (r_id,4,'Pour glaze over chicken, cook 3 min until sticky','{"action":"glaze","item":"chicken","minutes":3}');

  -- ── R14: Carrot Soup ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Carrot Ginger Soup','Smooth carrot soup with a hint of warmth','Western',2,10,25,4,ARRAY['soup','carrot','healthy'])
  RETURNING id INTO r_id;
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v_carrot,5,'piece'),(r_id,v_onion,1,'piece'),(r_id,v_garlic,2,'clove'),
    (r_id,v_butter,20,'g'),(r_id,v_salt,1,'tsp'),(r_id,v_pepper,0.25,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Peel and chop carrots','{"action":"chop","item":"carrot"}'),
    (r_id,2,'Sauté onion and garlic in butter until soft','{"action":"saute","item":"onion,garlic","minutes":3}'),
    (r_id,3,'Add carrots and water to cover, boil','{"action":"boil","item":"carrot,water"}'),
    (r_id,4,'Simmer 20 min until carrots are very tender','{"action":"simmer","minutes":20}'),
    (r_id,5,'Blend until smooth, season','{"action":"blend","item":"soup"}');

  -- ── R15: Pasta with Tomato Sauce ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Pasta with Tomato Sauce','Classic tomato pasta','Italian',1,5,15,2,ARRAY['quick','pasta'])
  RETURNING id INTO r_id;
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v_pasta,250,'g'),(r_id,v_tomato_paste,3,'tbsp'),(r_id,v_garlic,3,'clove'),
    (r_id,v_onion,0.5,'piece'),(r_id,v_oil,2,'tbsp'),(r_id,v_sugar,0.5,'tsp'),
    (r_id,v_salt,1,'tsp'),(r_id,v_pepper,0.25,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Cook pasta in boiling salted water','{"action":"boil","item":"pasta","minutes":10}'),
    (r_id,2,'Sauté garlic and onion in oil','{"action":"saute","item":"garlic,onion","minutes":2}'),
    (r_id,3,'Add tomato paste and 1/2 cup water, stir','{"action":"stir","item":"tomato_paste,water"}'),
    (r_id,4,'Add sugar, salt, pepper, simmer 5 min','{"action":"simmer","minutes":5}'),
    (r_id,5,'Toss with drained pasta','{"action":"toss","item":"pasta"}');

  -- ── R16: Omelette ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Veggie Omelette','Fluffy omelette with onion and carrot','Western',1,5,5,1,ARRAY['quick','breakfast','egg'])
  RETURNING id INTO r_id;
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v_egg,3,'piece'),(r_id,v_onion,0.25,'piece'),(r_id,v_carrot,0.5,'piece'),
    (r_id,v_butter,15,'g'),(r_id,v_salt,0.25,'tsp'),(r_id,v_pepper,0.1,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Finely dice onion and grate carrot','{"action":"chop","item":"onion,carrot","size":"fine"}'),
    (r_id,2,'Beat eggs with salt and pepper','{"action":"whisk","item":"egg,salt,pepper"}'),
    (r_id,3,'Melt butter, sauté vegetables 1 min','{"action":"saute","item":"vegetables","minutes":1}'),
    (r_id,4,'Pour in eggs, cook until set, fold in half','{"action":"cook","item":"omelette","minutes":3}');

  -- ── R17: Beef Fried Rice ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Beef Fried Rice','Savory beef fried rice with soy sauce','Asian',2,5,12,2,ARRAY['quick','beef','rice'])
  RETURNING id INTO r_id;
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v_beef,200,'g'),(r_id,v_rice,2,'cup'),(r_id,v_egg,1,'piece'),
    (r_id,v_onion,0.5,'piece'),(r_id,v_soy,2,'tbsp'),(r_id,v_oil,2,'tbsp'),(r_id,v_salt,0.25,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Thinly slice beef','{"action":"slice","item":"beef","size":"thin"}'),
    (r_id,2,'Stir-fry beef in oil over high heat until browned','{"action":"stir_fry","item":"beef","minutes":3}'),
    (r_id,3,'Push beef aside, scramble egg','{"action":"cook","item":"egg","style":"scramble"}'),
    (r_id,4,'Add rice, onion, soy sauce, toss everything together','{"action":"toss","item":"rice,vegetables,soy","minutes":3}');

  -- ── R18: Butter Bean Stew ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Butter Bean Stew','Creamy butter bean stew with tomato','Mediterranean',2,5,25,3,ARRAY['stew','beans','healthy'])
  RETURNING id INTO r_id;
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v_beans,1.5,'cup'),(r_id,v_tomato_paste,2,'tbsp'),(r_id,v_onion,1,'piece'),
    (r_id,v_garlic,3,'clove'),(r_id,v_oil,2,'tbsp'),(r_id,v_salt,1,'tsp'),(r_id,v_pepper,0.25,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Sauté diced onion and garlic in oil','{"action":"saute","item":"onion,garlic","minutes":3}'),
    (r_id,2,'Add tomato paste and stir 1 min','{"action":"stir","item":"tomato_paste","minutes":1}'),
    (r_id,3,'Add beans and 2 cups water, bring to boil','{"action":"boil","item":"beans,water"}'),
    (r_id,4,'Simmer 20 minutes, season to taste','{"action":"simmer","minutes":20}');

  -- ── R19: Pea Soup ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Split Pea Soup','Thick and hearty split pea soup','Western',2,5,35,4,ARRAY['soup','peas','healthy'])
  RETURNING id INTO r_id;
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v_peas,1.5,'cup'),(r_id,v_carrot,2,'piece'),(r_id,v_onion,1,'piece'),
    (r_id,v_garlic,2,'clove'),(r_id,v_oil,1,'tbsp'),(r_id,v_salt,1,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Dice carrot, onion, and mince garlic','{"action":"chop","item":"carrot,onion,garlic"}'),
    (r_id,2,'Sauté vegetables in oil 3 minutes','{"action":"saute","item":"vegetables","minutes":3}'),
    (r_id,3,'Add peas and 5 cups water, bring to boil','{"action":"boil","item":"peas,water"}'),
    (r_id,4,'Simmer 30 min until peas break down','{"action":"simmer","minutes":30}'),
    (r_id,5,'Season and serve','{"action":"season","item":"salt"}');

  -- ── R20: Coffee Cake ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Coffee Cake','Moist coffee-flavored cake','Western',3,15,35,8,ARRAY['baking','coffee','dessert'])
  RETURNING id INTO r_id;
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v_flour,2,'cup'),(r_id,v_sugar,0.75,'cup'),(r_id,v_egg,2,'piece'),
    (r_id,v_butter,100,'g'),(r_id,v_milk,200,'ml'),(r_id,v_coffee,2,'tbsp'),
    (r_id,v_baking_soda,1.5,'tsp'),(r_id,v_salt,0.25,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Preheat oven to 180°C (350°F)','{"action":"preheat","tool":"oven","temp_c":180}'),
    (r_id,2,'Dissolve coffee in 2 tbsp hot water','{"action":"dissolve","item":"coffee,water"}'),
    (r_id,3,'Cream butter and sugar until fluffy','{"action":"cream","item":"butter,sugar"}'),
    (r_id,4,'Beat in eggs one at a time','{"action":"mix","item":"eggs"}'),
    (r_id,5,'Mix flour, baking soda, salt separately','{"action":"mix","item":"dry_ingredients"}'),
    (r_id,6,'Alternate adding flour mix and milk to batter','{"action":"fold","item":"flour,milk"}'),
    (r_id,7,'Stir in coffee, pour into greased pan','{"action":"pour","item":"batter"}'),
    (r_id,8,'Bake 30-35 minutes until a toothpick comes out clean','{"action":"bake","minutes":33}');

  -- ── R21: Garlic Bread ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Garlic Bread','Crispy garlic butter bread','Italian',1,5,8,2,ARRAY['quick','side','bread'])
  RETURNING id INTO r_id;
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v_bread,4,'slice'),(r_id,v_butter,40,'g'),(r_id,v_garlic,3,'clove'),(r_id,v_salt,0.1,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Mix softened butter with minced garlic and salt','{"action":"mix","item":"butter,garlic,salt"}'),
    (r_id,2,'Spread garlic butter on bread slices','{"action":"spread","item":"butter,bread"}'),
    (r_id,3,'Toast in oven or pan until golden and crispy','{"action":"toast","item":"bread","minutes":5}');

  -- ── R22: Egg Drop Soup ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Egg Drop Soup','Light and silky Chinese-style egg soup','Asian',1,2,8,2,ARRAY['quick','soup','egg'])
  RETURNING id INTO r_id;
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v_egg,2,'piece'),(r_id,v_soy,1,'tbsp'),(r_id,v_salt,0.5,'tsp'),
    (r_id,v_pepper,0.1,'tsp'),(r_id,v_oil,1,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Bring 3 cups water to a boil','{"action":"boil","item":"water"}'),
    (r_id,2,'Add soy sauce and salt','{"action":"season","item":"soy,salt"}'),
    (r_id,3,'Beat eggs, slowly drizzle into boiling soup while stirring','{"action":"drizzle","item":"egg"}'),
    (r_id,4,'Remove from heat, season with pepper and oil','{"action":"season","item":"pepper,oil"}');

  -- ── R23: Potato Pancakes ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Potato Pancakes','Crispy pan-fried potato pancakes','Eastern European',2,10,10,3,ARRAY['potato','side'])
  RETURNING id INTO r_id;
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v_potato,3,'piece'),(r_id,v_egg,1,'piece'),(r_id,v_flour,2,'tbsp'),
    (r_id,v_onion,0.5,'piece'),(r_id,v_oil,3,'tbsp'),(r_id,v_salt,0.5,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Grate potatoes and onion, squeeze out liquid','{"action":"grate","item":"potato,onion"}'),
    (r_id,2,'Mix with egg, flour, and salt','{"action":"mix","item":"potato,egg,flour,salt"}'),
    (r_id,3,'Form into patties','{"action":"shape","item":"patties"}'),
    (r_id,4,'Fry in oil 3-4 min per side until golden','{"action":"fry","item":"patties","minutes":7}');

  -- ── R24: Lentil Dal ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Lentil Dal','Spiced Indian-style lentil stew, served with rice','Indian',2,5,25,3,ARRAY['lentils','healthy','indian'])
  RETURNING id INTO r_id;
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v_lentils,1,'cup'),(r_id,v_onion,1,'piece'),(r_id,v_garlic,3,'clove'),
    (r_id,v_tomato_paste,1,'tbsp'),(r_id,v_oil,2,'tbsp'),(r_id,v_salt,1,'tsp'),
    (r_id,v_pepper,0.5,'tsp'),(r_id,v_butter,15,'g');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Rinse lentils','{"action":"wash","item":"lentils"}'),
    (r_id,2,'Sauté onion and garlic in oil until golden','{"action":"saute","item":"onion,garlic","minutes":4}'),
    (r_id,3,'Add tomato paste and spices, stir 1 min','{"action":"stir","item":"tomato_paste,spices"}'),
    (r_id,4,'Add lentils and 3 cups water, bring to boil','{"action":"boil","item":"lentils,water"}'),
    (r_id,5,'Simmer 20 min until lentils are soft and thick','{"action":"simmer","minutes":20}'),
    (r_id,6,'Finish with butter, serve over rice','{"action":"garnish","item":"butter"}');

  -- ── R25: Simple Beef Patties ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Beef Patties','Juicy homemade beef patties','Western',2,10,10,4,ARRAY['beef','quick'])
  RETURNING id INTO r_id;
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v_beef,400,'g'),(r_id,v_onion,0.5,'piece'),(r_id,v_egg,1,'piece'),
    (r_id,v_bread,1,'slice'),(r_id,v_salt,1,'tsp'),(r_id,v_pepper,0.5,'tsp'),(r_id,v_oil,2,'tbsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Finely dice onion, soak bread in water and squeeze','{"action":"prep","item":"onion,bread"}'),
    (r_id,2,'Mix beef, onion, soaked bread, egg, salt, pepper','{"action":"mix","item":"beef,onion,bread,egg,seasoning"}'),
    (r_id,3,'Form into 4 patties','{"action":"shape","item":"patties","count":4}'),
    (r_id,4,'Pan-fry in oil 4-5 min per side until cooked through','{"action":"fry","item":"patties","minutes":9}');

END $$;
