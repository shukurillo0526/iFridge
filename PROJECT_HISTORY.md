# I-Fridge: Project History & Vision Alignment

This document tracks the development history of **I-Fridge**—an ambitious smart-kitchen ecosystem capable of tracking physical inventory and recommending hyper-personalized recipes.

## 🌟 The Core Vision & Pivot

Originally conceived with robotic hardware integrations in mind, I-Fridge has **pivoted to focus entirely on a premium consumer app experience**. We realized that before automating physical cooking, the core user experience of managing ingredients and finding the perfect recipe needs to be flawlessly executed.

The master plan for I-Fridge encompasses:
1. **Living Shelf:** A digital representation of a real shelf/fridge showing available ingredients with freshness tracking.
2. **Social-Style Recommendations:** Replacing clinical filters with engaging feeds (For You, Use It Up, Explore) powered by intelligent match algorithms.
3. **Frictionless Ingestion:** Making it incredibly easy to add items via parsing grocery receipts and analyzing photos of loose ingredients using AI Vision.
4. **Human-First Cooking:** Providing distraction-free, interactive step-by-step tutorials with inline timers and contextual guidance.

---

## 🏗️ What We Have Built (The Consumer Pivot - Phases 1-7)

We have successfully completed the 7-phase consumer pivot, resulting in a polished, AI-powered MVP that is fully deployed as a responsive Web Application via GitHub Pages.

### Phase 1: Existing UI/UX Polish & Functional Fixes
- Audited all current screens (Shelf, Scan, Cook, Profile).
- Removed dead-end settings and broken placeholders to ensure a clean, functional UI.
- Enhanced empty states and loading indicators using Shimmer skeleton screens.

### Phase 2: Ingredient Adding & Expiry Intelligence
- **Advanced Manual Entry:** Upgraded the Scan screen's manual entry with a highly-responsive Supabase **Autocomplete** functionality. Upon selecting a Google-like suggestion, it automatically infers category and metric type.
- **Smart Expiry Engine:** Implemented a robust offline fallback system that algorithmically assigns Estimated Expiry Dates based purely on the selected ingredient category natively in Dart.
- **OCR Receipt Parsing:** Built a FastAPI backend integrating Google Gemini 1.5 Flash. Tuned the prompt specifically for complex Korean grocery receipts (e.g., 진안식자재마트), successfully extracting items, sizes, origin markers, and tax-exempt tags.
- **Direct Photo Scan Logic:** Completely separated the UI logic so receipt parsing and direct photo ingredient detection (loose items on a counter) use dedicated APIs, eliminating cross-contamination of display metrics.

### Phase 3: Social-Style Recommendation Algorithm
- Rebranded the rigid 5-tier matching system into engaging social-style feeds:
  - **Perfect Match** (✅ Everything you need!)
  - **For You** (🔥 Recommended for you)
  - **Use It Up** (⏰ Use expiring items)
  - **Almost** (🛒 Just a few items away)
  - **Explore** (🌍 Discover something new)
- Added contextual recommendation badges to recipe cards.

### Phase 4: Data Pipeline & Knowledge Base
- Developed an ETL pipeline (`etl_foodcom.py`) to flawlessly map large-scale recipe datasets into the strict Supabase schema.
- Structured barcode lookup routers for automated Open Food Facts enrichment.

### Phase 5: Direct Photo Ingredient Detection
- Created a new `/api/v1/vision/detect-ingredients` FastAPI endpoint.
- Tuned a Gemini Vision prompt to analyze photos of loose ingredients on a counter, estimating name, quantity, category, confidence, and visual *freshness*.

### Phase 6: Human-First "Cook Mode" Tutorial
- **Removed Robot Actions:** Stripped out all legacy robot chef JSON payloads and terminology.
- **Interactive UI:** Redesigned `CookingRunScreen` into a swipeable, step-by-step tutorial.
- Added contextual cooking icons based on step text (e.g., 🔥 for heat, ✂️ for cut, 🍳 for fry).
- Built **inline interactive timers** that users can tap to start directly within the instructions.
- Added automated "Needs Your Attention" flags for manual steps.

### Phase 7: Polish, Verification & Final Delivery
- Executed strict linting (`flutter analyze`) ensuring zero errors.
- Fully documented the architecture and implementation in a comprehensive project walkthrough.
- Tuned the AI pipeline using real-world user receipt test data.

