# iFridge — Quick Start Checklist

> Run these commands **every time** before `flutter run -d Chrome`.
> Open **3 separate terminals** and run each section in order.

---

## Terminal 1: Ollama (AI Server)

```powershell
ollama serve
```

> Leave this running. If it says "already running", that's fine — skip to Terminal 2.

---

## Terminal 2: Backend (FastAPI)

```powershell
cd c:\Codes\iFridge\backend
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

> Wait until you see `Uvicorn running on http://0.0.0.0:8000`. Leave it running.

---

## Terminal 3: Frontend (Flutter)

```powershell
cd c:\Codes\iFridge\frontend
flutter run -d Chrome
```

---

## ✅ Quick Verify

After all 3 are running, open Chrome and check:

- `http://localhost:8000/` → should return `{"message": "I-Fridge Intelligence API v3.0 is running"}`
- `http://localhost:8000/api/v1/ai/status` → shows which AI models are loaded
- The Flutter app should load the Living Shelf

---

## ⚠️ Before Running: API URL Check

Make sure `frontend/lib/core/services/api_service.dart` points to **localhost** (not Railway):

```dart
class ApiConfig {
  static const String baseUrl = 'http://localhost:8000';  // ← this one
  // static const String baseUrl = 'https://merry-motivation-production-3529.up.railway.app';
}
```

> **Note:** If you recently pushed to GitHub, the file may still point to the Railway URL. Switch it back to localhost for local development.

---

## 🧠 AI Models (RTX 5070 Ti — 16GB VRAM)

The backend uses these local AI models via Ollama:

| Model | Size | Role |
|-------|------|------|
| `qwen2.5vl:7b` | 6.0 GB | Vision (multimodal) — scans receipts, detects ingredients, calorie photos |
| `qwen3:8b` | 5.2 GB | Text LLM — recipe generation, tips, ingredient subs |
| `nomic-embed-text` | 274 MB | Embeddings — semantic search (runs on CPU) |
| `gemma3:12b` | 8.1 GB | Fallback — multimodal backup if qwen2.5vl unavailable |

If any model is missing, pull it:
```powershell
ollama pull qwen2.5vl:7b
ollama pull qwen3:8b
ollama pull nomic-embed-text
ollama pull gemma3:12b
```

---

## 🔄 If Things Break

| Problem | Fix |
|---------|-----|
| Backend won't start | Make sure Python deps are installed: `pip install -r requirements.txt` |
| AI returns mock data | Check `ollama serve` is running in Terminal 1 |
| "Couldn't load inventory" | Backend not running or API URL is wrong |
| Hot reload not working | Press `R` (capital) in Terminal 3 for hot restart |
| Flutter `pub get` fails | Enable Developer Mode: `start ms-settings:developers` |
