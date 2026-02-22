# Section 1: The "Machine-Readable" Data Schema (Supabase)

> **Design Principle:** Every table must be queryable by a human *and* parseable by a robot. No prose-only fields for operational data.

---

## 1.1 Entity-Relationship Overview

```
users ──┬── inventory_items ──── ingredients (canonical)
        │         │
        │         └── vision_corrections
        │
        ├── user_flavor_profile
        ├── user_recipe_history
        ├── gamification_stats
        │
        └── recipes ──┬── recipe_ingredients
                      └── recipe_steps (JSONB: RobotAction[])
```

---

## 1.2 Full SQL Schema

### `users` — Core User Profile

```sql
CREATE TABLE public.users (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email           TEXT UNIQUE NOT NULL,
    display_name    TEXT NOT NULL DEFAULT 'Chef',
    avatar_url      TEXT,
    dietary_tags    TEXT[] DEFAULT '{}',       -- e.g. {'vegetarian','gluten-free'}
    household_size  SMALLINT DEFAULT 1,
    onboarding_done BOOLEAN DEFAULT FALSE,
    created_at      TIMESTAMPTZ DEFAULT now(),
    updated_at      TIMESTAMPTZ DEFAULT now()
);

-- RLS: Users can only read/write their own row.
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
CREATE POLICY "users_self" ON public.users
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);
```

---

### `ingredients` — Canonical Ingredient Dictionary

> A normalized, system-managed table. Users never write here directly. This is the "vocabulary" the robot speaks.

```sql
CREATE TABLE public.ingredients (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    canonical_name      TEXT UNIQUE NOT NULL,          -- 'fuji_apple'
    display_name_en     TEXT NOT NULL,                  -- 'Fuji Apple'
    display_name_ko     TEXT,                           -- '후지 사과'
    category            TEXT NOT NULL,                  -- 'fruit', 'dairy', 'protein'
    sub_category        TEXT,                           -- 'citrus', 'leafy_green'
    default_unit        TEXT NOT NULL DEFAULT 'piece',  -- 'piece','ml','g','bunch'
    sealed_shelf_life_days  INT,                        -- days when sealed/whole
    opened_shelf_life_days  INT,                        -- days once opened/cut
    avg_weight_grams    NUMERIC(8,2),                   -- for robot portioning
    clarifai_concept_ids TEXT[] DEFAULT '{}',           -- mapped Clarifai concept IDs
    is_allergen         BOOLEAN DEFAULT FALSE,
    allergen_group      TEXT,                           -- 'nuts','dairy','gluten'
    storage_zone        TEXT DEFAULT 'fridge',          -- 'fridge','freezer','pantry'
    created_at          TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_ingredients_category ON public.ingredients(category);
CREATE INDEX idx_ingredients_canonical ON public.ingredients(canonical_name);
```

---

### `inventory_items` — The Digital Twin (Dynamic State)

> **Key Design Decision:** Each physical item is a row. An opened and a sealed carton of milk are **two separate rows** with different `item_state` values and computed expiry dates.

```sql
CREATE TYPE item_state AS ENUM ('sealed', 'opened', 'partially_used', 'frozen', 'thawed');

CREATE TABLE public.inventory_items (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    ingredient_id       UUID NOT NULL REFERENCES public.ingredients(id),
    
    -- Quantity & Measurement
    quantity            NUMERIC(10,2) NOT NULL DEFAULT 1,
    unit                TEXT NOT NULL DEFAULT 'piece',  -- inherits from ingredient but overridable
    
    -- Dynamic State Management
    item_state          item_state NOT NULL DEFAULT 'sealed',
    state_changed_at    TIMESTAMPTZ,                    -- when was it opened/frozen?
    
    -- Expiry Tracking
    purchase_date       DATE DEFAULT CURRENT_DATE,
    manual_expiry_date  DATE,                           -- user-entered "best before"
    computed_expiry     DATE GENERATED ALWAYS AS (
        CASE 
            WHEN manual_expiry_date IS NOT NULL THEN manual_expiry_date
            ELSE NULL  -- fallback computed in application layer (see note below)
        END
    ) STORED,
    
    -- Provenance
    source              TEXT DEFAULT 'manual',          -- 'manual','camera','barcode','receipt'
    confidence_score    NUMERIC(3,2),                   -- 0.00–1.00 from vision pipeline
    location            TEXT DEFAULT 'fridge',          -- 'fridge','freezer','pantry','counter'
    notes               TEXT,
    
    created_at          TIMESTAMPTZ DEFAULT now(),
    updated_at          TIMESTAMPTZ DEFAULT now()
);

-- Performance indexes
CREATE INDEX idx_inventory_user ON public.inventory_items(user_id);
CREATE INDEX idx_inventory_expiry ON public.inventory_items(user_id, computed_expiry);
CREATE INDEX idx_inventory_ingredient ON public.inventory_items(ingredient_id);

-- RLS
ALTER TABLE public.inventory_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "inventory_owner" ON public.inventory_items
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);
```

