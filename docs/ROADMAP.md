# iFridge — Roadmap & Next Steps

> Tracks the evolution of iFridge from MVP to production-ready.
> Items marked ✅ have been completed. Remaining items are prioritized for future work.

---

## ✅ Completed — Optimization Roadmap (Sprints 1-5)

### Sprint 1: Security & Stability ✅
- ✅ SQL injection prevention — all queries use Supabase ORM/RPC
- ✅ Rate limiting — `slowapi` on all AI endpoints (10 req/min)
- ✅ API response standardization — `ApiResponse` envelope model

### Sprint 2: Algorithm Upgrades ✅
- ✅ 6-signal composite scoring (expiry, flavor, familiarity, difficulty, recency, coverage)
- ✅ Server-side recommendations — `/api/v1/recommendations/{user_id}` with client fallback
- ✅ AI ingredient substitution — "Swap" button on missing ingredients

### Sprint 3: UX & Performance ✅
- ✅ Onboarding flow — 3-step animated PageView for first-time users
- ✅ Recipe card redesign — glow border for ≥90% matches, relevance score bar
- ✅ Image caching — `cached_network_image` for recipe hero images
- ✅ iframe memory fix — auto-stop off-screen video playback

### Sprint 4: YouTube Intelligence ✅
- ✅ YouTube recipe extraction — `/api/v1/ai/youtube-recipe` via LLM
- ✅ Flavor profile auto-learning — EMA (α=0.15) on cook events
- ✅ Smart shopping list — `/api/v1/ai/shopping-list` (deduplicated, category-grouped)
- ✅ "I Cooked This" button — records cook + triggers flavor learning
- ✅ Video engagement tracking — persistent likes/saves/views

### Sprint 5: Scalability & Production ✅
- ✅ Request ID middleware — `X-Request-ID` + `X-Response-Time` tracing
- ✅ Input validation middleware — 10MB body limit, UUID format checks
- ✅ Structured JSON logging — request ID correlation
- ✅ Health checks — `/api/v1/health` (deep) + `/api/v1/health/ping` (liveness)
- ✅ Global error handlers — standardized error envelopes
- ✅ API documentation — enriched OpenAPI spec with tags

---

## 🔥 Priority 1: Critical Fixes & Polish

### 1.1 Seed the Recipes Table
- **Status:** ✅ Done — 100 recipes loaded with ingredients and steps.

### 1.2 Barcode Scanning
- **Status:** ✅ Done — wired into Scan screen via `mobile_scanner`.

### 1.3 User Authentication
- **Status:** ✅ Done — Supabase Auth with Google OAuth. Demo UUID replaced.

### 1.4 Expiry Notifications
- **Status:** ⏳ Pending — requires Supabase Edge Function + FCM push.
- **Action:** Implement a daily cron that queries items expiring within 2 days, sends push via FCM.

---

## ⚡ Priority 2: Feature Enhancements

### 2.1 Ingredient Image Database
- **Status:** Partially done (emoji icons work well). Full image URLs optional.
- **Options:** Unsplash API bulk-populate, Supabase Storage uploads, or AI-generated icons.

### 2.2 Shopping List Generation
- **Status:** ✅ Done — "Add to Shopping List" button on recipe detail, smart shopping list API, category grouping.

### 2.3 Meal Planning Calendar
- **Status:** ✅ Done — meal plan CRUD endpoints exist. Calendar view enhancement pending.

### 2.4 Multi-Language Support (i18n)
- **Status:** ✅ Done — English, Korean, Uzbek, Russian supported via `flutter_localizations`.

### 2.5 Share & Social Features
- **Status:** Partial — video feed with likes/bookmarks exists. Deep link sharing pending.

---

## 🧠 Priority 3: AI Upgrades

### 3.1 Conversational Kitchen Assistant
- **Status:** ⏳ Pending
- Replace single-shot tips with a persistent chat interface.
- Use streaming responses for real-time feel.

### 3.2 Smart Expiry Prediction (AI-Enhanced)
- **Status:** ⏳ Pending
- Train on historical data (purchase → discard). Factor in storage, packaging, season.

### 3.3 Visual Freshness Detection
- **Status:** ⏳ Pending
- Camera-based freshness scoring to dynamically adjust computed expiry.

### 3.4 Personalized Nutrition Tracking
- **Status:** ✅ Done — calorie analysis (DB-first + AI fallback), daily nutrition logs, meal-type tracking.

### 3.5 Voice Commands
- **Status:** ⏳ Pending
- Speech-to-text for hands-free cooking, voice timer control.

---

## 🏗️ Priority 4: Architecture & Scale

### 4.1 State Management Upgrade
- **Current:** `setState()` in most screens. Some screens use provider pattern.
- **Upgrade to:** Full Riverpod migration for shared caching (inventory loaded once).

### 4.2 Offline-First Architecture
- **Status:** ⏳ Pending
- Cache inventory/recipes locally using `hive` or `isar`.
- Sync with Supabase on connectivity restore.

### 4.3 Cloud AI Migration
- **Status:** ⏳ Pending — local Ollama works great for development.
- For production scale: OpenAI GPT-4o (text), Google Gemini 2.0 (vision).
- Keep Ollama as dev/offline fallback.

### 4.4 CI/CD Pipeline Expansion
- **Status:** ✅ Backend CI done — `.github/workflows/backend-tests.yml`
- 40 unit tests run on every push/PR to `main` (scoring, middleware, health)
- Flutter tests and Railway auto-deploy still pending.

### 4.5 Analytics & Monitoring
- **Status:** Partial — structured logging and health checks are done.
- Add PostHog/Mixpanel for user behavior analytics.
- Add Sentry for crash reporting.

---

## 📊 Current Status (v3.4.0)

| Area | Status | Completeness |
|------|--------|-------------|
| Core Features | ✅ | 95% |
| AI Pipeline | ✅ | 90% |
| Security | ✅ | 95% |
| Performance | ✅ | 85% |
| Observability | ✅ | 80% |
| Testing | ✅ | 60% |
| CI/CD | ✅ | 50% |

---

## 🧪 Test Suite (40 tests, 0.84s)

| File | Tests | Coverage |
|------|-------|----------|
| `test_scoring.py` | 24 | 6-signal scoring engine (expiry, flavor, difficulty, recency, coverage, composite) |
| `test_middleware.py` | 9 | Request ID, timing, body size, UUID validation, error formatting |
| `test_health.py` | 7 | Root endpoint, ping, deep health, 404 envelope |

Run locally: `cd backend && python -m pytest tests/ -v`

---

## 💡 Remaining Quick Wins

1. ⏳ Implement FCM push notifications for expiring items
2. ⏳ Add streaming chat for the kitchen assistant
3. ⏳ Riverpod migration for shared inventory state
4. ⏳ Flutter widget tests in CI
5. ⏳ Sentry crash reporting integration
