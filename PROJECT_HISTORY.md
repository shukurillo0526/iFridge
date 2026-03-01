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


## 🚀 The Future

I-Fridge is now a fully functional, AI-powered smart kitchen app. Future considerations include:
1. Scaling the database with Kaggle image datasets for visual ingredient matching.
2. Expanding the `pgvector` similarity search based on user swipe/cook history to further personalize the "For You" feed.
3. Live integrations with grocery delivery APIs (e.g., Instacart, Coupang) for 1-click restocking of "Missing Ingredients".
