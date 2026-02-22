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

We have successfully completed the 7-phase consumer pivot, resulting in a polished, AI-powered MVP.

### Phase 1: Existing UI/UX Polish & Functional Fixes
- Audited all current screens (Shelf, Scan, Cook, Profile).
- Removed dead-end settings and broken placeholders to ensure a clean, functional UI.
- Enhanced empty states and loading indicators using Shimmer skeleton screens.

### Phase 2: Ingredient Adding & Expiry Intelligence
- **Advanced Manual Entry:** Upgraded the Scan screen's manual entry with category dropdowns (Produce, Meat, Dairy, etc.) and 12+ metric types (pcs, kg, L, etc.). Form now directly upserts into Supabase.
- **OCR Receipt Parsing:** Built a FastAPI backend integrating Google Gemini 1.5 Flash. Tuned the prompt specifically for complex Korean grocery receipts (e.g., 진안식자재마트), successfully extracting items, sizes, origin markers, and tax-exempt tags.
- **Heuristic Expiry Engine:** Developed a robust fallback system with 25+ category-specific shelf-life estimates to automatically assign expiration dates when not found via OCR.

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

## 🚀 The Future

I-Fridge is now a fully functional, AI-powered smart kitchen app. Future considerations include:
1. Scaling the database with Kaggle image datasets for visual ingredient matching.
2. Expanding the `pgvector` similarity search based on user swipe/cook history to further personalize the "For You" feed.
3. Live integrations with grocery delivery APIs (e.g., Instacart, Coupang) for 1-click restocking of "Missing Ingredients".
