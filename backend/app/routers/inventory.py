"""
I-Fridge — Inventory API Router
=================================
Handles ingredient upsert and inventory item creation.
Uses the service role key to bypass RLS restrictions.
"""

import logging
from datetime import datetime, timedelta
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional

from app.db.supabase_client import get_supabase

logger = logging.getLogger("ifridge.inventory")

router = APIRouter()


class AddItemRequest(BaseModel):
    user_id: str
    ingredient_name: str
    category: str = "Pantry"
    quantity: float = 1.0
    unit: str = "pcs"
    location: str = "Fridge"
    expiry_date: Optional[str] = None  # ISO 8601, defaults to 7 days


@router.post("/api/v1/inventory/add-item")
async def add_inventory_item(req: AddItemRequest):
    """
    Upsert an ingredient and add it to inventory.
    Uses the service role key, so RLS is bypassed.
    """
    db = get_supabase()

    try:
        # 1. Find or create ingredient
        existing = (
            db.table("ingredients")
            .select("id")
            .ilike("display_name_en", req.ingredient_name)
            .limit(1)
            .execute()
        )

        if existing.data and len(existing.data) > 0:
            ingredient_id = existing.data[0]["id"]
        else:
            inserted = (
                db.table("ingredients")
                .insert({
                    "display_name_en": req.ingredient_name,
                    "category": req.category,
                    "default_unit": req.unit,
                })
                .execute()
            )
            ingredient_id = inserted.data[0]["id"]

        # 2. Insert inventory item
        expiry = req.expiry_date or (
            datetime.now() + timedelta(days=7)
        ).isoformat()

        db.table("inventory_items").insert({
            "user_id": req.user_id,
            "ingredient_id": ingredient_id,
            "quantity": req.quantity,
            "unit": req.unit,
            "location": req.location,
            "expiry_date": expiry,
        }).execute()

        logger.info(f"[Inventory] Added {req.ingredient_name} (id={ingredient_id})")
        return {
            "status": "success",
            "ingredient_id": ingredient_id,
            "message": f"Added {req.ingredient_name} to shelf",
        }

    except Exception as e:
        logger.error(f"[Inventory] Failed to add item: {e}")
        raise HTTPException(status_code=500, detail=str(e))
