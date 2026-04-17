# iFridge — Quick Start Checklist

> Run these steps to get iFridge running locally with full AI support.
> The app **auto-detects** its environment — no URL switching needed:
> - `flutter run -d Chrome` → uses **localhost:8000** (local Ollama AI)
> - GitHub Pages → uses **Railway production backend**

---

## 🔧 One-Time Setup (First Time Only)

### 1. Install Python Dependencies

```powershell
cd d:\dev\projects\iFridge\backend
pip install -r requirements.txt
```

### 2. Pull AI Models

```powershell
ollama pull qwen2.5vl:7b
ollama pull qwen3:8b
ollama pull nomic-embed-text
ollama pull gemma3:12b
```

### 3. Install Flutter Dependencies

```powershell
cd d:\dev\projects\iFridge\frontend
flutter pub get
```

---

## 🚀 Running Locally (3 Terminals)

### Terminal 1: Ollama (AI Server)

```powershell
ollama serve
```

> Leave this running. If it says "already running", that's fine — skip to Terminal 2.

---

### Terminal 2: Backend (FastAPI)

```powershell
cd d:\dev\projects\iFridge\backend
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

> Wait until you see `Uvicorn running on http://0.0.0.0:8000`. Leave it running.

---

### Terminal 3: Frontend (Flutter)

```powershell
cd d:\dev\projects\iFridge\frontend
flutter run -d Chrome
```

---

## ✅ Quick Verify

After all 3 are running, open Chrome and check:

- `http://localhost:8000/` → should return `{"message": "I-Fridge Intelligence API v3.0 is running"}`
- `http://localhost:8000/api/v1/ai/status` → shows which AI models are loaded
- The Flutter app should load the Living Shelf

---

## 🌐 How Environment Auto-Detection Works

The API URL is **automatic** — you never need to edit `api_service.dart`:

| Running From | Browser Host | Backend Used | AI Available |
|-------------|-------------|-------------|-------------|
| `flutter run -d Chrome` | `localhost` | `http://localhost:8000` | ✅ Local Ollama |
| GitHub Pages | `*.github.io` | Railway production URL | ⚠️ Railway (no local Ollama) |

The logic lives in `frontend/lib/core/services/api_service.dart`:

```dart
static String get baseUrl {
  if (kIsWeb) {
    final host = Uri.base.host;
    if (host != 'localhost' && host != '127.0.0.1') {
      return _productionUrl;  // GitHub Pages → Railway
    }
  }
  return _localUrl;  // Local dev → localhost:8000
}
```

> **No more commenting/uncommenting URLs before pushing to GitHub!**

---

## 🧠 AI Models (RTX 5070 Ti — 16GB VRAM)

The backend uses these local AI models via Ollama:

| Model | Size | Role |
|-------|------|------|
| `qwen2.5vl:7b` | 6.0 GB | Vision (multimodal) — scans receipts, detects ingredients, calorie photos |
| `qwen3:8b` | 5.2 GB | Text LLM — recipe generation, tips, ingredient subs |
| `nomic-embed-text` | 274 MB | Embeddings — semantic search (runs on CPU) |
| `gemma3:12b` | 8.1 GB | Fallback — multimodal backup if qwen2.5vl unavailable |

---

## 🔄 If Things Break

| Problem | Fix |
|---------|-----|
| `No module named uvicorn` | Run `pip install -r requirements.txt` in the `backend` folder |
| Backend won't start | Make sure Python deps are installed (see above) |
| AI returns mock data | Check `ollama serve` is running in Terminal 1 |
| "Couldn't load inventory" | Backend not running, or check Terminal 2 for errors |
| Hot reload not working | Press `R` (capital) in Terminal 3 for hot restart |
| Flutter `pub get` fails | Enable Developer Mode: `start ms-settings:developers` |
| Wrong backend URL | Should be automatic now — check `ApiConfig` in `api_service.dart` |
