# iFridge v0.0.2 — Quick Start Guide

> **The Intelligent Fridge Ecosystem** — AI-powered kitchen management, recipe recommendations,
> community cooking feeds, and restaurant ordering.

---

## 📋 Prerequisites

| Tool | Version | Check |
|------|---------|-------|
| **Flutter** | 3.27+ | `flutter --version` |
| **Dart** | 3.10+ | included with Flutter |
| **Python** | 3.12+ | `python --version` |
| **Ollama** | latest | `ollama --version` |
| **Android Studio** | latest | for emulator & SDK tools |
| **Chrome** | latest | for web debugging |
| **Git** | latest | `git --version` |

---

## 🔧 One-Time Setup

### 1. Clone the Repository

```powershell
git clone https://github.com/shukurillo0526/iFridge.git
cd iFridge
```

### 2. Backend Dependencies

```powershell
cd backend
pip install -r requirements.txt
```

### 3. Pull AI Models (requires ~20 GB disk, ~16 GB VRAM)

```powershell
ollama pull qwen2.5vl:7b       # Vision model — receipt/ingredient scanning
ollama pull qwen3:8b            # Text LLM — recipes, tips, chat
ollama pull nomic-embed-text    # Embeddings — semantic search (CPU)
ollama pull gemma3:12b          # Fallback multimodal
```

### 4. Flutter Dependencies

```powershell
cd frontend
flutter pub get
```

### 5. Enable Developer Mode (Windows only, first time)

```powershell
start ms-settings:developers
```

> Toggle **Developer Mode** ON — required for Flutter symlinks.

---

## 🚀 Running Locally (3 Terminals)

### Terminal 1 — Ollama AI Server

```powershell
ollama serve
```

> If it says "already running", skip to Terminal 2.

### Terminal 2 — Backend (FastAPI)

```powershell
cd d:\dev\projects\iFridge\backend
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

> Wait for `Uvicorn running on http://0.0.0.0:8000`. Leave running.

### Terminal 3 — Frontend (Flutter)

Pick your target platform:

```powershell
cd d:\dev\projects\iFridge\frontend

# ── Web (Chrome) ─────────────────────────────
flutter run -d chrome

# ── Android Emulator ─────────────────────────
flutter run                          # auto-picks connected device
flutter run -d emulator-5554         # specific emulator

# ── Windows Desktop ──────────────────────────
flutter run -d windows

# ── Physical Android Phone (USB) ─────────────
flutter run -d <device-id>           # get id from: flutter devices
```

---

## 🧪 Testing Guide

### A. Backend Unit Tests (Python / pytest)

The backend has a test suite covering scoring, middleware, health checks, and expiry prediction.

```powershell
cd d:\dev\projects\iFridge\backend

# Run all tests
python -m pytest tests/ -v

# Run a specific test file
python -m pytest tests/test_scoring.py -v
python -m pytest tests/test_middleware.py -v
python -m pytest tests/test_health.py -v
python -m pytest tests/test_expiry.py -v

# Run with short traceback + JUnit XML output
python -m pytest tests/ -v --tb=short --junitxml=test-results.xml
```

**Test files:**

| File | Covers |
|------|--------|
| `test_scoring.py` | Recipe recommendation engine (6-signal composite scoring) |
| `test_middleware.py` | Request ID injection, input validation, body size limits |
| `test_health.py` | Health check endpoints, dependency status |
| `test_expiry.py` | Smart expiry prediction (storage, packaging factors) |

> These tests also run automatically on every push to `main` via GitHub Actions (`.github/workflows/backend-tests.yml`).

---

### B. Frontend Widget Tests (Flutter)

```powershell
cd d:\dev\projects\iFridge\frontend

# Run all widget tests
flutter test

# Run a specific test file
flutter test test/widget_test.dart

# Run with verbose output
flutter test --reporter expanded
```

---

### C. Manual Testing on Each Platform

#### 🌐 Web (Chrome)

```powershell
flutter run -d chrome
```

- **Best for:** Rapid iteration, DevTools inspection, testing responsive layouts
- **Hot reload:** Press `r` in terminal
- **Hot restart:** Press `R` (capital)
- **DevTools:** Press `d` to detach, open `chrome://inspect`

#### 📱 Android Emulator

```powershell
# List available emulators
flutter emulators

# Launch an emulator
flutter emulators --launch <emulator-name>

# Run on it
flutter run
```

- **Best for:** Testing native features (camera, GPS, haptics, push notifications)
- **If `adb` fails:** Restart emulator or run `adb kill-server && adb start-server`
- **Process error (exit code 255):** Cold-boot the emulator from Android Studio

#### 📱 Physical Android Device (USB)

