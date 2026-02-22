# iFridge — Full Setup & Testing Guide

> Everything you need to run, test, and develop iFridge locally with full AI features enabled.

---

## 📋 Prerequisites

| Tool | Version | Purpose |
|------|---------|---------|
| **Flutter** | ≥ 3.41 (stable) | Frontend framework |
| **Dart** | ≥ 3.11 | Comes with Flutter |
| **Python** | ≥ 3.11 | Backend API server |
| **Ollama** | Latest | Local AI model server |
| **Git** | Latest | Version control |
| **Chrome** | Latest | Web testing target |
| **NVIDIA GPU** (optional) | GTX 1650 Ti+ (4GB+ VRAM) | Accelerated AI inference |

---

## 🗂️ Project Structure

```
iFridge/
├── frontend/          # Flutter app (Dart)
│   ├── lib/
│   │   ├── core/      # Theme, services (ApiService, Supabase config)
│   │   └── features/  # shelf, scan, cook, profile screens
│   ├── web/           # index.html, manifest.json, icons
│   └── pubspec.yaml
├── backend/           # FastAPI server (Python)
│   ├── app/
│   │   ├── main.py            # Application entry point
│   │   ├── routers/           # API endpoints
│   │   │   ├── ocr_parser.py        # /api/v1/receipt/scan
│   │   │   ├── vision_detect.py     # /api/v1/vision/detect-ingredients
│   │   │   ├── recipe_ai.py         # /api/v1/ai/generate-recipe, cooking-tip, substitute
│   │   │   ├── embeddings.py        # /api/v1/ai/semantic-search, personalize
│   │   │   └── barcode_lookup.py    # /api/v1/barcode/lookup
│   │   └── services/
│   │       └── ollama_service.py    # Unified Ollama AI layer
│   ├── db/            # SQL migrations & seed data
│   ├── .env           # Environment variables (DO NOT COMMIT)
│   └── requirements.txt
├── docs/              # Documentation
├── .github/workflows/ # CI/CD (GitHub Pages deployment)
└── PROJECT_HISTORY.md
```

---

## 🚀 Step 1: Backend Setup

### 1.1 Create Python Virtual Environment

```powershell
cd backend
python -m venv venv
.\venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

### 1.2 Configure Environment Variables

The backend requires a `.env` file in `backend/`. Key variables:

```env
# --- Supabase (Required) ---
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# --- Clarifai (Optional — for legacy vision) ---
CLARIFAI_API_KEY=your-clarifai-key

# --- Vision Thresholds ---
VISION_THRESHOLD_AUTO=0.90
VISION_THRESHOLD_CONFIRM=0.70

# --- Recommendation Engine Weights ---
WEIGHT_EXPIRY=0.45
WEIGHT_FLAVOR=0.35
WEIGHT_FAMILIAR=0.20
```

### 1.3 Start the Backend Server

```powershell
cd backend
.\venv\Scripts\Activate.ps1
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

The API will be available at `http://localhost:8000`. 
Health check: `http://localhost:8000/health`

---

## 🤖 Step 2: AI Setup (Ollama — Free & Local)

All AI features (recipe generation, cooking tips, ingredient detection, semantic search) run through **Ollama** on your local machine. No API keys or cloud costs required.

### 2.1 Install Ollama