---

## 🧠 Phase 8-11: Local AI Integration (Free & Offline)

Following the consumer pivot, we replaced expensive cloud AI services with local models running entirely on consumer hardware (GTX 1650 Ti).

### Phase 8: Local Ollama Backend
- **Unified Service Layer:** Created `ollama_service.py` using `/api/chat` and `/api/embed` with auto-model resolution.
- **Model Fallbacks:** Rewired receipt and photo vision to use local `moondream`, gracefully falling back to Gemini or Mock.
- **Prompt Engineering:** Solved `qwen3:8b`'s `<think>` tag empty responses via strict `/no_think` directives and output stripping.
- **New AI Capabilities:** Added endpoints for recipe generation (`generate-recipe`), ingredient swaps (`substitute`), and step-by-step help (`cooking-tip`).

### Phase 9: Flutter AI Wiring
- Added a **"💡 Ask AI for a tip"** button inside the cooking tutorial that dynamically fetches advice from the local LLM.
- Hooked up an **"AI Generate"** recipe prompt in the Cook screen that reads user inventory from Supabase and streams back a custom recipe.

### Phase 10: Vector Search & Embeddings
- Integrated `nomic-embed-text` to generate embeddings for recipes and user cooking histories.
- Implemented `/api/v1/ai/semantic-search` and `/api/v1/ai/personalize` using cosine similarity ranking to personalize the "For You" feed.

### Phase 11: Smart Search
- Added an AI-powered Search overlay in the Cook screen (`_RecipeSearchDelegate`).
- Enables fuzzy semantic-style filtering across all recommended recipes natively in Flutter.

---

## 🚀 Phase 12-13: Deployment & Branding (Complete)

### Phase 12: Application Branding
- Explicitly standardized the application name exactly as **"iFridge"**.
- Generated a custom, ultra-premium 1:1 squircle iOS app icon featuring a glassmorphic 3D rendering of a refrigerator holding vibrant fruits.
- Spliced, cropped, and embedded this custom icon into the `manifest.json` as `Icon-192`, `Icon-512`, and `favicon.png`.

### Phase 13: GitHub Monorepo & CI/CD
- Demolished fractured sub-git folders and consolidated both Flutter Front-end and FastAPI Back-end into a single **Monorepo**.
- Programmed a `flutter_web_deploy.yml` GitHub Actions Workflow to autonomously trigger on `main` branch pushes.
- Fixed notorious WASM CanvasKit web-rendering blank screen crashes and Case-Sensitive (`--base-href /iFridge/`) directory routing issues on GitHub Pages.
- Synced the Flutter application directly to the live Railway Production API, cleanly publishing the app to the internet.

---

## 🎨 Phase 14: Page-by-Page UX Overhaul (Complete)

Systematically iterated through each major screen, fixing bugs, adding features, and elevating the visual experience.

### Cook Page
- **AI Recipe Generation:** Added an "AI Generate" feature that reads the user's current shelf inventory from Supabase and streams a custom recipe from the local `qwen2.5:3b` model.
- **Shelf-Only Toggle:** Introduced a switch to constrain AI-generated recipes to only ingredients currently available on the shelf.
- **AI Tips Integration:** Wired "💡 Ask AI for a tip" button in CookingRunScreen to fetch contextual cooking advice from the local LLM.

### Scan Page
- **Two-Stage AI Pipeline:** Completely rewrote the receipt scanning (`ocr_parser.py`) and photo detection (`vision_detect.py`) backends to use a robust two-stage pipeline: `moondream` (vision) describes the image → `qwen2.5:3b` (text LLM) structures the output into JSON.
- **Frontend Data Path Fix:** Corrected the `_captureImage` and `_capturePhoto` functions to unwrap the `data` key from API responses, resolving the "0 items detected" bug.
- **Item Addition Tracking:** Added `_addedIndices` to visually mark items already added with a checkmark and reduced opacity.
- **Bulk Add:** Implemented "Add All to Shelf" button for efficient batch operations.
- **Scan Summary Counter:** Added a counter (e.g., "3 / 12 added") to the results screen.
- **Manual Entry:** Added a location picker (Fridge, Freezer, Pantry) to the manual entry form.
- **RLS Bypass:** Created a new backend endpoint (`/api/v1/inventory/add-item`) using the service role key to bypass Supabase Row Level Security restrictions on the `ingredients` table. All inventory operations (single add, bulk add, manual add, audit accept) now route through this endpoint.

