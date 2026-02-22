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
cd d:\New folder\backend
.\venv\Scripts\Activate.ps1
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

> Wait until you see `Uvicorn running on http://0.0.0.0:8000`. Leave it running.

---

## Terminal 3: Frontend (Flutter)

```powershell
cd d:\New folder\frontend
flutter run -d Chrome
```

---

## ✅ Quick Verify

After all 3 are running, open Chrome and check:

- `http://localhost:8000/health` → should return `{"status": "ok"}`
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

## 🔄 If Things Break

| Problem | Fix |
|---------|-----|
| Backend won't start | Re-activate venv: `.\venv\Scripts\Activate.ps1` |
| AI returns mock data | Check `ollama serve` is running in Terminal 1 |
| "Couldn't load inventory" | Backend not running or API URL is wrong |
| Hot reload not working | Press `R` (capital) in Terminal 3 for hot restart |