> **Note on `computed_expiry`:** PostgreSQL `GENERATED` columns cannot reference other tables. The full expiry logic (which joins `ingredients.sealed_shelf_life_days` and checks `item_state`) runs as a **database function + trigger**:

```sql
CREATE OR REPLACE FUNCTION fn_compute_expiry()
RETURNS TRIGGER AS $$
DECLARE
    v_sealed_days INT;
    v_opened_days INT;
    v_base_date   DATE;
BEGIN
    SELECT sealed_shelf_life_days, opened_shelf_life_days
      INTO v_sealed_days, v_opened_days
      FROM public.ingredients
     WHERE id = NEW.ingredient_id;

    -- If the user set a manual date, respect it.
    IF NEW.manual_expiry_date IS NOT NULL THEN
        RETURN NEW;
    END IF;

    -- Determine base date based on state
    v_base_date := COALESCE(NEW.purchase_date, CURRENT_DATE);
    
    IF NEW.item_state IN ('opened', 'partially_used', 'thawed') THEN
        v_base_date := COALESCE(NEW.state_changed_at::DATE, CURRENT_DATE);
        NEW.computed_expiry := v_base_date + COALESCE(v_opened_days, 3);  -- 3-day safety default
    ELSIF NEW.item_state = 'frozen' THEN
        NEW.computed_expiry := v_base_date + 90;  -- 90-day frozen default
    ELSE
        NEW.computed_expiry := v_base_date + COALESCE(v_sealed_days, 7);  -- 7-day safety default
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_compute_expiry
    BEFORE INSERT OR UPDATE ON public.inventory_items
    FOR EACH ROW EXECUTE FUNCTION fn_compute_expiry();
```

---

### `recipes` — Robot-Ready Recipe Definitions

```sql
CREATE TABLE public.recipes (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title               TEXT NOT NULL,
    description         TEXT,
    cuisine             TEXT,                           -- 'korean','italian','mexican'
    difficulty          SMALLINT CHECK (difficulty BETWEEN 1 AND 5),
    prep_time_minutes   INT,
    cook_time_minutes   INT,
    servings            SMALLINT DEFAULT 2,
    image_url           TEXT,
    tags                TEXT[] DEFAULT '{}',            -- {'quick','comfort','spicy'}
    flavor_vectors      JSONB DEFAULT '{}',            -- {"sweet":0.3,"salty":0.7,"umami":0.9}
    is_community        BOOLEAN DEFAULT FALSE,
    author_id           UUID REFERENCES public.users(id),
    created_at          TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_recipes_tags ON public.recipes USING GIN(tags);
CREATE INDEX idx_recipes_flavor ON public.recipes USING GIN(flavor_vectors);
```

### `recipe_ingredients` — Normalized Ingredient Requirements

```sql
CREATE TABLE public.recipe_ingredients (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    recipe_id       UUID NOT NULL REFERENCES public.recipes(id) ON DELETE CASCADE,
    ingredient_id   UUID NOT NULL REFERENCES public.ingredients(id),
    quantity        NUMERIC(10,2) NOT NULL,
    unit            TEXT NOT NULL,
    is_optional     BOOLEAN DEFAULT FALSE,
    prep_note       TEXT                              -- 'diced','room temperature'
);

CREATE INDEX idx_ri_recipe ON public.recipe_ingredients(recipe_id);
CREATE INDEX idx_ri_ingredient ON public.recipe_ingredients(ingredient_id);
```

### `recipe_steps` — Structured, Machine-Parseable Instructions

> **This is the crown jewel.** Each step is a JSONB `RobotAction` object.

