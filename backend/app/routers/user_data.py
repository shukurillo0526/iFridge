"""
I-Fridge — User Data API Router
=================================
Centralized backend for all user-scoped data operations.
Uses the service role key to bypass RLS for writes.
"""

import logging
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional, List

from app.db.supabase_client import get_supabase

logger = logging.getLogger("ifridge.user_data")

router = APIRouter(prefix="/api/v1/user", tags=["User Data"])


# ── Request Models ────────────────────────────────────────────

class InitUserRequest(BaseModel):
    user_id: str
    email: str
    display_name: Optional[str] = None


class UpdateProfileRequest(BaseModel):
    user_id: str
    display_name: Optional[str] = None
    dietary_tags: Optional[List[str]] = None
    avatar_url: Optional[str] = None


class ShoppingItemRequest(BaseModel):
    user_id: str
    ingredient_name: str
    quantity: float = 1.0
    unit: str = "pcs"


class ToggleShoppingRequest(BaseModel):
    is_purchased: bool


class MealPlanRequest(BaseModel):
    user_id: str
    recipe_id: str
    planned_date: str  # ISO date string YYYY-MM-DD
    meal_type: str = "dinner"


# ── Endpoints ─────────────────────────────────────────────────

@router.post("/init")
async def init_user(req: InitUserRequest):
    """
    Atomically initialize a new user's profile rows.
    Creates users, gamification_stats, and user_flavor_profile.
    Idempotent — safe to call multiple times.
    """
    db = get_supabase()

    try:
        name = req.display_name or req.email.split("@")[0]

        # 1. Upsert users row
        db.table("users").upsert(
            {
                "id": req.user_id,
                "email": req.email,
                "display_name": name,
            },
            on_conflict="id",
        ).execute()

        # 2. Upsert gamification_stats
        db.table("gamification_stats").upsert(
            {"user_id": req.user_id},
            on_conflict="user_id",
        ).execute()

        # 3. Upsert user_flavor_profile
        db.table("user_flavor_profile").upsert(
            {"user_id": req.user_id},
            on_conflict="user_id",
        ).execute()

        logger.info(f"[User] Initialized user {req.user_id}")
        return {"status": "success", "user_id": req.user_id}

    except Exception as e:
        logger.error(f"[User] Init failed: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/{user_id}/dashboard")
