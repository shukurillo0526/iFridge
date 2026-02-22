import httpx
from fastapi import APIRouter, HTTPException

router = APIRouter()

@router.get("/api/v1/product/{barcode}")
async def lookup_barcode(barcode: str):
    """
    Look up a product by barcode using the Open Food Facts API.
    Returns structured data matching the MVP inventory item schema.
    """
    url = f"https://world.openfoodfacts.org/api/v2/product/{barcode}.json"
    
    async with httpx.AsyncClient() as client:
        response = await client.get(url)
        
        if response.status_code != 200:
            raise HTTPException(status_code=404, detail="Product not found in Open Food Facts database.")
            
        data = response.json()
        
        if data.get("status") != 1:
            raise HTTPException(status_code=404, detail="Product not found.")
            
        product = data.get("product", {})
        
        # Extract helpful fields
        product_name = product.get("product_name_en") or product.get("product_name") or "Unknown Product"
        brands = product.get("brands", "Unknown Brand")
        categories = product.get("categories", "Pantry")
        image_url = product.get("image_front_url", "")
        
        # Infer a simple category for the heuristic engine
        category_lower = categories.lower()
        if "dairy" in category_lower or "milk" in category_lower or "cheese" in category_lower:
            simple_category = "Dairy"
        elif "meat" in category_lower or "beef" in category_lower or "chicken" in category_lower:
            simple_category = "Meat"
        elif "vegetable" in category_lower or "fruit" in category_lower:
            simple_category = "Produce"
        else:
            simple_category = "Pantry"
            
        return {
            "canonical_name": f"{brands} {product_name}".strip(),
            "category": simple_category,
            "image_url": image_url,
            "source": "open_food_facts"
        }
