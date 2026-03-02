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
    If the same ingredient already exists in the same location,
    increments quantity instead of creating a duplicate.
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
            # canonical_name is required (NOT NULL UNIQUE)
            canonical = req.ingredient_name.strip().lower().replace(" ", "_")
            inserted = (
                db.table("ingredients")
                .insert({
                    "canonical_name": canonical,
                    "display_name_en": req.ingredient_name.strip(),
                    "category": req.category,
                    "default_unit": req.unit,
                })
                .execute()
            )
            ingredient_id = inserted.data[0]["id"]

        # 2. Upsert inventory item (increment qty if exists)
        location = req.location.lower()  # normalize for consistency
        expiry = req.expiry_date or (
            datetime.now() + timedelta(days=7)
        ).isoformat()

        # Check if item already exists for this user+ingredient+location
        existing_inv = (
            db.table("inventory_items")
            .select("id, quantity")
            .eq("user_id", req.user_id)
            .eq("ingredient_id", ingredient_id)
            .eq("location", location)
            .limit(1)
            .execute()
        )

        if existing_inv.data and len(existing_inv.data) > 0:
            # Update quantity (add to existing)
            old_qty = existing_inv.data[0]["quantity"]
            new_qty = old_qty + req.quantity
            db.table("inventory_items").update({
                "quantity": new_qty,
                "manual_expiry_date": expiry,
            }).eq("id", existing_inv.data[0]["id"]).execute()

            logger.info(f"[Inventory] Updated {req.ingredient_name} qty: {old_qty} → {new_qty}")
            return {
                "status": "updated",
                "ingredient_id": ingredient_id,
                "message": f"Updated {req.ingredient_name} quantity to {new_qty}",
            }
        else:
            # Insert new inventory item
            db.table("inventory_items").insert({
                "user_id": req.user_id,
                "ingredient_id": ingredient_id,
                "quantity": req.quantity,
                "unit": req.unit,
                "location": location,
                "manual_expiry_date": expiry,
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


class UpdateItemRequest(BaseModel):
    quantity: Optional[float] = None
    unit: Optional[str] = None
    item_state: Optional[str] = None
    location: Optional[str] = None
    notes: Optional[str] = None


@router.patch("/api/v1/inventory/{item_id}")
async def update_inventory_item(item_id: str, req: UpdateItemRequest):
    """Update an inventory item's properties."""
    db = get_supabase()

    try:
        update_data = {}
        if req.quantity is not None:
            update_data["quantity"] = req.quantity
        if req.unit is not None:
            update_data["unit"] = req.unit
        if req.item_state is not None:
            update_data["item_state"] = req.item_state
        if req.location is not None:
            update_data["location"] = req.location
        if req.notes is not None:
            update_data["notes"] = req.notes

        if not update_data:
            return {"status": "no_changes"}

        db.table("inventory_items").update(update_data).eq("id", item_id).execute()

        logger.info(f"[Inventory] Updated item {item_id}")
        return {"status": "success"}

    except Exception as e:
        logger.error(f"[Inventory] Update failed: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.delete("/api/v1/inventory/{item_id}")
async def delete_inventory_item(item_id: str):
    """Delete an inventory item."""
    db = get_supabase()

    try:
        db.table("inventory_items").delete().eq("id", item_id).execute()
        logger.info(f"[Inventory] Deleted item {item_id}")
        return {"status": "success"}

    except Exception as e:
        logger.error(f"[Inventory] Delete failed: {e}")
        raise HTTPException(status_code=500, detail=str(e))


class ConsumeItemRequest(BaseModel):
    inventory_id: str
    quantity_to_consume: float


@router.post("/api/v1/inventory/consume")
async def consume_inventory_item(req: ConsumeItemRequest):
    """
    Consume (decrement) an inventory item's quantity.
    Uses the consume_inventory_item RPC which auto-deletes at 0.
    """
    db = get_supabase()

    try:
        db.rpc(
            "consume_inventory_item",
            {
                "p_inventory_id": req.inventory_id,
                "p_qty_to_consume": req.quantity_to_consume,
            },
        ).execute()

        logger.info(
            f"[Inventory] Consumed {req.quantity_to_consume} from {req.inventory_id}"
        )
        return {"status": "success"}

    except Exception as e:
        logger.error(f"[Inventory] Consume failed: {e}")
        raise HTTPException(status_code=500, detail=str(e))

