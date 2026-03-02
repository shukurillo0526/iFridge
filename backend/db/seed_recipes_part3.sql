-- ============================================================
-- I-Fridge — Seed: Famous World Recipes (Part 3) — 25 Recipes
-- ============================================================
-- Creates a temp helper function, seeds 25 famous dishes,
-- then drops the helper.
-- ============================================================

-- Helper: find-or-create ingredient by name, returns its UUID
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

  -- ── R51: American Pancakes ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'American Pancakes','Thick, fluffy buttermilk pancakes with maple syrup','American',1,5,10,4,ARRAY['breakfast','baking','quick'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Flour','baking','cup'); v2:=_ensure_ing('Egg','protein','piece');
  v3:=_ensure_ing('Milk','dairy','ml'); v4:=_ensure_ing('Butter','dairy','g');
  v5:=_ensure_ing('Sugar','baking','tbsp'); v6:=_ensure_ing('Baking Soda','baking','tsp');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,1.5,'cup'),(r_id,v2,2,'piece'),(r_id,v3,300,'ml'),(r_id,v4,30,'g'),(r_id,v5,2,'tbsp'),(r_id,v6,1,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Mix flour, sugar, baking soda, salt in bowl','{"action":"mix","item":"dry_ingredients"}'),
    (r_id,2,'Whisk eggs, milk, melted butter separately','{"action":"whisk","item":"wet_ingredients"}'),
    (r_id,3,'Combine wet into dry, stir until just mixed (lumpy is OK)','{"action":"fold","item":"batter"}'),
    (r_id,4,'Ladle 1/4 cup onto hot buttered griddle','{"action":"pour","item":"batter"}'),
    (r_id,5,'Cook until bubbles form on surface, flip, cook 2 min more','{"action":"cook","item":"pancake","minutes":4}'),
    (r_id,6,'Serve stacked with butter and maple syrup','{"action":"plate","items":"pancakes,butter,syrup"}');

  -- ── R52: Korean Fish Soup (Maeuntang) ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Maeuntang (Korean Spicy Fish Soup)','Traditional Korean spicy fish stew with tofu and vegetables','Korean',3,15,25,4,ARRAY['soup','korean','seafood','spicy'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('White Fish Fillet','seafood','g'); v2:=_ensure_ing('Tofu','protein','g');
  v3:=_ensure_ing('Onion','vegetable','piece'); v4:=_ensure_ing('Garlic','vegetable','clove');
  v5:=_ensure_ing('Korean Chili Flakes','seasoning','tbsp'); v6:=_ensure_ing('Soy Sauce','condiment','tbsp');
  v7:=_ensure_ing('Egg','protein','piece'); v8:=_ensure_ing('Salt','seasoning','tsp');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,300,'g'),(r_id,v2,200,'g'),(r_id,v3,1,'piece'),(r_id,v4,4,'clove'),
    (r_id,v5,2,'tbsp'),(r_id,v6,2,'tbsp'),(r_id,v7,1,'piece'),(r_id,v8,1,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Cut fish into chunks, cube tofu, slice onion','{"action":"chop","item":"fish,tofu,onion"}'),
    (r_id,2,'Bring 4 cups water to boil with garlic and chili flakes','{"action":"boil","item":"water,garlic,chili"}'),
    (r_id,3,'Add fish pieces, cook 10 minutes','{"action":"simmer","item":"fish","minutes":10}'),
    (r_id,4,'Add tofu and onion, simmer 8 minutes','{"action":"simmer","item":"tofu,onion","minutes":8}'),
    (r_id,5,'Season with soy sauce and salt','{"action":"season","item":"soy,salt"}'),
    (r_id,6,'Crack in egg, stir gently, serve hot','{"action":"add","item":"egg"}');

  -- ── R53: Japanese Ramen ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Shoyu Ramen','Japanese soy sauce ramen with soft-boiled egg','Japanese',3,15,30,2,ARRAY['soup','japanese','noodles'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Ramen Noodles','grain','g'); v2:=_ensure_ing('Chicken','protein','g');
  v3:=_ensure_ing('Soy Sauce','condiment','tbsp'); v4:=_ensure_ing('Garlic','vegetable','clove');
  v5:=_ensure_ing('Egg','protein','piece'); v6:=_ensure_ing('Salt','seasoning','tsp');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,200,'g'),(r_id,v2,200,'g'),(r_id,v3,3,'tbsp'),(r_id,v4,3,'clove'),(r_id,v5,2,'piece'),(r_id,v6,0.5,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Simmer chicken in 4 cups water with garlic for 20 min to make broth','{"action":"simmer","item":"chicken,garlic","minutes":20}'),
    (r_id,2,'Remove chicken, shred, season broth with soy sauce','{"action":"shred","item":"chicken"}'),
    (r_id,3,'Soft-boil eggs: 6.5 min in boiling water, ice bath','{"action":"boil","item":"egg","minutes":7}'),
    (r_id,4,'Cook ramen noodles separately per package','{"action":"boil","item":"noodles","minutes":3}'),
    (r_id,5,'Assemble: noodles in bowl, pour hot broth, top with chicken and halved egg','{"action":"plate","items":"noodles,broth,chicken,egg"}');

  -- ── R54: Italian Margherita Pizza ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Margherita Pizza','Classic Neapolitan pizza with tomato, mozzarella, and basil','Italian',3,30,12,2,ARRAY['italian','baking','pizza'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Flour','baking','cup'); v2:=_ensure_ing('Tomato Paste','condiment','tbsp');
  v3:=_ensure_ing('Mozzarella','dairy','g'); v4:=_ensure_ing('Cooking Oil','oil','tbsp');
  v5:=_ensure_ing('Salt','seasoning','tsp'); v6:=_ensure_ing('Sugar','baking','tsp');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,2.5,'cup'),(r_id,v2,4,'tbsp'),(r_id,v3,200,'g'),(r_id,v4,2,'tbsp'),(r_id,v5,1,'tsp'),(r_id,v6,1,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Mix flour, salt, sugar, oil and warm water into dough, knead 10 min','{"action":"knead","item":"dough","minutes":10}'),
    (r_id,2,'Let dough rise 1 hour','{"action":"proof","minutes":60}'),
    (r_id,3,'Preheat oven to max (250°C)','{"action":"preheat","tool":"oven","temp_c":250}'),
    (r_id,4,'Stretch dough into circle, spread tomato paste','{"action":"stretch","item":"dough"}'),
    (r_id,5,'Top with torn mozzarella','{"action":"top","item":"mozzarella"}'),
    (r_id,6,'Bake 10-12 min until crust is golden and cheese bubbles','{"action":"bake","minutes":11}');

  -- ── R55: Thai Pad Thai ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Pad Thai','Classic Thai stir-fried noodles with egg and peanuts','Thai',3,15,10,2,ARRAY['thai','noodles','quick'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Rice Noodles','grain','g'); v2:=_ensure_ing('Egg','protein','piece');
  v3:=_ensure_ing('Cooking Oil','oil','tbsp'); v4:=_ensure_ing('Soy Sauce','condiment','tbsp');
  v5:=_ensure_ing('Sugar','baking','tbsp'); v6:=_ensure_ing('Peanuts','snack','tbsp');
  v7:=_ensure_ing('Bean Sprouts','vegetable','cup'); v8:=_ensure_ing('Garlic','vegetable','clove');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,200,'g'),(r_id,v2,2,'piece'),(r_id,v3,3,'tbsp'),(r_id,v4,3,'tbsp'),
    (r_id,v5,2,'tbsp'),(r_id,v6,3,'tbsp'),(r_id,v7,1,'cup'),(r_id,v8,3,'clove');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Soak rice noodles in warm water 15 min, drain','{"action":"soak","item":"noodles","minutes":15}'),
    (r_id,2,'Mix sauce: soy sauce, sugar, 1 tbsp water','{"action":"mix","item":"sauce"}'),
    (r_id,3,'Stir-fry garlic in oil 30 sec, add noodles','{"action":"stir_fry","item":"garlic,noodles"}'),
    (r_id,4,'Push aside, scramble eggs','{"action":"cook","item":"egg","style":"scramble"}'),
    (r_id,5,'Add sauce, toss everything 2 min','{"action":"toss","item":"noodles,sauce","minutes":2}'),
    (r_id,6,'Top with bean sprouts and crushed peanuts','{"action":"garnish","item":"sprouts,peanuts"}');

  -- ── R56: Mexican Tacos ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Beef Tacos','Classic Mexican seasoned beef tacos','Mexican',2,10,15,4,ARRAY['mexican','beef','quick'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Beef','protein','g'); v2:=_ensure_ing('Onion','vegetable','piece');
  v3:=_ensure_ing('Garlic','vegetable','clove'); v4:=_ensure_ing('Tomato Paste','condiment','tbsp');
  v5:=_ensure_ing('Flour','baking','cup'); v6:=_ensure_ing('Cooking Oil','oil','tbsp');
  v7:=_ensure_ing('Salt','seasoning','tsp');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,400,'g'),(r_id,v2,1,'piece'),(r_id,v3,3,'clove'),(r_id,v4,2,'tbsp'),
    (r_id,v5,2,'cup'),(r_id,v6,2,'tbsp'),(r_id,v7,1,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Make taco shells: mix flour, salt, oil, water, cook on dry pan','{"action":"cook","item":"tortillas","minutes":6}'),
    (r_id,2,'Brown beef with diced onion and garlic','{"action":"fry","item":"beef,onion,garlic","minutes":8}'),
    (r_id,3,'Add tomato paste and spices, cook 3 min','{"action":"stir","item":"tomato_paste,spices","minutes":3}'),
    (r_id,4,'Fill shells with seasoned beef','{"action":"assemble","item":"tacos"}');

  -- ── R57: French Crêpes ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'French Crêpes','Thin, delicate French pancakes','French',2,5,15,6,ARRAY['french','breakfast','dessert'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Flour','baking','cup'); v2:=_ensure_ing('Egg','protein','piece');
  v3:=_ensure_ing('Milk','dairy','ml'); v4:=_ensure_ing('Butter','dairy','g');
  v5:=_ensure_ing('Sugar','baking','tbsp'); v6:=_ensure_ing('Salt','seasoning','tsp');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,1,'cup'),(r_id,v2,2,'piece'),(r_id,v3,300,'ml'),(r_id,v4,30,'g'),(r_id,v5,1,'tbsp'),(r_id,v6,0.25,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Blend flour, eggs, milk, melted butter, sugar, salt until smooth','{"action":"blend","item":"batter"}'),
    (r_id,2,'Rest batter 30 min','{"action":"rest","minutes":30}'),
    (r_id,3,'Heat buttered pan, pour thin layer of batter, swirl','{"action":"pour","item":"batter"}'),
    (r_id,4,'Cook 1 min, flip, cook 30 sec more','{"action":"cook","item":"crepe","minutes":1.5}'),
    (r_id,5,'Fill with sugar, jam, or Nutella and fold','{"action":"plate","items":"crepe,filling"}');

  -- ── R58: Indian Butter Chicken ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Butter Chicken','Creamy, mildly spiced Indian chicken curry','Indian',3,15,25,4,ARRAY['indian','chicken','curry','spicy'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Chicken','protein','g'); v2:=_ensure_ing('Butter','dairy','g');
  v3:=_ensure_ing('Tomato Paste','condiment','tbsp'); v4:=_ensure_ing('Onion','vegetable','piece');
  v5:=_ensure_ing('Garlic','vegetable','clove'); v6:=_ensure_ing('Milk','dairy','ml');
  v7:=_ensure_ing('Salt','seasoning','tsp');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,500,'g'),(r_id,v2,50,'g'),(r_id,v3,4,'tbsp'),(r_id,v4,1,'piece'),
    (r_id,v5,4,'clove'),(r_id,v6,100,'ml'),(r_id,v7,1,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Cut chicken into pieces, season with salt','{"action":"chop","item":"chicken"}'),
    (r_id,2,'Fry chicken in butter until golden, set aside','{"action":"fry","item":"chicken","minutes":6}'),
    (r_id,3,'Sauté diced onion and garlic in same pan','{"action":"saute","item":"onion,garlic","minutes":3}'),
    (r_id,4,'Add tomato paste, cook 2 min','{"action":"stir","item":"tomato_paste","minutes":2}'),
    (r_id,5,'Add milk, return chicken, simmer 15 min until thick','{"action":"simmer","item":"sauce,chicken","minutes":15}'),
    (r_id,6,'Finish with extra butter, serve with rice','{"action":"garnish","item":"butter"}');

  -- ── R59: Spanish Tortilla ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Spanish Tortilla','Classic potato and onion omelette from Spain','Spanish',2,10,20,4,ARRAY['spanish','egg','potato'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Potato','vegetable','piece'); v2:=_ensure_ing('Egg','protein','piece');
  v3:=_ensure_ing('Onion','vegetable','piece'); v4:=_ensure_ing('Cooking Oil','oil','tbsp');
  v5:=_ensure_ing('Salt','seasoning','tsp');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,4,'piece'),(r_id,v2,6,'piece'),(r_id,v3,1,'piece'),(r_id,v4,4,'tbsp'),(r_id,v5,1,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Thinly slice potatoes and onion','{"action":"slice","item":"potato,onion","size":"thin"}'),
    (r_id,2,'Slowly fry in oil until soft, 12 min','{"action":"fry","item":"potato,onion","minutes":12}'),
    (r_id,3,'Beat eggs with salt, mix in the fried potato/onion','{"action":"mix","item":"egg,potato,onion"}'),
    (r_id,4,'Pour back into pan, cook on low 5 min','{"action":"cook","item":"tortilla","minutes":5}'),
    (r_id,5,'Flip using a plate, cook 3 more min','{"action":"flip","item":"tortilla","minutes":3}');

  -- ── R60: Greek Moussaka ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Greek Moussaka','Layered eggplant and beef bake with béchamel','Greek',4,25,45,6,ARRAY['greek','beef','baking'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Eggplant','vegetable','piece'); v2:=_ensure_ing('Beef','protein','g');
  v3:=_ensure_ing('Onion','vegetable','piece'); v4:=_ensure_ing('Tomato Paste','condiment','tbsp');
  v5:=_ensure_ing('Butter','dairy','g'); v6:=_ensure_ing('Flour','baking','tbsp');
  v7:=_ensure_ing('Milk','dairy','ml'); v8:=_ensure_ing('Salt','seasoning','tsp');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,2,'piece'),(r_id,v2,400,'g'),(r_id,v3,1,'piece'),(r_id,v4,3,'tbsp'),
    (r_id,v5,40,'g'),(r_id,v6,3,'tbsp'),(r_id,v7,400,'ml'),(r_id,v8,1,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Slice eggplant, salt and drain 20 min','{"action":"slice","item":"eggplant"}'),
    (r_id,2,'Brown beef with diced onion, add tomato paste','{"action":"fry","item":"beef,onion,tomato_paste","minutes":8}'),
    (r_id,3,'Fry eggplant slices in oil until golden','{"action":"fry","item":"eggplant","minutes":6}'),
    (r_id,4,'Make béchamel: melt butter, whisk flour, slowly add milk','{"action":"whisk","item":"butter,flour,milk"}'),
    (r_id,5,'Layer: eggplant, beef, eggplant, béchamel','{"action":"layer","item":"eggplant,beef,bechamel"}'),
    (r_id,6,'Bake at 180°C for 40 min until golden','{"action":"bake","temp_c":180,"minutes":40}');

  -- ── R61: Chinese Dumplings ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Chinese Dumplings (Jiaozi)','Pan-fried meat and veggie dumplings','Chinese',3,30,10,4,ARRAY['chinese','appetizer'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Flour','baking','cup'); v2:=_ensure_ing('Beef','protein','g');
  v3:=_ensure_ing('Onion','vegetable','piece'); v4:=_ensure_ing('Garlic','vegetable','clove');
  v5:=_ensure_ing('Soy Sauce','condiment','tbsp'); v6:=_ensure_ing('Cooking Oil','oil','tbsp');
  v7:=_ensure_ing('Salt','seasoning','tsp');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,2,'cup'),(r_id,v2,300,'g'),(r_id,v3,1,'piece'),(r_id,v4,3,'clove'),
    (r_id,v5,2,'tbsp'),(r_id,v6,3,'tbsp'),(r_id,v7,0.5,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Make dough: flour + 3/4 cup boiling water, knead 5 min, rest 20 min','{"action":"knead","item":"dough","minutes":5}'),
    (r_id,2,'Mix filling: minced meat, diced onion, garlic, soy sauce, salt','{"action":"mix","item":"filling"}'),
    (r_id,3,'Roll dough thin, cut circles, fill and pleat closed','{"action":"shape","item":"dumplings","count":20}'),
    (r_id,4,'Pan-fry in oil 2 min, add water, cover, steam 6 min','{"action":"fry","item":"dumplings","minutes":8}'),
    (r_id,5,'Serve with soy sauce dipping','{"action":"plate","items":"dumplings,soy_sauce"}');

  -- ── R62: Turkish Menemen ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Turkish Menemen','Scrambled eggs in tomato and pepper sauce','Turkish',1,5,10,2,ARRAY['turkish','breakfast','egg','quick'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Egg','protein','piece'); v2:=_ensure_ing('Tomato Paste','condiment','tbsp');
  v3:=_ensure_ing('Onion','vegetable','piece'); v4:=_ensure_ing('Cooking Oil','oil','tbsp');
  v5:=_ensure_ing('Salt','seasoning','tsp'); v6:=_ensure_ing('Black Pepper','seasoning','tsp');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,4,'piece'),(r_id,v2,2,'tbsp'),(r_id,v3,1,'piece'),(r_id,v4,2,'tbsp'),
    (r_id,v5,0.5,'tsp'),(r_id,v6,0.25,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Sauté diced onion in oil 3 min','{"action":"saute","item":"onion","minutes":3}'),
    (r_id,2,'Add tomato paste and 1/2 cup water, simmer 5 min','{"action":"simmer","item":"sauce","minutes":5}'),
    (r_id,3,'Crack eggs into sauce, stir gently until just set','{"action":"cook","item":"eggs","minutes":3}'),
    (r_id,4,'Season, serve with bread','{"action":"plate","items":"menemen,bread"}');

  -- ── R63: Korean Bibimbap ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Bibimbap','Korean mixed rice bowl with vegetables and egg','Korean',2,15,10,2,ARRAY['korean','rice','healthy'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Rice','grain','cup'); v2:=_ensure_ing('Egg','protein','piece');
  v3:=_ensure_ing('Carrot','vegetable','piece'); v4:=_ensure_ing('Bean Sprouts','vegetable','cup');
  v5:=_ensure_ing('Soy Sauce','condiment','tbsp'); v6:=_ensure_ing('Cooking Oil','oil','tbsp');
  v7:=_ensure_ing('Garlic','vegetable','clove');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,2,'cup'),(r_id,v2,2,'piece'),(r_id,v3,1,'piece'),(r_id,v4,1,'cup'),
    (r_id,v5,3,'tbsp'),(r_id,v6,2,'tbsp'),(r_id,v7,2,'clove');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Cook rice','{"action":"cook","item":"rice","minutes":20}'),
    (r_id,2,'Julienne carrot, blanch bean sprouts 1 min','{"action":"prep","item":"carrot,sprouts"}'),
    (r_id,3,'Season each veggie with garlic, soy sauce, oil','{"action":"season","item":"vegetables"}'),
    (r_id,4,'Fry egg sunny-side up','{"action":"fry","item":"egg","style":"sunny_side_up"}'),
    (r_id,5,'Arrange rice, veggies, egg in bowl, drizzle soy sauce','{"action":"plate","items":"rice,vegetables,egg,sauce"}');

  -- ── R64: Shakshuka ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Shakshuka','Middle Eastern eggs poached in spiced tomato sauce','Middle Eastern',2,5,15,2,ARRAY['middle-eastern','egg','breakfast','spicy'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Egg','protein','piece'); v2:=_ensure_ing('Tomato Paste','condiment','tbsp');
  v3:=_ensure_ing('Onion','vegetable','piece'); v4:=_ensure_ing('Garlic','vegetable','clove');
  v5:=_ensure_ing('Cooking Oil','oil','tbsp'); v6:=_ensure_ing('Salt','seasoning','tsp');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,4,'piece'),(r_id,v2,3,'tbsp'),(r_id,v3,1,'piece'),(r_id,v4,3,'clove'),
    (r_id,v5,2,'tbsp'),(r_id,v6,1,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Sauté onion and garlic in oil','{"action":"saute","item":"onion,garlic","minutes":3}'),
    (r_id,2,'Add tomato paste and 1 cup water, simmer 5 min','{"action":"simmer","item":"sauce","minutes":5}'),
    (r_id,3,'Make wells, crack in eggs, cover, cook 5-7 min','{"action":"poach","item":"eggs","minutes":6}'),
    (r_id,4,'Serve in the pan with crusty bread','{"action":"plate","items":"shakshuka,bread"}');

  -- ── R65: British Fish and Chips ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Fish and Chips','Classic British beer-battered fish with chunky fries','British',3,15,20,2,ARRAY['british','seafood','fried'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('White Fish Fillet','seafood','g'); v2:=_ensure_ing('Potato','vegetable','piece');
  v3:=_ensure_ing('Flour','baking','cup'); v4:=_ensure_ing('Cooking Oil','oil','ml');
  v5:=_ensure_ing('Salt','seasoning','tsp'); v6:=_ensure_ing('Baking Soda','baking','tsp');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,400,'g'),(r_id,v2,4,'piece'),(r_id,v3,1,'cup'),(r_id,v4,500,'ml'),
    (r_id,v5,1,'tsp'),(r_id,v6,0.5,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Cut potatoes into thick chips, soak in water 30 min','{"action":"chop","item":"potato","size":"thick_chips"}'),
    (r_id,2,'Make batter: flour, baking soda, salt, cold water','{"action":"mix","item":"batter"}'),
    (r_id,3,'Heat oil to 180°C, fry chips 5 min, drain','{"action":"fry","item":"chips","minutes":5}'),
    (r_id,4,'Dip fish in batter, fry 4-5 min until golden','{"action":"fry","item":"fish","minutes":5}'),
    (r_id,5,'Re-fry chips 2 min for extra crispness','{"action":"fry","item":"chips","minutes":2}');

  -- ── R66: Carbonara ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Spaghetti Carbonara','Classic Roman pasta with egg and pepper','Italian',2,5,15,2,ARRAY['italian','pasta','quick'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Pasta','grain','g'); v2:=_ensure_ing('Egg','protein','piece');
  v3:=_ensure_ing('Black Pepper','seasoning','tsp'); v4:=_ensure_ing('Salt','seasoning','tsp');
  v5:=_ensure_ing('Cooking Oil','oil','tbsp');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,300,'g'),(r_id,v2,3,'piece'),(r_id,v3,1,'tsp'),(r_id,v4,1,'tsp'),(r_id,v5,1,'tbsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Cook pasta in well-salted water until al dente','{"action":"boil","item":"pasta","minutes":10}'),
    (r_id,2,'Mix egg yolks, 1 whole egg, plenty of pepper','{"action":"whisk","item":"egg,pepper"}'),
    (r_id,3,'Drain pasta, save 1 cup pasta water','{"action":"drain","item":"pasta"}'),
    (r_id,4,'Toss hot pasta with egg mixture OFF heat, add pasta water to thin','{"action":"toss","item":"pasta,egg_sauce"}');

  -- ── R67: Kimchi Fried Rice ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Kimchi Fried Rice','Quick Korean fried rice with egg','Korean',1,3,8,1,ARRAY['korean','rice','quick','spicy'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Rice','grain','cup'); v2:=_ensure_ing('Egg','protein','piece');
  v3:=_ensure_ing('Soy Sauce','condiment','tbsp'); v4:=_ensure_ing('Cooking Oil','oil','tbsp');
  v5:=_ensure_ing('Onion','vegetable','piece');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,2,'cup'),(r_id,v2,1,'piece'),(r_id,v3,1,'tbsp'),(r_id,v4,2,'tbsp'),(r_id,v5,0.25,'piece');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Stir-fry diced onion in oil 1 min','{"action":"stir_fry","item":"onion","minutes":1}'),
    (r_id,2,'Add cold rice, stir-fry 3 min','{"action":"stir_fry","item":"rice","minutes":3}'),
    (r_id,3,'Add soy sauce, toss 1 min','{"action":"toss","item":"rice,soy","minutes":1}'),
    (r_id,4,'Top with fried egg','{"action":"fry","item":"egg","style":"sunny_side_up"}');

  -- ── R68: Vietnamese Pho ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Vietnamese Pho','Fragrant beef noodle soup','Vietnamese',3,10,40,4,ARRAY['vietnamese','soup','beef','noodles'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Beef','protein','g'); v2:=_ensure_ing('Rice Noodles','grain','g');
  v3:=_ensure_ing('Onion','vegetable','piece'); v4:=_ensure_ing('Garlic','vegetable','clove');
  v5:=_ensure_ing('Soy Sauce','condiment','tbsp'); v6:=_ensure_ing('Salt','seasoning','tsp');
  v7:=_ensure_ing('Bean Sprouts','vegetable','cup');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,300,'g'),(r_id,v2,200,'g'),(r_id,v3,1,'piece'),(r_id,v4,3,'clove'),
    (r_id,v5,2,'tbsp'),(r_id,v6,1,'tsp'),(r_id,v7,1,'cup');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Char halved onion under broiler until black spots appear','{"action":"char","item":"onion","minutes":5}'),
    (r_id,2,'Simmer beef, charred onion, garlic in 6 cups water 30 min','{"action":"simmer","item":"beef,onion,garlic","minutes":30}'),
    (r_id,3,'Remove beef, slice thin, strain and season broth','{"action":"slice","item":"beef","size":"thin"}'),
    (r_id,4,'Cook noodles separately, drain','{"action":"boil","item":"noodles","minutes":3}'),
    (r_id,5,'Assemble: noodles, sliced beef, hot broth, top with bean sprouts','{"action":"plate","items":"noodles,beef,broth,sprouts"}');

  -- ── R69: Falafel ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Falafel','Crispy Middle Eastern chickpea fritters','Middle Eastern',2,15,10,4,ARRAY['middle-eastern','legume','fried','vegetarian'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Beans','legume','cup'); v2:=_ensure_ing('Onion','vegetable','piece');
  v3:=_ensure_ing('Garlic','vegetable','clove'); v4:=_ensure_ing('Flour','baking','tbsp');
  v5:=_ensure_ing('Cooking Oil','oil','ml'); v6:=_ensure_ing('Salt','seasoning','tsp');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,2,'cup'),(r_id,v2,0.5,'piece'),(r_id,v3,3,'clove'),(r_id,v4,2,'tbsp'),
    (r_id,v5,200,'ml'),(r_id,v6,1,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Blend beans, onion, garlic, salt into coarse paste','{"action":"blend","item":"beans,onion,garlic"}'),
    (r_id,2,'Mix in flour, shape into small patties','{"action":"shape","item":"falafel","count":12}'),
    (r_id,3,'Deep fry in hot oil 3-4 min until golden','{"action":"fry","item":"falafel","minutes":4}'),
    (r_id,4,'Serve in bread with sauce','{"action":"plate","items":"falafel,bread"}');

  -- ── R70: Chicken Teriyaki ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Chicken Teriyaki','Glazed Japanese teriyaki chicken','Japanese',2,5,15,2,ARRAY['japanese','chicken','quick'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Chicken','protein','g'); v2:=_ensure_ing('Soy Sauce','condiment','tbsp');
  v3:=_ensure_ing('Sugar','baking','tbsp'); v4:=_ensure_ing('Cooking Oil','oil','tbsp');
  v5:=_ensure_ing('Garlic','vegetable','clove'); v6:=_ensure_ing('Rice','grain','cup');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,400,'g'),(r_id,v2,4,'tbsp'),(r_id,v3,2,'tbsp'),(r_id,v4,1,'tbsp'),
    (r_id,v5,2,'clove'),(r_id,v6,2,'cup');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Cook rice','{"action":"cook","item":"rice","minutes":20}'),
    (r_id,2,'Pan fry chicken in oil until golden, 6 min','{"action":"fry","item":"chicken","minutes":6}'),
    (r_id,3,'Mix soy sauce, sugar, minced garlic, 2 tbsp water','{"action":"mix","item":"teriyaki_sauce"}'),
    (r_id,4,'Pour sauce over chicken, simmer until sticky glaze forms','{"action":"glaze","item":"chicken","minutes":3}'),
    (r_id,5,'Slice chicken, serve over rice','{"action":"plate","items":"rice,chicken"}');

  -- ── R71: Hummus ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Hummus','Creamy Middle Eastern chickpea dip','Middle Eastern',1,10,0,4,ARRAY['middle-eastern','legume','no-cook','appetizer'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Beans','legume','cup'); v2:=_ensure_ing('Garlic','vegetable','clove');
  v3:=_ensure_ing('Cooking Oil','oil','tbsp'); v4:=_ensure_ing('Salt','seasoning','tsp');
  v5:=_ensure_ing('Lemon','fruit','piece');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,1.5,'cup'),(r_id,v2,2,'clove'),(r_id,v3,3,'tbsp'),(r_id,v4,0.5,'tsp'),(r_id,v5,0.5,'piece');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Drain and rinse beans','{"action":"wash","item":"beans"}'),
    (r_id,2,'Blend beans, garlic, lemon juice, oil, salt until smooth','{"action":"blend","item":"beans,garlic,lemon,oil,salt"}'),
    (r_id,3,'Adjust consistency with water, drizzle oil on top','{"action":"garnish","item":"oil"}');

  -- ── R72: Beef Stroganoff ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Beef Stroganoff','Creamy Russian beef with mushroom sauce','Russian',3,10,20,3,ARRAY['russian','beef','pasta'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Beef','protein','g'); v2:=_ensure_ing('Mushroom','vegetable','g');
  v3:=_ensure_ing('Onion','vegetable','piece'); v4:=_ensure_ing('Butter','dairy','g');
  v5:=_ensure_ing('Flour','baking','tbsp'); v6:=_ensure_ing('Milk','dairy','ml');
  v7:=_ensure_ing('Salt','seasoning','tsp'); v8:=_ensure_ing('Black Pepper','seasoning','tsp');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,400,'g'),(r_id,v2,200,'g'),(r_id,v3,1,'piece'),(r_id,v4,30,'g'),
    (r_id,v5,1,'tbsp'),(r_id,v6,150,'ml'),(r_id,v7,1,'tsp'),(r_id,v8,0.5,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Slice beef into thin strips','{"action":"slice","item":"beef","size":"thin_strips"}'),
    (r_id,2,'Sear beef in butter over high heat 3 min, set aside','{"action":"sear","item":"beef","minutes":3}'),
    (r_id,3,'Sauté mushrooms and diced onion 5 min','{"action":"saute","item":"mushroom,onion","minutes":5}'),
    (r_id,4,'Sprinkle flour, stir, add milk for creamy sauce','{"action":"whisk","item":"flour,milk"}'),
    (r_id,5,'Return beef, simmer 5 min, season','{"action":"simmer","item":"beef,sauce","minutes":5}');

  -- ── R73: Banana Bread ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Banana Bread','Moist, sweet banana quick bread','American',2,10,50,8,ARRAY['baking','dessert','breakfast'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Banana','fruit','piece'); v2:=_ensure_ing('Flour','baking','cup');
  v3:=_ensure_ing('Egg','protein','piece'); v4:=_ensure_ing('Sugar','baking','cup');
  v5:=_ensure_ing('Butter','dairy','g'); v6:=_ensure_ing('Baking Soda','baking','tsp');
  v7:=_ensure_ing('Salt','seasoning','tsp');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,3,'piece'),(r_id,v2,1.5,'cup'),(r_id,v3,1,'piece'),(r_id,v4,0.5,'cup'),
    (r_id,v5,60,'g'),(r_id,v6,1,'tsp'),(r_id,v7,0.25,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Preheat oven to 175°C, grease loaf pan','{"action":"preheat","temp_c":175}'),
    (r_id,2,'Mash bananas with a fork','{"action":"mash","item":"banana"}'),
    (r_id,3,'Mix melted butter, sugar, egg, mashed banana','{"action":"mix","item":"wet_ingredients"}'),
    (r_id,4,'Fold in flour, baking soda, salt','{"action":"fold","item":"dry_ingredients"}'),
    (r_id,5,'Pour into pan, bake 45-50 min','{"action":"bake","minutes":48}');

  -- ── R74: Chicken Caesar Salad ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Chicken Caesar Salad','Classic Caesar with grilled chicken','American',2,10,10,2,ARRAY['salad','chicken','healthy','quick'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Chicken','protein','g'); v2:=_ensure_ing('Lettuce','vegetable','piece');
  v3:=_ensure_ing('Bread','grain','slice'); v4:=_ensure_ing('Garlic','vegetable','clove');
  v5:=_ensure_ing('Cooking Oil','oil','tbsp'); v6:=_ensure_ing('Egg','protein','piece');
  v7:=_ensure_ing('Salt','seasoning','tsp'); v8:=_ensure_ing('Lemon','fruit','piece');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,250,'g'),(r_id,v2,1,'piece'),(r_id,v3,2,'slice'),(r_id,v4,1,'clove'),
    (r_id,v5,3,'tbsp'),(r_id,v6,1,'piece'),(r_id,v7,0.5,'tsp'),(r_id,v8,0.5,'piece');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Season chicken, pan-fry until done, slice','{"action":"fry","item":"chicken","minutes":8}'),
    (r_id,2,'Cube bread, toast in oil with garlic for croutons','{"action":"toast","item":"bread,garlic","minutes":3}'),
    (r_id,3,'Make dressing: egg yolk, oil, lemon juice, garlic, salt','{"action":"whisk","item":"dressing"}'),
    (r_id,4,'Tear lettuce, toss with dressing, top with chicken and croutons','{"action":"toss","item":"salad,dressing,chicken,croutons"}');

  -- ── R75: Chocolate Mug Cake ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Chocolate Mug Cake','Single-serve microwave cake in 5 minutes','Western',1,3,2,1,ARRAY['dessert','quick','baking'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Flour','baking','tbsp'); v2:=_ensure_ing('Sugar','baking','tbsp');
  v3:=_ensure_ing('Coffee','beverage','tsp'); v4:=_ensure_ing('Egg','protein','piece');
  v5:=_ensure_ing('Milk','dairy','tbsp'); v6:=_ensure_ing('Cooking Oil','oil','tbsp');
  v7:=_ensure_ing('Baking Soda','baking','tsp');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,4,'tbsp'),(r_id,v2,3,'tbsp'),(r_id,v3,1,'tsp'),(r_id,v4,1,'piece'),
    (r_id,v5,3,'tbsp'),(r_id,v6,2,'tbsp'),(r_id,v7,0.25,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Mix flour, sugar, coffee, baking soda in a mug','{"action":"mix","item":"dry_ingredients"}'),
    (r_id,2,'Add egg, milk, oil, stir until smooth','{"action":"stir","item":"batter"}'),
    (r_id,3,'Microwave on high 90 seconds','{"action":"microwave","minutes":1.5}');

END $$;

-- Cleanup
DROP FUNCTION IF EXISTS _ensure_ing(TEXT,TEXT,TEXT);