```powershell
# 1. Enable USB Debugging on your phone (Settings → Developer Options)
# 2. Connect via USB
# 3. Check connection
flutter devices

# 4. Run
flutter run -d <device-id>
```

- **Best for:** Real-world performance, actual camera/GPS testing, haptic feedback

#### 🖥️ Windows Desktop

```powershell
flutter run -d windows
```

- **Best for:** Large-screen layout testing, keyboard navigation
- **Note:** Some mobile-only plugins (camera, GPS) will show permission dialogs or stubs

---

### D. API Testing (Backend Endpoints)

#### Using the built-in Swagger UI

Start the backend, then open in browser:

```
http://localhost:8000/docs
```

> Interactive API docs — try any endpoint directly from the browser.

#### Using curl / PowerShell

```powershell
# Health check
Invoke-RestMethod http://localhost:8000/api/v1/health/ping

# Full health report
Invoke-RestMethod http://localhost:8000/api/v1/health

# AI model status
Invoke-RestMethod http://localhost:8000/api/v1/ai/status

# Generate a recipe
Invoke-RestMethod -Method POST -Uri http://localhost:8000/api/v1/ai/generate-recipe `
  -ContentType "application/json" `
  -Body '{"ingredients": ["chicken", "rice", "soy sauce"], "user_id": "test"}'
```

---

## ✅ Quick Verification Checklist

After all 3 terminals are running:

| URL | Expected |
|-----|----------|
| `http://localhost:8000/` | `{"name": "I-Fridge Intelligence API", "version": "3.4.0", ...}` |
| `http://localhost:8000/api/v1/health/ping` | `{"status": "ok", ...}` |
| `http://localhost:8000/api/v1/health` | Full dependency health report (Supabase, Ollama) |
| `http://localhost:8000/api/v1/ai/status` | Shows which AI models are loaded |
| `http://localhost:8000/docs` | Interactive Swagger API docs |
| Flutter app (any platform) | Onboarding → Living Shelf after login |

---

## 🏗️ Building for Production

### Debug APK (fast, for testing)

```powershell
cd d:\dev\projects\iFridge\frontend
flutter build apk --debug
```

> Output: `build/app/outputs/flutter-apk/app-debug.apk`

### Release APK (optimized, minified)

```powershell
flutter build apk --release
```

> Uses ProGuard/R8 minification. Requires signing key for Play Store.

### Release App Bundle (Play Store upload)

```powershell
flutter build appbundle \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

### Web Build (GitHub Pages)

```powershell
flutter build web --base-href /iFridge/
```

> Auto-deployed on push to `main` via GitHub Actions.

### Windows Desktop Build

```powershell
flutter build windows --release
```

---

## 🌐 Environment Auto-Detection

The app detects its environment automatically — **no URL switching needed:**

| Running From | Browser Host | Backend Used | AI Available |
|-------------|-------------|-------------|-------------|
| `flutter run -d chrome` | `localhost` | `http://localhost:8000` | ✅ Local Ollama |
| `flutter run -d windows` | N/A (desktop) | `http://localhost:8000` | ✅ Local Ollama |
| `flutter run` (Android) | N/A (mobile) | `http://localhost:8000` | ✅ Local Ollama |
| GitHub Pages | `*.github.io` | Railway production | ⚠️ Railway only |

The logic lives in `frontend/lib/core/services/api_service.dart` → `ApiConfig.baseUrl`.

> **Supabase keys** are loaded via `--dart-define` with development fallbacks.  
> For production: pass `--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`

---

## 🧠 AI Models (RTX 5070 Ti — 16GB VRAM)

| Model | Size | Role |
|-------|------|------|
| `qwen2.5vl:7b` | 6.0 GB | Vision — scans receipts, detects ingredients, calorie photos |
| `qwen3:8b` | 5.2 GB | Text LLM — recipe generation, tips, ingredient subs, YouTube extraction |
| `nomic-embed-text` | 274 MB | Embeddings — semantic search (runs on CPU) |
| `gemma3:12b` | 8.1 GB | Fallback — multimodal backup if qwen2.5vl unavailable |

---

## 🏛️ Architecture Overview

### Backend (FastAPI v3.4.0)

```
Request → CORS → RequestIdMiddleware → InputValidationMiddleware → Router → Response
                 ↓                      ↓
           X-Request-ID           Body size check
           X-Response-Time        UUID validation
                 ↓
         Structured JSON logs with request_id correlation
```

**Middleware Stack:**

| Layer | Purpose |
|-------|---------|
| `CORSMiddleware` | Allows Flutter origins |
| `RequestIdMiddleware` | Injects `X-Request-ID`, measures `X-Response-Time` |
| `InputValidationMiddleware` | 10MB body limit, UUID format validation |
| `register_error_handlers` | Standardized error envelopes with request IDs |

**Key Services:**

