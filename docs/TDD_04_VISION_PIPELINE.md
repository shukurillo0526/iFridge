# Section 4: The Vision Pipeline (Clarifai)

> **Goal:** From camera snap to inventory update in under 5 seconds, with graceful degradation at every step.

---

## 4.1 End-to-End Flow

```
┌──────────────────────────────────────────────────────────────────┐
│                       USER FLOW                                   │
│                                                                   │
│  📸 Snap Photo                                                    │
│      │                                                            │
│      ▼                                                            │
│  🔄 Upload to Supabase Storage (compressed)                      │
│      │                                                            │
│      ▼                                                            │
│  🧠 FastAPI → Clarifai Food Recognition API                      │
│      │                                                            │
│      ├─── Confidence ≥ 90% ──→ ✅ Auto-add (with undo toast)     │
│      │                                                            │
│      ├─── 70% ≤ Conf < 90% ──→ 🔍 Confirm Card (tap to accept)  │
│      │                                                            │
│      └─── Confidence < 70% ──→ ✏️ Correction UI (search & pick)  │
│                                                                   │
│  ✅ Items added to inventory_items with source='camera'            │
│  📝 Any corrections logged to vision_corrections                  │
└──────────────────────────────────────────────────────────────────┘
```

---

## 4.2 Backend: Vision Orchestrator

```python
# app/services/vision_service.py

from clarifai_grpc.channel.clarifai_channel import ClarifaiChannel
from clarifai_grpc.grpc.api import resources_pb2, service_pb2, service_pb2_grpc
from clarifai_grpc.grpc.api.status import status_code_pb2
from app.core.config import settings

# Confidence thresholds
THRESHOLD_AUTO    = 0.90   # auto-add, no confirmation needed
THRESHOLD_CONFIRM = 0.70   # show confirmation card
# Below 0.70 → full correction UI

class VisionService:
    def __init__(self):
        channel = ClarifaiChannel.get_grpc_channel()
        self.stub = service_pb2_grpc.V2Stub(channel)
        self.metadata = (("authorization", f"Key {settings.CLARIFAI_API_KEY}"),)

    async def recognize_ingredients(
        self, image_bytes: bytes
    ) -> list[dict]:
        """
        Send image to Clarifai Food Model.
        Returns list of predictions with confidence levels.
        """
        request = service_pb2.PostModelOutputsRequest(
            model_id=settings.CLARIFAI_FOOD_MODEL_ID,
            inputs=[
                resources_pb2.Input(
                    data=resources_pb2.Data(
                        image=resources_pb2.Image(base64=image_bytes)
                    )
                )
            ],
        )
        
        response = self.stub.PostModelOutputs(request, metadata=self.metadata)
        
        if response.status.code != status_code_pb2.SUCCESS:
            raise VisionAPIError(response.status.description)
        
        concepts = response.outputs[0].data.concepts
        
        results = []
        for concept in concepts:
            # Map Clarifai concept to our canonical ingredient
            canonical = await self._map_to_canonical(concept.name, concept.id)
            
            results.append({
                "clarifai_concept":  concept.name,
                "clarifai_id":       concept.id,
                "confidence":        round(concept.value, 3),
                "canonical_match":   canonical,  # our ingredient or None
                "action": self._classify_action(concept.value),
            })
        
        return results

    def _classify_action(self, confidence: float) -> str:
        if confidence >= THRESHOLD_AUTO:
            return "auto_add"
        elif confidence >= THRESHOLD_CONFIRM:
            return "confirm"
        else:
            return "correct"

    async def _map_to_canonical(
        self, concept_name: str, clarifai_id: str
    ) -> dict | None:
        """
        Maps a Clarifai concept to our canonical ingredients table.
        Uses the clarifai_concept_ids array for fast lookup.
        Falls back to fuzzy name matching.
        """
        # 1. Try exact concept ID match
        result = await self.db.execute(
            "SELECT id, canonical_name, display_name_en "
            "FROM ingredients "
            "WHERE :clarifai_id = ANY(clarifai_concept_ids) "
            "LIMIT 1",
            {"clarifai_id": clarifai_id}
        )
        if result:
            return result
        
        # 2. Fuzzy name match (trigram similarity)
        result = await self.db.execute(
            "SELECT id, canonical_name, display_name_en, "
            "  similarity(display_name_en, :name) AS sim "
            "FROM ingredients "
            "WHERE similarity(display_name_en, :name) > 0.3 "
            "ORDER BY sim DESC LIMIT 3",
            {"name": concept_name}
        )
        return result[0] if result else None
```

---

## 4.3 FastAPI Endpoint