```sql
CREATE TABLE public.recipe_steps (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    recipe_id       UUID NOT NULL REFERENCES public.recipes(id) ON DELETE CASCADE,
    step_number     SMALLINT NOT NULL,
    
    -- Human-readable
    human_text      TEXT NOT NULL,                     -- "Julienne the carrots into thin strips"
    
    -- Machine-readable (RobotAction schema)
    robot_action    JSONB NOT NULL,
    /*
    {
        "action": "CUT",                         -- verb from controlled vocabulary
        "target": "carrot",                       -- canonical ingredient name
        "tool": "chef_knife",                     -- required tool
        "parameters": {
            "technique": "julienne",
            "thickness_mm": 3,
            "length_mm": 50
        },
        "duration_seconds": null,                 -- null = not time-based
        "temperature_celsius": null,              -- null = no heat
        "sensor_check": null,                     -- e.g. {"type":"color","value":"golden_brown"}
        "dependencies": [],                       -- step_numbers that must complete first
        "outputs": ["julienned_carrot"]           -- named outputs for subsequent steps
    }
    */
    
    estimated_seconds INT,
    requires_attention BOOLEAN DEFAULT TRUE,       -- can robot do this unattended?
    
    CONSTRAINT uq_recipe_step UNIQUE (recipe_id, step_number)
);

CREATE INDEX idx_steps_recipe ON public.recipe_steps(recipe_id);
```

#### Controlled Action Vocabulary

| Action | Description | Typical Parameters |
|--------|-------------|--------------------|
| `CUT` | Any cutting operation | `technique`, `thickness_mm` |
| `HEAT` | Apply heat (stove/oven) | `method` (sauté, boil, bake), `temperature_celsius` |
| `MIX` | Combine ingredients | `method` (stir, whisk, fold), `speed_rpm` |
| `POUR` | Transfer liquid | `volume_ml`, `rate` (slow, fast) |
| `SEASON` | Add seasoning | `amount_grams`, `method` (sprinkle, rub) |
| `WAIT` | Passive time | `duration_seconds`, `sensor_check` |
| `PLATE` | Final plating | `arrangement`, `garnish` |

---

### `user_recipe_history` — Taste Memory & Tier Classification

```sql
CREATE TABLE public.user_recipe_history (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    recipe_id       UUID NOT NULL REFERENCES public.recipes(id),
    cooked_at       TIMESTAMPTZ DEFAULT now(),
    rating          SMALLINT CHECK (rating BETWEEN 1 AND 5),
    tier_used       SMALLINT CHECK (tier_used BETWEEN 1 AND 5),
    waste_score     NUMERIC(3,2),                     -- 0.00 = no waste, 1.00 = everything wasted
    notes           TEXT
);

CREATE INDEX idx_history_user ON public.user_recipe_history(user_id);
CREATE INDEX idx_history_recipe ON public.user_recipe_history(user_id, recipe_id);
```

### `user_flavor_profile` — Learned Taste Vectors

```sql
CREATE TABLE public.user_flavor_profile (
    user_id         UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
    sweet           NUMERIC(3,2) DEFAULT 0.50,
    salty           NUMERIC(3,2) DEFAULT 0.50,
    sour            NUMERIC(3,2) DEFAULT 0.50,
    bitter          NUMERIC(3,2) DEFAULT 0.50,
    umami           NUMERIC(3,2) DEFAULT 0.50,
    spicy           NUMERIC(3,2) DEFAULT 0.50,
    preferred_cuisines TEXT[] DEFAULT '{}',
    disliked_ingredients UUID[] DEFAULT '{}',          -- references ingredients.id
    updated_at      TIMESTAMPTZ DEFAULT now()
);
```

### `vision_corrections` — Feedback Loop for AI Improvement

```sql
CREATE TABLE public.vision_corrections (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             UUID NOT NULL REFERENCES public.users(id),
    original_prediction TEXT NOT NULL,                  -- what Clarifai said
    corrected_to        UUID REFERENCES public.ingredients(id), -- what user selected
    clarifai_concept_id TEXT,
    confidence          NUMERIC(3,2),
    image_storage_path  TEXT,                           -- Supabase Storage ref
    created_at          TIMESTAMPTZ DEFAULT now()
);
```

### `gamification_stats` — Waste Warrior Tracking

```sql
CREATE TABLE public.gamification_stats (
    user_id             UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
    total_meals_cooked  INT DEFAULT 0,
    tier1_meals         INT DEFAULT 0,                 -- zero-waste meals
    tier2_meals         INT DEFAULT 0,
    items_saved         INT DEFAULT 0,                 -- items used before expiry
    items_wasted        INT DEFAULT 0,                 -- items removed as expired
    current_streak      INT DEFAULT 0,                 -- consecutive days cooking
    longest_streak      INT DEFAULT 0,
    xp_points           INT DEFAULT 0,
    level               SMALLINT DEFAULT 1,
    badges              JSONB DEFAULT '[]',            -- [{"id":"waste_warrior","earned_at":"..."}]
    updated_at          TIMESTAMPTZ DEFAULT now()
);
```

---

*← [Back to Overview](./TDD_00_OVERVIEW.md) | [Section 2: Algorithm →](./TDD_02_ALGORITHM.md)*
