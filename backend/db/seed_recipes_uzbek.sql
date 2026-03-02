-- ============================================================
-- I-Fridge — Seed: Uzbek Recipes — 15 Authentic Dishes
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

  -- ── 1: Plov (Osh) ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Plov (Osh)','The king of Uzbek cuisine — fragrant rice pilaf with lamb, carrots and cumin','Uzbek',3,20,60,6,ARRAY['uzbek','rice','lamb','traditional'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Rice','grain','cup'); v2:=_ensure_ing('Lamb','protein','g');
  v3:=_ensure_ing('Carrot','vegetable','piece'); v4:=_ensure_ing('Onion','vegetable','piece');
  v5:=_ensure_ing('Cooking Oil','oil','ml'); v6:=_ensure_ing('Garlic','vegetable','clove');
  v7:=_ensure_ing('Cumin','seasoning','tsp'); v8:=_ensure_ing('Salt','seasoning','tsp');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,3,'cup'),(r_id,v2,500,'g'),(r_id,v3,4,'piece'),(r_id,v4,3,'piece'),
    (r_id,v5,100,'ml'),(r_id,v6,1,'piece'),(r_id,v7,1,'tsp'),(r_id,v8,2,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Heat oil in a kazan (heavy pot) until smoking hot','{"action":"heat","item":"oil","temp":"high"}'),
    (r_id,2,'Sear lamb pieces until deep golden brown on all sides','{"action":"sear","item":"lamb","minutes":8}'),
    (r_id,3,'Add sliced onions, fry until golden','{"action":"fry","item":"onion","minutes":5}'),
    (r_id,4,'Add julienned carrots, stir-fry 5 min without breaking them','{"action":"stir_fry","item":"carrot","minutes":5}'),
    (r_id,5,'Add cumin, salt, whole garlic head, cover with water 2cm above meat','{"action":"season","item":"cumin,salt,garlic,water"}'),
    (r_id,6,'Simmer zirvak (base) for 30 min until carrots are tender','{"action":"simmer","item":"zirvak","minutes":30}'),
    (r_id,7,'Spread soaked rice evenly on top — do NOT stir. Add water to 1cm above rice','{"action":"layer","item":"rice"}'),
    (r_id,8,'Cook on high until water evaporates, reduce to low, cover tightly for 25 min','{"action":"steam","item":"plov","minutes":25}'),
    (r_id,9,'Gently flip onto large serving dish, garlic on top','{"action":"plate","items":"plov,garlic"}');

  -- ── 2: Mastava ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Mastava','Hearty Uzbek rice soup with vegetables and herbs, served with sour cream','Uzbek',2,15,40,6,ARRAY['uzbek','soup','rice','comfort'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Beef','protein','g'); v2:=_ensure_ing('Rice','grain','cup');
  v3:=_ensure_ing('Potato','vegetable','piece'); v4:=_ensure_ing('Carrot','vegetable','piece');
  v5:=_ensure_ing('Onion','vegetable','piece'); v6:=_ensure_ing('Tomato Paste','condiment','tbsp');
  v7:=_ensure_ing('Garlic','vegetable','clove'); v8:=_ensure_ing('Salt','seasoning','tsp');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,400,'g'),(r_id,v2,0.5,'cup'),(r_id,v3,2,'piece'),(r_id,v4,1,'piece'),
    (r_id,v5,1,'piece'),(r_id,v6,2,'tbsp'),(r_id,v7,3,'clove'),(r_id,v8,1.5,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Cut beef into small cubes, dice potato, carrot, onion','{"action":"chop","item":"beef,potato,carrot,onion"}'),
    (r_id,2,'Sauté onion in oil until golden, add beef, brown 5 min','{"action":"fry","item":"onion,beef","minutes":7}'),
    (r_id,3,'Add carrot, cook 3 min, then add tomato paste','{"action":"stir","item":"carrot,tomato_paste","minutes":3}'),
    (r_id,4,'Add 6 cups water, bring to boil, skim foam','{"action":"boil","item":"water"}'),
    (r_id,5,'Add potatoes and rice, simmer 25 min until rice is soft','{"action":"simmer","item":"potato,rice","minutes":25}'),
    (r_id,6,'Add minced garlic, season with salt and pepper','{"action":"season","item":"garlic,salt"}'),
    (r_id,7,'Serve hot with a spoon of sour cream and fresh herbs','{"action":"plate","items":"mastava,sour_cream,herbs"}');

  -- ── 3: Lagman ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Lagman','Hand-pulled noodle soup with beef and vegetable stew','Uzbek',4,30,25,4,ARRAY['uzbek','noodles','soup','beef'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Beef','protein','g'); v2:=_ensure_ing('Flour','baking','cup');
  v3:=_ensure_ing('Onion','vegetable','piece'); v4:=_ensure_ing('Carrot','vegetable','piece');
  v5:=_ensure_ing('Tomato Paste','condiment','tbsp'); v6:=_ensure_ing('Potato','vegetable','piece');
  v7:=_ensure_ing('Cooking Oil','oil','tbsp'); v8:=_ensure_ing('Salt','seasoning','tsp');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,300,'g'),(r_id,v2,2,'cup'),(r_id,v3,1,'piece'),(r_id,v4,1,'piece'),
    (r_id,v5,3,'tbsp'),(r_id,v6,1,'piece'),(r_id,v7,4,'tbsp'),(r_id,v8,1,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Make dough: flour, salt, water — knead 10 min, rest 30 min covered in oil','{"action":"knead","item":"dough","minutes":10}'),
    (r_id,2,'Roll and stretch dough into thin noodles by hand','{"action":"stretch","item":"noodles"}'),
    (r_id,3,'Cut beef into strips, dice all vegetables','{"action":"chop","item":"beef,onion,carrot,potato"}'),
    (r_id,4,'Fry beef in oil until browned, add onion, cook 3 min','{"action":"fry","item":"beef,onion","minutes":5}'),
    (r_id,5,'Add carrot, potato, tomato paste, stir 3 min','{"action":"stir","item":"vegetables,tomato_paste","minutes":3}'),
    (r_id,6,'Add water, simmer 15 min for the stew (vaj)','{"action":"simmer","item":"stew","minutes":15}'),
    (r_id,7,'Boil noodles separately 3-4 min, drain','{"action":"boil","item":"noodles","minutes":4}'),
    (r_id,8,'Place noodles in bowl, ladle stew on top','{"action":"plate","items":"noodles,stew"}');

  -- ── 4: Shurpa ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Shurpa','Rich Uzbek lamb and vegetable broth soup','Uzbek',2,10,50,6,ARRAY['uzbek','soup','lamb','comfort'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Lamb','protein','g'); v2:=_ensure_ing('Potato','vegetable','piece');
  v3:=_ensure_ing('Carrot','vegetable','piece'); v4:=_ensure_ing('Onion','vegetable','piece');
  v5:=_ensure_ing('Tomato Paste','condiment','tbsp'); v6:=_ensure_ing('Salt','seasoning','tsp');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,500,'g'),(r_id,v2,3,'piece'),(r_id,v3,2,'piece'),(r_id,v4,2,'piece'),
    (r_id,v5,2,'tbsp'),(r_id,v6,1.5,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Place lamb pieces in pot with 8 cups cold water, bring to boil, skim','{"action":"boil","item":"lamb,water"}'),
    (r_id,2,'Simmer 30 min until lamb is tender','{"action":"simmer","item":"lamb","minutes":30}'),
    (r_id,3,'Add large chunks of potato, carrot, onion, tomato paste','{"action":"add","item":"vegetables,tomato_paste"}'),
    (r_id,4,'Simmer 15 more min until vegetables are soft','{"action":"simmer","item":"soup","minutes":15}'),
    (r_id,5,'Season, serve in deep bowls with fresh herbs','{"action":"plate","items":"shurpa,herbs"}');

  -- ── 5: Manti ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Manti','Large steamed dumplings filled with spiced lamb and onion','Uzbek',4,40,30,4,ARRAY['uzbek','dumplings','lamb','steamed'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Flour','baking','cup'); v2:=_ensure_ing('Lamb','protein','g');
  v3:=_ensure_ing('Onion','vegetable','piece'); v4:=_ensure_ing('Salt','seasoning','tsp');
  v5:=_ensure_ing('Black Pepper','seasoning','tsp'); v6:=_ensure_ing('Cumin','seasoning','tsp');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,3,'cup'),(r_id,v2,400,'g'),(r_id,v3,3,'piece'),(r_id,v4,1,'tsp'),
    (r_id,v5,0.5,'tsp'),(r_id,v6,0.5,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Make dough: flour, salt, water — knead until smooth, rest 20 min','{"action":"knead","item":"dough","minutes":8}'),
    (r_id,2,'Finely dice lamb and onion (do NOT grind), season with salt, pepper, cumin','{"action":"chop","item":"lamb,onion"}'),
    (r_id,3,'Roll dough thin, cut into 10cm squares','{"action":"roll","item":"dough"}'),
    (r_id,4,'Place filling in center, pinch corners to make boat shape','{"action":"shape","item":"manti","count":20}'),
    (r_id,5,'Steam in a greased mantovarka or steamer for 25-30 min','{"action":"steam","item":"manti","minutes":28}'),
    (r_id,6,'Serve with sour cream or tomato sauce','{"action":"plate","items":"manti,sour_cream"}');

  -- ── 6: Samsa ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Samsa','Flaky baked pastries filled with lamb, onion and cumin','Uzbek',3,30,25,6,ARRAY['uzbek','baking','lamb','pastry'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Flour','baking','cup'); v2:=_ensure_ing('Lamb','protein','g');
  v3:=_ensure_ing('Onion','vegetable','piece'); v4:=_ensure_ing('Butter','dairy','g');
  v5:=_ensure_ing('Salt','seasoning','tsp'); v6:=_ensure_ing('Cumin','seasoning','tsp');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,3,'cup'),(r_id,v2,300,'g'),(r_id,v3,3,'piece'),(r_id,v4,100,'g'),
    (r_id,v5,1,'tsp'),(r_id,v6,1,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Make dough: flour, salt, cold water. Knead and rest 20 min','{"action":"knead","item":"dough","minutes":5}'),
    (r_id,2,'Roll dough thin, spread softened butter, roll into log, slice into rounds','{"action":"roll","item":"dough,butter"}'),
    (r_id,3,'Dice lamb and onion finely, mix with cumin, salt, pepper','{"action":"mix","item":"filling"}'),
    (r_id,4,'Flatten each round, fill with meat mixture, pinch into triangle shape','{"action":"shape","item":"samsa","count":12}'),
    (r_id,5,'Preheat oven to 200°C, bake 20-25 min until golden','{"action":"bake","temp_c":200,"minutes":22}');

  -- ── 7: Chuchvara ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Chuchvara','Tiny Uzbek dumplings in clear broth','Uzbek',3,35,10,4,ARRAY['uzbek','dumplings','soup','beef'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Flour','baking','cup'); v2:=_ensure_ing('Beef','protein','g');
  v3:=_ensure_ing('Onion','vegetable','piece'); v4:=_ensure_ing('Salt','seasoning','tsp');
  v5:=_ensure_ing('Black Pepper','seasoning','tsp'); v6:=_ensure_ing('Egg','protein','piece');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,2,'cup'),(r_id,v2,250,'g'),(r_id,v3,1,'piece'),(r_id,v4,1,'tsp'),
    (r_id,v5,0.5,'tsp'),(r_id,v6,1,'piece');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Make dough: flour, egg, salt, water — knead until elastic, rest 15 min','{"action":"knead","item":"dough","minutes":8}'),
    (r_id,2,'Finely mince beef and onion, season with salt and pepper','{"action":"mince","item":"beef,onion"}'),
    (r_id,3,'Roll dough very thin, cut into 4cm squares','{"action":"roll","item":"dough"}'),
    (r_id,4,'Place small amount of filling, fold into triangle, pinch edges','{"action":"shape","item":"chuchvara","count":40}'),
    (r_id,5,'Boil in salted water or beef broth for 7-8 min','{"action":"boil","item":"chuchvara","minutes":8}'),
    (r_id,6,'Serve in broth with sour cream and herbs','{"action":"plate","items":"chuchvara,broth,sour_cream"}');

  -- ── 8: Norin ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Norin','Cold noodle dish with shredded horse meat or beef','Uzbek',3,20,30,4,ARRAY['uzbek','noodles','beef','cold'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Flour','baking','cup'); v2:=_ensure_ing('Beef','protein','g');
  v3:=_ensure_ing('Onion','vegetable','piece'); v4:=_ensure_ing('Salt','seasoning','tsp');
  v5:=_ensure_ing('Black Pepper','seasoning','tsp');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,2,'cup'),(r_id,v2,400,'g'),(r_id,v3,1,'piece'),(r_id,v4,1,'tsp'),(r_id,v5,0.5,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Boil beef in salted water until very tender, 40 min. Save broth','{"action":"boil","item":"beef","minutes":40}'),
    (r_id,2,'Make dough: flour, salt, water. Knead, rest 20 min','{"action":"knead","item":"dough","minutes":8}'),
    (r_id,3,'Roll dough paper-thin, cut into fine noodles','{"action":"roll","item":"noodles"}'),
    (r_id,4,'Boil noodles in broth 3 min, drain','{"action":"boil","item":"noodles","minutes":3}'),
    (r_id,5,'Shred beef finely by hand, mix with noodles','{"action":"shred","item":"beef"}'),
    (r_id,6,'Top with thin-sliced raw onion, pepper, serve warm or room temp','{"action":"plate","items":"norin,onion"}');

  -- ── 9: Dimlama ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Dimlama','Slow-cooked layered stew — meat and vegetables steamed in own juices','Uzbek',2,15,90,6,ARRAY['uzbek','stew','beef','slow-cook'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Beef','protein','g'); v2:=_ensure_ing('Potato','vegetable','piece');
  v3:=_ensure_ing('Carrot','vegetable','piece'); v4:=_ensure_ing('Onion','vegetable','piece');
  v5:=_ensure_ing('Tomato Paste','condiment','tbsp'); v6:=_ensure_ing('Salt','seasoning','tsp');
  v7:=_ensure_ing('Cooking Oil','oil','tbsp');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,500,'g'),(r_id,v2,4,'piece'),(r_id,v3,2,'piece'),(r_id,v4,2,'piece'),
    (r_id,v5,2,'tbsp'),(r_id,v6,1.5,'tsp'),(r_id,v7,3,'tbsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Layer in heavy pot: oil, then meat, then onion rings, carrot, potato','{"action":"layer","item":"oil,beef,onion,carrot,potato"}'),
    (r_id,2,'Season each layer with salt and tomato paste','{"action":"season","item":"salt,tomato_paste"}'),
    (r_id,3,'Cover tightly (seal lid with dough if needed), cook on lowest heat 90 min','{"action":"steam","item":"dimlama","minutes":90}'),
    (r_id,4,'Do NOT open or stir during cooking — let it steam in its own juices','{"action":"wait","minutes":90}'),
    (r_id,5,'Open, serve all layers together in deep dish','{"action":"plate","items":"dimlama"}');

  -- ── 10: Non (Uzbek Bread) ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Non (Uzbek Flatbread)','Traditional round bread stamped with a pattern, baked in tandoor or oven','Uzbek',2,20,15,4,ARRAY['uzbek','bread','baking','traditional'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Flour','baking','cup'); v2:=_ensure_ing('Sugar','baking','tsp');
  v3:=_ensure_ing('Salt','seasoning','tsp'); v4:=_ensure_ing('Cooking Oil','oil','tbsp');
  v5:=_ensure_ing('Milk','dairy','ml');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,3,'cup'),(r_id,v2,1,'tsp'),(r_id,v3,1,'tsp'),(r_id,v4,2,'tbsp'),(r_id,v5,200,'ml');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Mix flour, salt, sugar. Add warm milk and oil, knead 10 min','{"action":"knead","item":"dough","minutes":10}'),
    (r_id,2,'Let dough rise 40 min','{"action":"proof","minutes":40}'),
    (r_id,3,'Shape into round flat discs, thinner in center, thicker rim','{"action":"shape","item":"non","count":4}'),
    (r_id,4,'Stamp center with a fork or chekich pattern','{"action":"stamp","item":"non"}'),
    (r_id,5,'Bake at 220°C for 12-15 min until golden','{"action":"bake","temp_c":220,"minutes":13}');

  -- ── 11: Achichuk Salad ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Achichuk Salad','Fresh Uzbek tomato and onion salad — the essential plov companion','Uzbek',1,5,0,4,ARRAY['uzbek','salad','no-cook','quick','vegetarian'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Tomato','vegetable','piece'); v2:=_ensure_ing('Onion','vegetable','piece');
  v3:=_ensure_ing('Salt','seasoning','tsp');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,4,'piece'),(r_id,v2,1,'piece'),(r_id,v3,0.5,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Slice tomatoes into thin half-moons','{"action":"slice","item":"tomato","size":"thin"}'),
    (r_id,2,'Slice onion into very thin rings, soak in cold water 5 min to soften bite','{"action":"soak","item":"onion","minutes":5}'),
    (r_id,3,'Drain onion, toss with tomato, salt. Let sit 5 min for juices to release','{"action":"toss","item":"tomato,onion,salt"}');

  -- ── 12: Narhangi ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Narhangi','Uzbek roasted meat and vegetable casserole','Uzbek',2,15,50,4,ARRAY['uzbek','stew','beef','comfort'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Beef','protein','g'); v2:=_ensure_ing('Potato','vegetable','piece');
  v3:=_ensure_ing('Onion','vegetable','piece'); v4:=_ensure_ing('Tomato Paste','condiment','tbsp');
  v5:=_ensure_ing('Cooking Oil','oil','tbsp'); v6:=_ensure_ing('Salt','seasoning','tsp');
  v7:=_ensure_ing('Cumin','seasoning','tsp');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,400,'g'),(r_id,v2,3,'piece'),(r_id,v3,2,'piece'),(r_id,v4,2,'tbsp'),
    (r_id,v5,3,'tbsp'),(r_id,v6,1,'tsp'),(r_id,v7,0.5,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Brown beef cubes in oil, add sliced onion','{"action":"fry","item":"beef,onion","minutes":8}'),
    (r_id,2,'Add cubed potato, tomato paste, cumin, salt','{"action":"add","item":"potato,tomato_paste,cumin,salt"}'),
    (r_id,3,'Add 1 cup water, cover, simmer 40 min until everything is tender','{"action":"simmer","item":"narhangi","minutes":40}'),
    (r_id,4,'Serve in the pot or deep dish','{"action":"plate","items":"narhangi"}');

  -- ── 13: Qozon Kabob ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Qozon Kabob','Pot-roasted lamb ribs with potatoes','Uzbek',2,10,55,4,ARRAY['uzbek','lamb','roasted','comfort'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Lamb','protein','g'); v2:=_ensure_ing('Potato','vegetable','piece');
  v3:=_ensure_ing('Onion','vegetable','piece'); v4:=_ensure_ing('Cooking Oil','oil','tbsp');
  v5:=_ensure_ing('Salt','seasoning','tsp'); v6:=_ensure_ing('Cumin','seasoning','tsp');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,600,'g'),(r_id,v2,4,'piece'),(r_id,v3,2,'piece'),(r_id,v4,4,'tbsp'),
    (r_id,v5,1.5,'tsp'),(r_id,v6,0.5,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Sear lamb ribs in hot oil until dark golden','{"action":"sear","item":"lamb","minutes":6}'),
    (r_id,2,'Add onion rings on top, then halved potatoes','{"action":"layer","item":"onion,potato"}'),
    (r_id,3,'Season with salt and cumin, add 1/2 cup water','{"action":"season","item":"salt,cumin,water"}'),
    (r_id,4,'Cover tightly, cook on low heat 45 min','{"action":"braise","item":"kabob","minutes":45}'),
    (r_id,5,'Serve inverted so crispy lamb is on top','{"action":"plate","items":"lamb,potato,onion"}');

  -- ── 14: Suzma Oshi (Yogurt Soup) ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Suzma Oshi','Light Uzbek yogurt and rice soup','Uzbek',1,5,20,3,ARRAY['uzbek','soup','rice','light'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Rice','grain','cup'); v2:=_ensure_ing('Milk','dairy','ml');
  v3:=_ensure_ing('Onion','vegetable','piece'); v4:=_ensure_ing('Butter','dairy','g');
  v5:=_ensure_ing('Salt','seasoning','tsp');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,0.5,'cup'),(r_id,v2,300,'ml'),(r_id,v3,1,'piece'),(r_id,v4,20,'g'),(r_id,v5,0.5,'tsp');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Sauté diced onion in butter until soft','{"action":"saute","item":"onion","minutes":3}'),
    (r_id,2,'Add 3 cups water and rice, simmer 15 min','{"action":"simmer","item":"rice,water","minutes":15}'),
    (r_id,3,'Stir in milk, season with salt, heat through but do not boil','{"action":"stir","item":"milk,salt","minutes":3}'),
    (r_id,4,'Serve warm — optionally top with herbs','{"action":"plate","items":"soup,herbs"}');

  -- ── 15: Halvaitar ──
  INSERT INTO recipes(id,title,description,cuisine,difficulty,prep_time_minutes,cook_time_minutes,servings,tags)
  VALUES(gen_random_uuid(),'Halvaitar','Uzbek flour halva — sweet, rich, made in minutes','Uzbek',1,2,10,6,ARRAY['uzbek','dessert','sweet','quick'])
  RETURNING id INTO r_id;
  v:=_ensure_ing('Flour','baking','cup'); v2:=_ensure_ing('Butter','dairy','g');
  v3:=_ensure_ing('Sugar','baking','cup'); v4:=_ensure_ing('Milk','dairy','ml');
  INSERT INTO recipe_ingredients(recipe_id,ingredient_id,quantity,unit) VALUES
    (r_id,v,1,'cup'),(r_id,v2,100,'g'),(r_id,v3,0.5,'cup'),(r_id,v4,200,'ml');
  INSERT INTO recipe_steps(recipe_id,step_number,human_text,robot_action) VALUES
    (r_id,1,'Melt butter, add flour, stir constantly on medium heat until golden and nutty, 6-7 min','{"action":"toast","item":"butter,flour","minutes":7}'),
    (r_id,2,'Separately, heat milk and dissolve sugar in it','{"action":"dissolve","item":"sugar,milk"}'),
    (r_id,3,'Carefully pour sweet milk into flour mixture, stir rapidly — it will thicken instantly','{"action":"stir","item":"halva","minutes":2}'),
    (r_id,4,'Press into mold or plate, let cool slightly, serve warm','{"action":"plate","items":"halvaitar"}');

END $$;

DROP FUNCTION IF EXISTS _ensure_ing(TEXT,TEXT,TEXT);