Download from [https://ollama.com](https://ollama.com) and install.

### 2.2 Pull Required Models

```powershell
# Text generation (primary — fits in 4GB VRAM)
ollama pull qwen2.5:3b

# Vision / image analysis
ollama pull moondream

# Embeddings (runs on CPU, very lightweight)
ollama pull nomic-embed-text
```

### 2.3 Verify Ollama is Running

```powershell
ollama serve
```

Then in a separate terminal:

```powershell
ollama list
```

You should see `qwen2.5:3b`, `moondream`, and `nomic-embed-text`.

### 2.4 GPU Configuration (NVIDIA)

If you have a dedicated NVIDIA GPU alongside an integrated GPU, ensure Ollama uses the dedicated one:

```powershell
# Set once per terminal session before starting Ollama
$env:CUDA_VISIBLE_DEVICES = "0"
ollama serve
```

> **VRAM Budget:** The GTX 1650 Ti has 4GB VRAM. `qwen2.5:3b` (~2.0GB) + `moondream` (~1.7GB) fit simultaneously. If you use `qwen3:8b` (~5GB), it will offload to RAM and run slower.

### 2.5 AI Model Fallback Chain

Each AI endpoint follows a strict fallback order:
1. **Local Ollama** → fastest, free, works offline
2. **Cloud Gemini** → requires `GEMINI_API_KEY` in `.env` (optional)
3. **Mock Data** → hardcoded fallback so the app never crashes

---

## 📱 Step 3: Frontend Setup

### 3.1 Install Flutter Dependencies

```powershell
cd frontend
flutter pub get
```

### 3.2 Switch API URL (Local vs Production)

In `frontend/lib/core/services/api_service.dart`, toggle the `baseUrl`:

```dart
class ApiConfig {
  // ✅ For LOCAL development (Ollama + local backend):
  static const String baseUrl = 'http://localhost:8000';

  // ✅ For PRODUCTION / GitHub Pages:
  // static const String baseUrl =
  //     'https://merry-motivation-production-3529.up.railway.app';
}
```

> ⚠️ **Important:** When deploying to GitHub Pages, you MUST use the production URL. `localhost` is unreachable from a hosted website.

### 3.3 Run on Chrome (Web)

```powershell
cd frontend
flutter run -d Chrome
```

### 3.4 Run on Android / iOS

```powershell
flutter run -d android   # or -d ios
```

---

## 🧪 Step 4: Testing

### 4.1 Flutter Analysis

```powershell
cd frontend
flutter analyze
```

### 4.2 Flutter Unit Tests

```powershell
cd frontend
flutter test
```

### 4.3 Backend Tests

```powershell
cd backend
.\venv\Scripts\Activate.ps1
pytest tests/ -v
```

### 4.4 Manual Feature Testing Checklist

| Feature | How to Test | AI Required? |
|---------|------------|--------------|
| **Living Shelf** | Open app → Shelf tab shows inventory grid | No (Supabase only) |
| **Manual Add** | Shelf tab → "+" → type ingredient name → autocomplete appears | No (Supabase only) |
| **Receipt Scan** | Scan tab → Receipt mode → upload/capture receipt image | Yes (Ollama or Gemini) |
| **Photo Scan** | Scan tab → Photo mode → upload photo of loose ingredients | Yes (Ollama vision) |
| **Audit Screen** | After scan → "Start Visual Audit" → swipe right to accept | No |
| **Cook Screen** | Cook tab → browse recipes → tap to see details | No (Supabase only) |
| **AI Recipe Gen** | Cook tab → "AI Generate" → generates recipe from your inventory | Yes (Ollama text) |
| **Cooking Tips** | Inside recipe steps → "💡 Ask AI" button | Yes (Ollama text) |
| **Expiry Alerts** | Add items with 1-2 day expiry → banner appears on Shelf | No |

---

## 🗄️ Step 5: Database (Supabase)

### 5.1 Schema Setup

Run the SQL migration files in this order on your Supabase SQL Editor:

1. `db/migration_001_init.sql` — creates all tables
2. `db/seed_data.sql` — base ingredient dictionary + demo user
3. `db/additional_seed_data.sql` — expanded ingredients
4. `db/recipe_steps_seed.sql` — recipe data with steps
5. `db/consume_inventory_item.sql` — RPC for "quick use" gesture
6. `db/get_recommended_recipes.sql` — RPC for recommendation tiers
7. `db/dev_rls_fix.sql` — disables Row Level Security for dev

### 5.2 Demo User

The app uses a hardcoded demo user UUID for development:
```
00000000-0000-4000-8000-000000000001
```

This UUID is seeded in `seed_data.sql` and referenced throughout the Flutter app.

---

## 🌐 Step 6: Deployment (GitHub Pages)

The app auto-deploys to GitHub Pages on every push to `main` via `.github/workflows/flutter_web_deploy.yml`.

### Key Configuration:
- **Base href** must exactly match your repository name case: `--base-href /iFridge/`
- **API URL** must point to the production Railway backend (not localhost)
- The workflow uses `peaceiris/actions-gh-pages@v3` to publish `frontend/build/web` to the `gh-pages` branch

### Manual Deploy:
```powershell
cd frontend
flutter build web --base-href /iFridge/
# Then push the build/web contents to gh-pages branch
```

---

## ❗ Common Issues & Fixes

| Issue | Cause | Fix |
|-------|-------|-----|
| **"Couldn't load inventory"** | Supabase query error (wrong column name, RLS blocking) | Check Supabase SQL logs; run `dev_rls_fix.sql` |
| **Blank white page on GH Pages** | `--base-href` casing mismatch with repo URL | Ensure exact match: `/iFridge/` |
| **AI features return mock data** | Ollama not running or models not pulled | Run `ollama serve` and `ollama pull qwen2.5:3b` |
| **Slow AI responses** | Large model loaded, offloading to RAM | Use `qwen2.5:3b` instead of `qwen3:8b` |
| **Receipt scan says "unknown store"** | Photo mode is needed, not receipt mode | Toggle to "Photo" mode in Scan screen |
| **`display_name_en` errors** | Code using old column name `name` | All queries must use `display_name_en` |

---

## 🔑 API Endpoints Reference

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/health` | GET | Health check |
| `/api/v1/receipt/scan` | POST | OCR receipt parsing |
| `/api/v1/vision/detect-ingredients` | POST | Photo ingredient detection |
| `/api/v1/ai/cooking-tip` | POST | Get AI cooking advice |
| `/api/v1/ai/generate-recipe` | POST | Generate recipe from ingredients |
| `/api/v1/ai/substitute` | POST | Find ingredient substitutes |
| `/api/v1/ai/status` | GET | Check AI model availability |
| `/api/v1/ai/semantic-search` | POST | Vector-based recipe search |
| `/api/v1/ai/personalize` | POST | Personalized recommendations |
| `/api/v1/barcode/lookup` | GET | Open Food Facts barcode lookup |