### Audit Screen
- **Category Images:** Integrated `categoryImageUrl()` on audit cards for visual identification.
- **Undo-Reject:** Implemented an undo button with `_undoStack` to recover accidentally rejected items.
- **RLS Fix:** Routed ingredient creation through the new backend API endpoint.

### Profile Page
- **Header Redesign:** Replaced the basic avatar with a `SweepGradient` ring effect, added email subtitle, and made the display name tappable to edit (saves to Supabase `users.display_name`).
- **Animated Stats:** Replaced static stat tiles with `TweenAnimationBuilder` count-up animations and color-coded icon backgrounds (green/teal/orange).
- **Badge Layout Fix:** Used `LayoutBuilder` to constrain badges to 4 per row, preventing overflow on small screens.
- **Account Section:** Added email display, Sign Out (with confirmation dialog — moved from AppBar), and Delete Account (with warning).
- **Settings Section:** Added Language display, Theme indicator, "About iFridge" dialog, and version number.
- **Shopping List Counter:** Title now shows checked vs total count (e.g., "Shopping List (2/5)").
- **Meal Planner Clear:** Long-press the edit icon on any planned meal to remove it from the schedule.

---

## 🗄️ Phase 15: Data Architecture Overhaul (Complete)

Systematically audited and rebuilt the app's data layer for efficiency, consistency, and proper per-user isolation.

### Database Fixes
- **`increment_gamification_stats` RPC:** Was literally empty (0 bytes). Now atomically handles XP increment, level calculation (`floor(sqrt(xp/100))+1`), streak management (consecutive day detection), and stat counters.
- **`get_recommended_recipes` RPC:** Fixed broken reference to non-existent `master_ingredients` → `ingredients`, and `expiry_date` → `computed_expiry`.

### Backend Data API (`v3.2.0`)
- **`user_data.py` Router:** 8 new endpoints — `POST /init` (atomic user profile creation), `GET /{id}/dashboard` (single call replaces 5 parallel queries), `PATCH /profile`, shopping list CRUD, meal plan CRUD.
- **`inventory.py` Expansion:** Added `PATCH /{id}`, `DELETE /{id}`, `POST /consume` (wraps `consume_inventory_item` RPC).
- All writes now route through the backend (service role key), ensuring consistent RLS bypass.

### Frontend Repository Layer
- **`InventoryRepository`:** Centralized read/write/realtime for inventory. Reads via Supabase anon key (RLS), writes via backend API.
- **`UserRepository`:** Dashboard (1 API call → replaces 5 parallel Supabase queries), profile, shopping, meal plan mutations.
- **`ApiService`:** 11 new methods added for all backend endpoints.

### Schema Hardening (`migration_006`)
- Added `updated_at` columns + triggers to `shopping_list` and `meal_plan`.
- Tightened `ingredients` INSERT policy (service role only).
- Added unique constraint on `inventory_items(user_id, ingredient_id, location)` to prevent duplicates.
- Added trigram index on `ingredients.display_name_en` for faster autocomplete.
- **Removed shared demo UUID** — guests now use Supabase anonymous auth with real UUIDs, eliminating data collision.

## 🍽️ Phase 16: Recipe Seeding & Ingredient Icons (Complete)

Massively expanded the recipe database and introduced per-ingredient visual identity.

### 100-Recipe Collection
- **Seeded 100 recipes** across 4 SQL files (`seed_recipes_part1-4.sql`), each with full `recipe_ingredients` and `recipe_steps` (human text + robot action JSON).
- **Cuisines covered:** American, Korean, Japanese, Italian, Thai, Mexican, French, Indian, Spanish, Greek, Chinese, Turkish, Vietnamese, Middle Eastern, British, Russian, Mediterranean.
- **Tags span:** breakfast, lunch, dinner, dessert, side, soup, salad, appetizer, snack, quick, baking, fried, grilled, spicy, healthy, vegetarian, comfort, no-cook.
- **Highlights:** American Pancakes, Korean Maeuntang (spicy fish soup), Bibimbap, Tteokbokki, Bulgogi, Doenjang Jjigae, Shoyu Ramen, Margherita Pizza, Pad Thai, Butter Chicken, and more.
- **Helper function:** `_ensure_ing()` auto-creates missing ingredients with proper `canonical_name` during seeding.

