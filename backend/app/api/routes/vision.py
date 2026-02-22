"""
I-Fridge — Vision API Routes
==============================
Endpoints for camera-based ingredient recognition and correction.
"""

from fastapi import APIRouter, UploadFile, File, HTTPException
from app.services.vision_service import VisionService, VisionAPIError
from app.models.vision import VisionResponse, CorrectionRequest

router = APIRouter(prefix="/api/v1/vision", tags=["vision"])


@router.post("/recognize", response_model=VisionResponse)
async def recognize_image(
    user_id: str,
    image: UploadFile = File(..., description="Food photo (JPEG/PNG)"),
):
    """
    Process a food photo and return categorized predictions.

    **Flow:**
    1. Image is sent to Clarifai Food Recognition model
    2. Each prediction is mapped to our canonical ingredient database
    3. Predictions are gated by confidence:
       - **≥90%** → `auto_add` (instantly added to inventory)
       - **70-89%** → `confirm` (shown for one-tap confirmation)
       - **<70%** → `correct` (full correction UI with alternatives)

    **Response includes:**
    - `auto_added`: List of inventory item IDs that were instantly added
    - `confirm`: Predictions needing user confirmation
    - `correct`: Low-confidence predictions needing manual correction
    """
    try:
        vision = VisionService()
        image_bytes = await image.read()

        predictions = await vision.recognize_ingredients(image_bytes)

        auto_added: list[str] = []
        confirm_list = []
        correct_list = []

        for pred in predictions:
            if pred.action == "auto_add" and pred.canonical_match:
                inv_id = await vision.add_to_inventory(
                    user_id=user_id,
                    ingredient_id=pred.canonical_match["id"],
                    confidence=pred.confidence,
                )
                auto_added.append(inv_id)
            elif pred.action == "confirm":
                confirm_list.append(pred)
            else:
                correct_list.append(pred)

        return VisionResponse(
            auto_added=auto_added,
            confirm=confirm_list,
            correct=correct_list,
        )

    except VisionAPIError as e:
        raise HTTPException(status_code=502, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/correct")
async def submit_correction(
    user_id: str,
    correction: CorrectionRequest,
):
    """
    Submit a user correction for a vision prediction.

    This logs the correction for:
    1. Improving Clarifai concept → ingredient mappings
    2. Building fine-tuning datasets
    3. Analytics on model weak spots

    The corrected ingredient is also added to inventory.
    """
    try:
        vision = VisionService()

        # Log the correction
        await vision.log_correction(
            user_id=user_id,
            original_prediction=correction.original_prediction,
            corrected_ingredient_id=correction.corrected_ingredient_id,
            clarifai_concept_id=correction.clarifai_concept_id,
            confidence=correction.confidence,
            image_path=correction.image_storage_path,
        )

        # Add corrected ingredient to inventory
        inv_id = await vision.add_to_inventory(
            user_id=user_id,
            ingredient_id=correction.corrected_ingredient_id,
            confidence=1.0,  # user-confirmed = 100% confidence
            source="camera_corrected",
        )

        return {"status": "corrected", "inventory_item_id": inv_id}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