| Service | Purpose |
|---------|---------|
| `recommendation_engine.py` | 6-signal composite scoring (expiry, flavor, familiarity, difficulty, recency, coverage) |
| `youtube_intelligence.py` | Extracts structured recipes from YouTube video metadata |
| `flavor_learning.py` | EMA-based flavor profile auto-learning on cook events |
| `expiry_prediction.py` | Smart expiry with storage/packaging factors + visual freshness |
| `ollama_service.py` | Local LLM interface (text, vision, embeddings, streaming) |

### Frontend (Flutter v0.0.2)

```
main.dart → AppShell
              ├── _ModeSwitchBar (ORDER / COOK toggle)
              ├── DualModeNavBar (5 Cook tabs, 3 Order tabs)
              └── Screens
                   ├── Cook Mode: Shelf → Cook → Scan → Feeds → Manage
                   └── Order Mode: Order → Feeds → Manage
```

**Key Packages:**

| Package | Purpose |
|---------|---------|
| `supabase_flutter` | Auth, Realtime DB, Storage |
| `flutter_riverpod` | State management |
| `hive_flutter` | Offline cache + sync queue |
| `mobile_scanner` | Barcode/receipt scanning |
| `speech_to_text` | Voice commands |
| `share_plus` | Social sharing |

---

## 📡 API Endpoints

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/v1/health` | Deep health check (Supabase + Ollama + latency) |
| GET | `/api/v1/health/ping` | Lightweight liveness probe |
| GET | `/api/v1/ai/status` | AI model status |
| POST | `/api/v1/ai/generate-recipe` | Generate recipe from ingredients |
| POST | `/api/v1/ai/substitute` | AI ingredient substitution |
| POST | `/api/v1/ai/cooking-tip` | Get cooking tips for a step |
| POST | `/api/v1/ai/youtube-recipe` | Extract recipe from YouTube metadata |
| POST | `/api/v1/ai/shopping-list` | Smart shopping list generation |
| POST | `/api/v1/ai/parse-raw` | Parse raw recipe text |
| POST | `/api/v1/ai/normalize-recipe` | Convert terse steps to detailed steps |
| POST | `/api/v1/ai/chat` | Multi-turn kitchen assistant (SSE streaming) |
| GET | `/api/v1/recommendations/{user_id}` | Server-side scored recommendations |
| POST | `/api/v1/user/init` | Initialize new user |
| GET | `/api/v1/user/{user_id}/dashboard` | Full user profile data |
| POST | `/api/v1/user/cook` | Record cook event (triggers flavor learning) |
| POST | `/api/v1/user/engagement` | Track video likes/saves/views |
| POST | `/api/v1/inventory/predict-expiry` | Smart expiry prediction |
| POST | `/api/v1/inventory/assess-freshness` | Visual freshness score from photo |
| POST | `/api/v1/calories/analyze-image` | Analyze food photo for calories |
| POST | `/api/v1/calories/analyze` | Estimate calories for food items |
| GET | `/api/v1/calories/daily/{user_id}` | Daily nutrition summary |

> Full interactive docs at `http://localhost:8000/docs`

---

## 🔄 CI/CD Pipelines

| Workflow | Trigger | What it does |
|----------|---------|--------------|
| `backend-tests.yml` | Push/PR to `main` (backend changes) | Runs `pytest` on Python tests |
| `flutter_web_deploy.yml` | Push to `main` | Builds Flutter web → deploys to GitHub Pages |

---

## 🐛 Troubleshooting

| Problem | Fix |
|---------|-----|
| `No module named uvicorn` | Run `pip install -r requirements.txt` in `backend/` |
| Backend won't start | Check Python 3.12+ installed, deps installed |
| AI returns mock data | Check `ollama serve` is running in Terminal 1 |
| "Couldn't load inventory" | Backend not running, or check Terminal 2 for errors |
| Hot reload not working | Press `R` (capital) for full hot restart |
| `flutter pub get` fails | Enable Developer Mode: `start ms-settings:developers` |
| Wrong backend URL | Automatic via `ApiConfig` — check `api_service.dart` |
| Health check returns 503 | Supabase connection issue — check `.env` credentials |
| `X-Request-ID` missing | Ensure `RequestIdMiddleware` is registered in `main.py` |
| Emulator process error 255 | Cold-boot emulator from Android Studio, or `adb kill-server` |
| Chrome CORS error | Ensure backend is running on port 8000 with CORS enabled |
| `flutter run` no devices | Run `flutter devices` — start emulator or connect phone |
| Windows build fails | Run `flutter config --enable-windows-desktop` first |
| APK install fails on phone | Enable "Install from unknown sources" in phone settings |
| Release build crashes | Check ProGuard rules in `android/app/proguard-rules.pro` |