### Ingredient Icon System
- **`seed_ingredients.sql`:** 24 common ingredients with bilingual names (EN/KO), shelf-life data, and storage zones.
- **`migration_007`:** Added `image_url` column to `ingredients` table.
- **`ingredient_icons.dart`:** 70+ emoji mappings (🥔🥕🧅🥚🍗🍚🥛 etc.) with per-ingredient match → category fallback → default.
- **`InventoryItemCard`:** Replaced unreliable Unsplash `NetworkImage` with instant-loading emoji icons.

### Inventory Add Fix
- **Upsert logic:** Backend `add-item` endpoint now checks for existing items at the same `(user_id, ingredient_id, location)` — increments quantity instead of failing with `duplicate key` constraint violation.
- **`canonical_name`:** Now properly set when creating new ingredients (was missing, caused NOT NULL violations).
- **Location normalization:** Lowercased on insert for consistent shelf filtering.

### Query Limits
- Increased recipe query limits from 50 → 200 in Cook screen and Profile screen to display all 100 recipes.

---

## 🌟 Gap Analysis & Deep Refinement (Phases A-E)

Following the initial 16 phases, a comprehensive gap analysis was conducted to refine the core ingredients system, polish recipes, build out deep profile features, and introduce creator capabilities.

### Phase A: Ingredient Foundation & Auto-Fill
- **DB Expansion**: Seeded over 500+ real-world ingredients into the Supabase database with extensive metadata (shelf life, calories, category).
- **Auto-Fill Pipeline**: Wired the photo/barcode/receipt scanners to automatically query the core DB. When an ingredient is detected, the app auto-populates its image, category, and expiry date.
- **Metric Refactor**: Added `UnitConverter.simplifyMetric` to gracefully display quantities (e.g., showing "2 kg" instead of "2000 g"), which is now live in the prep screen.

### Phase B: Recipe System Polish
- **AI Scaling**: Fixed the AI scaling bug allowing smooth portion control.
- **Ingredient Metrics**: Added gamified, highly visible ingredient metrics.
- **Cooking Controls**: Added manual timer toggle support for cooking mode.
- **Fallback Generation**: Handled empty steps with UI to auto-generate instructions via AI.

### Phase C: Profile Deep Pages
- **New Screens**: Created full, robust screens for **Meal Planner**, **Nutrition Tracker**, and **Shopping List**.
- **Navigation**: Wired these deep links from the profile cards.
- **Flavor Profile**: Enhanced the feature to track prepared foods and consumed calories.

### Phase D: Explore & Creator Enhancements
- **Creator Studio**: Built a robust creator dashboard inside the Profile page reflecting views, followers, and engagement metrics.
- **Post Upload Form**: Implemented a comprehensive UI for community chefs to upload reels/videos, attach tags, and link existing recipes.
- **Inline Recipe Viewer (Reels)**: When a user encounters a cooking reel in the Explore tab, tapping the `Recipe` button now opens an immersive, draggable bottom sheet displaying ingredients & instructions seamlessly over the video instead of breaking navigation.

### Phase E: Raw Recipe Parser
- **Backend AI Engine**: Deployed a `/api/v1/ai/parse-raw` endpoint in FastAPI. This utilizes the local `gemma3:1b` model to digest raw, unstructured text (e.g., from blogs or books) and return precise JSON recipes.
- **Frontend Import UI**: Created the `RecipeImportScreen` (accessed via a floating action button in the Cook tab). Users can paste any recipe text, and the AI immediately structures it into prep time, ingredients, and steps.
- **Auto-Timers Capability**: The dynamic regex step-parser inherently processes these AI-generated steps, successfully creating single-tap automated timers (e.g., "bake for 10 minutes") without requiring backend schema migrations.

