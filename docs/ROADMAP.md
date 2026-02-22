# iFridge — Future Roadmap & Next Steps

> A prioritized list of improvements, new features, and architectural upgrades to take iFridge from MVP to production-ready.

---

## 🔥 Priority 1: Critical Fixes & Polish (Phase 14)

These should be done first to ensure the core MVP is rock-solid.

### 1.1 Seed the Recipes Table
- **Status:** The `recipes` table is mostly empty. The Cook screen's fallback query works, but returns nothing meaningful without data.
- **Action:** Run `recipe_steps_seed.sql` and `additional_seed_data.sql` on Supabase. Alternatively, build an admin ETL script to bulk-import recipes from Food.com or similar datasets.

### 1.2 Barcode Scanning
- **Status:** The `/api/v1/barcode/lookup` endpoint exists but is not wired into the Flutter app.
- **Action:** Add a barcode scan button to the Scan screen using the `mobile_scanner` Flutter package. On scan, call the barcode API, which enriches via Open Food Facts, then auto-populate the manual entry form.

### 1.3 User Authentication
- **Status:** Currently uses a hardcoded demo UUID (`00000000-0000-4000-8000-000000000001`).
- **Action:** Integrate Supabase Auth (email/password or Google OAuth). Replace all hardcoded `_demoUserId` references with `Supabase.instance.client.auth.currentUser!.id`.

### 1.4 Expiry Notifications
- **Status:** The shelf shows an "Expiring Soon" banner, but there are no push notifications.
- **Action:** Implement a Supabase Edge Function that runs daily, queries items expiring within 2 days, and sends push notifications via Firebase Cloud Messaging (FCM).

---

## ⚡ Priority 2: Feature Enhancements (Phase 15)

### 2.1 Ingredient Image Database
- **Status:** Shelf items currently show category emojis (🍎, 🥩, etc.) because the `ingredients` table has no `image_url` column populated.
- **Action Options:**
  - **Option A:** Add an `image_url` column to `ingredients` and bulk-populate from Unsplash/Pexels API using ingredient names.
  - **Option B:** Use Supabase Storage to let users upload photos of their own ingredients.
  - **Option C:** Use AI (DALL-E/Stable Diffusion) to generate stylized icons for each ingredient category.

### 2.2 Shopping List Generation
- When a user views a recipe with missing ingredients, add a **"Add to Shopping List"** button.
- Create a `shopping_list` table and a new Shopping tab in the bottom navigation.
- Future integration with grocery delivery APIs (Coupang, Instacart).

### 2.3 Meal Planning Calendar
- Allow users to assign recipes to specific days of the week.
- Auto-generate a weekly shopping list from the planned meals minus current inventory.
- Display a calendar view in a new "Plan" tab.

### 2.4 Multi-Language Support (i18n)
- **Status:** The app currently uses English only, but ingredient names support `display_name_ko` (Korean).
- **Action:** Implement Flutter's `intl` package for full localization. Start with English and Korean.

### 2.5 Share & Social Features
- Allow users to share recipes via deep links.
- Add a "Community Recipes" feed where users can publish their AI-generated recipes.
- Implement likes/saves on shared recipes.

---

## 🧠 Priority 3: AI Upgrades (Phase 16)

### 3.1 Conversational Kitchen Assistant
- Replace the single-shot "Ask AI for a tip" with a persistent **chat interface**.
- Users can ask follow-up questions mid-cooking: "Can I substitute butter with oil?" → "How much oil?" → "What temperature?"
- Use streaming responses for a real-time feel.

### 3.2 Smart Expiry Prediction (AI-Enhanced)
- Train a lightweight model on historical expiry data (purchase date → actual discard date).
- Factor in storage location (fridge vs pantry), packaging type, and season.
- Replace the current static category-based algorithm with learned predictions.

### 3.3 Visual Freshness Detection
- Use the phone camera to analyze an ingredient's visual freshness (brown spots on bananas, wilted lettuce).
- Output a freshness score that dynamically adjusts the computed expiry date.
- The backend vision endpoint already returns a `freshness` field — wire it into the inventory update flow.

### 3.4 Personalized Nutrition Tracking
- Parse nutritional data from recipes (calories, macros).
- Track daily intake based on cooked recipes.
- Display weekly nutrition summaries in the Profile tab.

### 3.5 Voice Commands
- Integrate speech-to-text for hands-free cooking.
- "Hey iFridge, what can I cook tonight?" → triggers AI recipe generation.
- "Start timer for 5 minutes" → starts inline timer.

---

## 🏗️ Priority 4: Architecture & Scale (Phase 17)

### 4.1 State Management Upgrade
- **Current:** Each screen manages its own state with `setState()`.
- **Upgrade to:** Riverpod or Bloc for centralized, testable state management.
- This enables proper caching (inventory loaded once, shared across Shelf/Cook/Scan).

### 4.2 Offline-First Architecture
- Cache inventory and recipes locally using `hive` or `isar`.
- Sync with Supabase when connectivity is restored.
- Critical for mobile use in kitchens with poor WiFi.

### 4.3 Cloud AI Migration
- For production scale, replace local Ollama with cloud-hosted models:
  - **OpenAI GPT-4o** for text generation
  - **Google Gemini 2.0 Flash** for vision
  - **OpenAI Embeddings** for semantic search
- Keep Ollama as a development/offline fallback.

### 4.4 CI/CD Pipeline Expansion
- Add automated Flutter tests to the GitHub Actions workflow.
- Add backend pytest execution in CI.
- Deploy backend automatically to Railway on `main` push.

### 4.5 Analytics & Monitoring
- Integrate PostHog or Mixpanel for user behavior analytics.
- Track which features are used most, scan success rates, recipe completion rates.
- Add Sentry for crash reporting.

---

## 📊 Suggested Timeline

| Phase | Focus | Estimated Time |
|-------|-------|---------------|
| **Phase 14** | Critical Fixes (Auth, Recipes, Barcode) | 1-2 weeks |
| **Phase 15** | Feature Enhancements (Shopping List, Images, Meal Plan) | 2-3 weeks |
| **Phase 16** | AI Upgrades (Chat, Freshness, Nutrition) | 3-4 weeks |
| **Phase 17** | Architecture & Scale (State Mgmt, Offline, Cloud AI) | 4-6 weeks |

---

## 💡 Quick Wins (Can Do Right Now)

1. ✅ Run `recipe_steps_seed.sql` to populate Cook screen
2. ✅ Add more ingredients to the `ingredients` table for richer autocomplete
3. ✅ Add `image_url` column to `ingredients` and populate with free stock images
4. ✅ Wire barcode scanning into the Scan screen
5. ✅ Replace demo UUID with Supabase Auth