async def get_dashboard(user_id: str):
    """
    Single endpoint returning all user profile data.
    Replaces 5 parallel queries from the Profile screen.
    """
    db = get_supabase()

    try:
        # Parallel-safe: all reads, no conflicts
        user_res = (
            db.table("users")
            .select("display_name, email, avatar_url, dietary_tags, household_size")
            .eq("id", user_id)
            .limit(1)
            .execute()
        )

        stats_res = (
            db.table("gamification_stats")
            .select("*")
            .eq("user_id", user_id)
            .limit(1)
            .execute()
        )

        flavor_res = (
            db.table("user_flavor_profile")
            .select("sweet, salty, sour, bitter, umami, spicy, preferred_cuisines")
            .eq("user_id", user_id)
            .limit(1)
            .execute()
        )

        shopping_res = (
            db.table("shopping_list")
            .select("id, ingredient_name, quantity, unit, is_purchased, created_at")
            .eq("user_id", user_id)
            .order("created_at")
            .execute()
        )

        # Get today's date for meal plan window
        from datetime import date
        today = date.today().isoformat()

        meal_res = (
            db.table("meal_plan")
            .select("id, planned_date, meal_type, notes, recipe_id, recipes(title)")
            .eq("user_id", user_id)
            .gte("planned_date", today)
            .order("planned_date")
            .limit(14)
            .execute()
        )

        return {
            "user": user_res.data[0] if user_res.data else None,
            "stats": stats_res.data[0] if stats_res.data else None,
            "flavor_profile": flavor_res.data[0] if flavor_res.data else None,
            "shopping_list": shopping_res.data or [],
            "meal_plan": meal_res.data or [],
        }

    except Exception as e:
        logger.error(f"[User] Dashboard load failed: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.patch("/profile")
async def update_profile(req: UpdateProfileRequest):
    """Update user profile fields."""
    db = get_supabase()

    try:
        update_data = {}
        if req.display_name is not None:
            update_data["display_name"] = req.display_name
        if req.dietary_tags is not None:
            update_data["dietary_tags"] = req.dietary_tags
        if req.avatar_url is not None:
            update_data["avatar_url"] = req.avatar_url

        if not update_data:
            return {"status": "no_changes"}

        db.table("users").update(update_data).eq("id", req.user_id).execute()

        logger.info(f"[User] Profile updated for {req.user_id}")
        return {"status": "success"}

    except Exception as e:
        logger.error(f"[User] Profile update failed: {e}")
        raise HTTPException(status_code=500, detail=str(e))


# ── Shopping List ─────────────────────────────────────────────

@router.post("/shopping-list")
async def add_shopping_item(req: ShoppingItemRequest):
    """Add an item to the shopping list."""
    db = get_supabase()

    try:
        res = db.table("shopping_list").insert({
            "user_id": req.user_id,
            "ingredient_name": req.ingredient_name,
            "quantity": req.quantity,
            "unit": req.unit,
            "is_purchased": False,
        }).execute()

        item = res.data[0] if res.data else {}
        return {"status": "success", "id": item.get("id")}

    except Exception as e:
        logger.error(f"[Shopping] Add failed: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.patch("/shopping-list/{item_id}")
async def toggle_shopping_item(item_id: str, req: ToggleShoppingRequest):
    """Toggle purchased status of a shopping list item."""
    db = get_supabase()

    try:
        db.table("shopping_list").update({
            "is_purchased": req.is_purchased,
        }).eq("id", item_id).execute()

        return {"status": "success"}

    except Exception as e:
        logger.error(f"[Shopping] Toggle failed: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.delete("/shopping-list/{item_id}")
async def delete_shopping_item(item_id: str):
    """Delete a shopping list item."""
    db = get_supabase()

    try:
        db.table("shopping_list").delete().eq("id", item_id).execute()
        return {"status": "success"}

    except Exception as e:
        logger.error(f"[Shopping] Delete failed: {e}")
        raise HTTPException(status_code=500, detail=str(e))


# ── Meal Plan ─────────────────────────────────────────────────

@router.post("/meal-plan")
async def add_meal_plan(req: MealPlanRequest):
    """Plan a recipe for a specific date."""
    db = get_supabase()

    try:
        res = db.table("meal_plan").upsert(
            {
                "user_id": req.user_id,
                "recipe_id": req.recipe_id,
                "planned_date": req.planned_date,
                "meal_type": req.meal_type,
            },
            on_conflict="user_id,planned_date,meal_type",
        ).execute()

        item = res.data[0] if res.data else {}
        return {"status": "success", "id": item.get("id")}

    except Exception as e:
        logger.error(f"[MealPlan] Add failed: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.delete("/meal-plan/{meal_id}")
async def delete_meal_plan(meal_id: str):
    """Remove a planned meal."""
    db = get_supabase()

    try:
        db.table("meal_plan").delete().eq("id", meal_id).execute()
        return {"status": "success"}

    except Exception as e:
        logger.error(f"[MealPlan] Delete failed: {e}")
        raise HTTPException(status_code=500, detail=str(e))


# ── Cook Tracking (with flavor auto-learning) ─────────────────

class RecordCookRequest(BaseModel):
    user_id: str
    recipe_id: str


@router.post("/cook")
async def record_cook(req: RecordCookRequest):
    """
    Record that the user cooked a recipe.
    
    This triggers two things:
    1. Adds an entry to user_recipe_history (for recency signal)
    2. Updates the user's flavor profile via EMA blending (for better recommendations)
    
    The flavor profile shifts by 15% toward the recipe's flavor vector each time.
    """
    from app.services.flavor_learning import record_cook_event
    
    result = await record_cook_event(req.user_id, req.recipe_id)
    return result


# ── Video Engagement Tracking ─────────────────────────────────

class VideoEngagementRequest(BaseModel):
    user_id: str
    video_id: str
    action: str  # "like", "unlike", "save", "unsave", "view"


@router.post("/engagement")
async def track_engagement(req: VideoEngagementRequest):
    """
    Persist video engagement actions (likes, saves, views).
    
    - like/unlike: toggles the liked state in user_video_engagement
    - save/unsave: toggles the saved state
    - view: increments view count (no toggle)
    """
    db = get_supabase()
    
    try:
        if req.action == "view":
            # Upsert view count
            db.table("user_video_engagement").upsert(
                {
                    "user_id": req.user_id,
                    "video_id": req.video_id,
                    "view_count": 1,
                },
                on_conflict="user_id,video_id",
            ).execute()
            
            # Also try incrementing via RPC if available
            try:
                db.rpc("increment_video_views", {
                    "p_video_id": req.video_id,
                }).execute()
            except Exception:
                pass  # RPC not set up yet
                
            return {"status": "success"}
        
        # Like / Save toggles
        update_field = None
        update_value = None
        
        if req.action == "like":
            update_field = "is_liked"
            update_value = True
        elif req.action == "unlike":
            update_field = "is_liked"
            update_value = False
        elif req.action == "save":
            update_field = "is_saved"
            update_value = True
        elif req.action == "unsave":
            update_field = "is_saved"
            update_value = False
        else:
            raise HTTPException(status_code=400, detail=f"Unknown action: {req.action}")
        
        db.table("user_video_engagement").upsert(
            {
                "user_id": req.user_id,
                "video_id": req.video_id,
                update_field: update_value,
            },
            on_conflict="user_id,video_id",
        ).execute()
        
        return {"status": "success", "action": req.action}
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"[Engagement] Track failed: {e}")
        raise HTTPException(status_code=500, detail=str(e))