### Phase F: Hyperlocal Food Discovery & Native Video Feeds
- **Native Inline Video Feeds**: Migrated from clunky webviews to high-performance `dart:ui_web` Platform View Factories for inline YouTube playback without app freezes. 
- **TikTok-Style UI Architecture**: Revamped the `ExploreScreen` (Reels Tab) and `OrderFeedsScreen` using vertical `PageView` builders with robust full-screen video overlays.
- **Context-Aware Interactions**: Added "Close" overlays that properly unmount iframes and return scroll control to the user. Implemented interactive "Cook This Recipe" sidebars for cooking context, and "Order/Reserve" localized actions for restaurant context.
- **Content Bootstrapping via Supabase**: Hand-seeded over 40+ high-quality multi-language (English, Korean, Russian, Uzbek) video shorts directly into a new `video_feeds` schema, completely managed by Supabase, enabling zero-code content pushes.

### Phase G: Security & Algorithm Hardening
- **SQL Injection Fix**: Eliminated critical vulnerability in `recommendation_engine.py` where raw `.format()` string interpolation was used in SQL queries. Replaced with UUID validation + safe Supabase ORM query builder fallback. No raw SQL is ever built from user input.
- **Urgent Items Bug Fix**: Fixed `_get_urgent_items()` which was silently returning zero results — the date range filter used `.lte(today)` instead of `.lte(today + 2 days)`, meaning only items expiring *exactly* today were found.
- **N+1 Query Elimination**: Urgent items previously issued a separate DB query per ingredient to fetch its name. Refactored to a single query with JOIN — O(1) instead of O(N) database calls.
- **CORS Hardening**: Restricted `allow_origins` from wildcard `*` to only `localhost:8080`, `127.0.0.1:8080`, and `shukurillo0526.github.io`.
- **Rate Limiting**: Added `slowapi` rate limiting (10 req/min) on expensive AI endpoints (`generate-recipe`, `detect-ingredients`) to prevent GPU abuse.
- **Dead Code Cleanup**: Removed unused `video_feed_service` import from `cook_screen.dart`.
- **API Version Bump**: Backend version bumped from `3.2.0` → `3.3.0`.

### Phase H: Algorithm & Intelligence Upgrades
- **6-Signal Composite Scoring**: Upgraded from 3-signal scoring (expiry, flavor, familiarity) to 6-signal (+ difficulty fit, recency penalty, match coverage). Weights are configurable via environment variables and sum to 1.0.
- **Difficulty Fit Signal**: Recipes now match against the user's estimated cooking skill level (auto-derived from cooking history count, or explicit `skill_level` column).
- **Recency Penalty Signal**: Recently cooked recipes are penalized to promote variety. 14-day cooldown window with linear ramp.
- **Match Coverage Signal**: A power-curve scoring function that rewards high ingredient match percentages (100% match → 1.0, 50% → 0.45).
- **Server-Side Recommendations API**: New `/api/v1/recommendations/{user_id}` endpoint returns pre-scored, pre-tiered recipes. The Flutter client now tries this first, falling back to client-side scoring if the backend is unreachable. Dramatically reduces data transfer (200 recipes → 50 pre-scored).
- **Ingredient Substitution UI**: Added "🔄 Swap" button on missing ingredients in `RecipeDetailScreen`. Tapping it opens a glassmorphic bottom sheet that calls `/api/v1/ai/substitute` and displays 3 AI-suggested alternatives with swap ratios.
- **Standardized API Response Envelope**: Created `ApiResponse` model with `success/error/partial` status, `data`, `message`, `error`, and `meta` fields for consistent response shapes across all new endpoints.

### Phase I: UX & Performance Overhaul
- **Onboarding Flow**: Built animated 3-step onboarding (PageView with elastic emoji animations, gradient backgrounds, skip controls). Shows once for first-time users, persisted via `SharedPreferences`. Wired into `_AuthGate` without modifying existing auth logic.
- **Recipe Card Redesign**: Enhanced `_RecipeCard` with glowing border for high-match recipes (≥90%), relevance score progress bar (showing the 6-signal composite score), and "% fit" chip. All existing card elements preserved.
- **Image Caching**: Added `cached_network_image` package. Recipe card hero images now use `CachedNetworkImageProvider` instead of raw `NetworkImage`, preventing redundant downloads during scroll.
- **iframe Memory Management**: Fixed memory leak in both `ExploreScreen` (Reels) and `OrderFeedsScreen` — added `didUpdateWidget` to auto-stop video playback when cards scroll off-screen. Previously, iframes stayed alive in memory after scrolling away.