```python
# app/api/routes/vision.py

from fastapi import APIRouter, UploadFile, File, Depends
from app.services.vision_service import VisionService

router = APIRouter(prefix="/api/v1/vision", tags=["vision"])

@router.post("/recognize")
async def recognize_image(
    user_id: str,
    image: UploadFile = File(...),
    vision: VisionService = Depends(),
):
    """
    Process a food photo and return categorized predictions.
    
    Response shape:
    {
        "auto_add": [{"ingredient_id": "...", "name": "Banana", "confidence": 0.97}],
        "confirm":  [{"ingredient_id": "...", "name": "Red Apple", "confidence": 0.82,
                       "alternatives": ["Fuji Apple", "Gala Apple"]}],
        "correct":  [{"raw_prediction": "round fruit", "confidence": 0.45,
                       "suggestions": ["Apple", "Tomato", "Peach"]}]
    }
    """
    image_bytes = await image.read()
    predictions = await vision.recognize_ingredients(image_bytes)
    
    # Group by action
    grouped = {"auto_add": [], "confirm": [], "correct": []}
    for pred in predictions:
        action = pred["action"]
        grouped[action].append(pred)
    
    # Auto-add high-confidence items immediately
    added_ids = []
    for item in grouped["auto_add"]:
        if item["canonical_match"]:
            inv_id = await _auto_add_to_inventory(user_id, item)
            added_ids.append(inv_id)
    
    return {
        "auto_added": added_ids,
        "confirm": grouped["confirm"],
        "correct": grouped["correct"],
    }
```

---

## 4.4 Edge Case: "Red Apple" vs. "Fuji Apple" — The Correction UI

### The Problem

Clarifai sees "Red Apple" at 82% confidence. The user actually bought Fuji Apples. We need a **frictionless** correction flow — no typing, minimal taps.

### The Correction Flow (Flutter)

```
┌──────────────────────────────────┐
│  📸 We found these items:         │
│                                   │
│  ✅ Banana         (97%)  Added!  │
│  ✅ Eggs           (94%)  Added!  │
│                                   │
│  ─── Please confirm ───           │
│                                   │
│  🔍 Red Apple      (82%)          │
│     ┌─────────────────────────┐   │
│     │  ✓ Red Apple            │   │  ← tap to accept as-is
│     │  › Fuji Apple           │   │  ← tap to pick variant
│     │  › Gala Apple           │   │
│     │  › Honeycrisp Apple     │   │
│     │  🔎 Search other...     │   │  ← full search fallback
│     └─────────────────────────┘   │
│                                   │
│  ─── Not sure about these ───     │
│                                   │
│  ❓ "round red object" (45%)      │
│     [ Search ingredient... 🔎 ]   │  ← inline search bar
│                                   │
│        [ Done ✓ ]                 │
└──────────────────────────────────┘
```

### Implementation Logic

```dart
// lib/features/scan/presentation/widgets/correction_card.dart

class CorrectionCard extends StatelessWidget {
  final VisionPrediction prediction;
  final List<Ingredient> alternatives;
  final ValueChanged<Ingredient> onSelect;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: what Clarifai predicted
          ListTile(
            leading: _ConfidenceIndicator(prediction.confidence),
            title: Text(prediction.rawPrediction),
            subtitle: Text('${(prediction.confidence * 100).toInt()}% confidence'),
          ),
          
          const Divider(height: 1),
          
          // Alternative options — one tap to select
          ...alternatives.map((alt) => ListTile(
            leading: const Icon(Icons.subdirectory_arrow_right, size: 18),
            title: Text(alt.displayName),
            trailing: const Icon(Icons.add_circle_outline),
            onTap: () => onSelect(alt),
            dense: true,
          )),
          
          // Fallback: full search
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Search other ingredient...'),
            onTap: () => _openIngredientSearch(context),
            dense: true,
          ),
        ],
      ),
    );
  }
}
```

### Feedback Loop

Every correction is logged to `vision_corrections`:

```python
async def log_correction(
    user_id: str,
    original_prediction: str,
    corrected_ingredient_id: str,
    clarifai_concept_id: str,
    confidence: float,
    image_path: str,
):
    """
    Logs user corrections for:
    1. Improving our Clarifai concept → ingredient mapping
    2. Building a fine-tuning dataset
    3. Analytics on model weak spots
    """
    await supabase.table("vision_corrections").insert({
        "user_id": user_id,
        "original_prediction": original_prediction,
        "corrected_to": corrected_ingredient_id,
        "clarifai_concept_id": clarifai_concept_id,
        "confidence": confidence,
        "image_storage_path": image_path,
    }).execute()
    
    # Also update the ingredient's clarifai_concept_ids mapping 
    # if this correction happens frequently (batch job, not real-time)
```

---

*← [Section 3: UI Architecture](./TDD_03_UI_ARCHITECTURE.md) | [Section 5: Robot Protocol →](./TDD_05_ROBOT_PROTOCOL.md)*