### Phase J: YouTube Intelligence & Advanced Features
- **YouTube Recipe Extraction**: New `youtube_intelligence.py` service + `/api/v1/ai/youtube-recipe` endpoint. Extracts structured recipe data (ingredients, steps, cuisine, difficulty) from YouTube video titles + descriptions using the local LLM. No YouTube Data API required.
- **Flavor Profile Auto-Learning**: New `flavor_learning.py` service. When user taps "I Cooked This", their flavor profile is updated via EMA (15% decay). Creates a feedback loop: cook → profile shifts → better recommendations.
- **"I Cooked This" Button**: Added to `RecipeDetailScreen`. Records cook event, updates flavor profile, and shows a success snackbar. Feeds both the recency signal (for variety) and the flavor learning (for personalization).
- **Smart Shopping List**: New `/api/v1/ai/shopping-list` endpoint generates a consolidated, category-grouped shopping list from missing ingredients across multiple selected recipes. Deduplicates shared ingredients.
- **Video Engagement Tracking**: New `/api/v1/user/engagement` endpoint persists likes, saves, and views to `user_video_engagement` table. Supports like/unlike, save/unsave, and view actions.
- **Frontend API Methods**: Added `recordCook`, `trackEngagement`, `extractYouTubeRecipe`, `generateShoppingList` to `ApiService`.

### Phase K: Scalability & Production Readiness
- **Request ID Middleware**: `RequestIdMiddleware` injects/preserves `X-Request-ID` headers for end-to-end request tracing across frontend → backend → logs. Also adds `X-Response-Time` timing headers.
- **Input Validation Middleware**: `InputValidationMiddleware` enforces 10MB body size limits, validates UUID path parameters, and rejects malformed requests before they hit business logic.
- **Structured Logging**: New `logging_config.py` with JSON-structured logs (or readable dev-mode). Every log entry includes timestamp, level, logger, message, and `request_id` for correlation.
- **Health Check System**: New `/api/v1/health` deep health probe tests Supabase connectivity, Ollama AI availability, and rate limiter status with latency measurements. Returns `healthy`/`degraded`/`unhealthy`. Lightweight `/api/v1/health/ping` liveness probe also added.
- **Global Error Handlers**: Standardized error envelope (`{"status": "error", "code": "...", "message": "...", "request_id": "..."}`) for all HTTP exceptions, validation errors, and unhandled crashes. Tracebacks logged server-side but never exposed to clients.
- **API Documentation**: Enriched OpenAPI spec with descriptive tags (Health, Vision, AI, Recipes, Inventory, User Data, Nutrition, Embeddings), detailed app description, and version bump to 3.4.0.

### Phase L: Testing & CI Pipeline
- **Test Suite**: Created 40 unit/integration tests across 3 test files — all passing in 0.84s:
  - `test_scoring.py` (24 tests): Every signal in the 6-signal composite scoring engine (expiry urgency, flavor affinity, difficulty fit, recency penalty, match coverage, and composite score).
  - `test_middleware.py` (9 tests): Request ID injection/preservation, response timing, body size limits, UUID validation, error formatting.
  - `test_health.py` (7 tests): Root endpoint, ping liveness probe, deep health check, 404 error envelopes.
- **GitHub Actions CI**: `.github/workflows/backend-tests.yml` — runs all tests on every push/PR to `main` with Python 3.12, pip caching, and JUnit result artifacts.
- **Documentation Update**: Updated `QUICK_START.md` (v3.4.0 endpoints, architecture diagram, API table), rewrote `ROADMAP.md` (marked all completed sprints), created `API_REFERENCE.md` (full endpoint reference with request/response shapes, error codes, headers).

---

## 🚀 The Future

I-Fridge is now a fully functional, AI-powered smart kitchen app with 100 recipes, production-grade middleware, and comprehensive observability. Future considerations include:
1. Scaling the database with Kaggle image datasets for visual ingredient matching.
2. Expanding the `pgvector` similarity search based on user swipe/cook history to further personalize the "For You" feed.
3. Live integrations with grocery delivery APIs (e.g., Instacart, Coupang) for 1-click restocking of "Missing Ingredients".
4. End-to-end integration tests using `pytest-asyncio` + Supabase test instance.
5. CI/CD pipeline with GitHub Actions for automated linting, testing, and deployment.
