import json
import os

keys = {
    "myFridge": "🧊 My Fridge",
    "expiryAlerts": "Expiry alerts",
    "errorLoadInventory": "Couldn't load inventory",
    "errorCheckConnection": "Check your connection and try again.",
    "total": "Total",
    "fresh": "Fresh",
    "expiring": "Expiring",
    "expired": "Expired",
    "searchIngredients": "Search ingredients...",
    "all": "All",
    "itemsCount": "{count} items",
    "zoneEmptyTitle": "Your {zone} is Empty",
    "zoneEmptyDesc": "Ready to fill up your digital kitchen.\nAdd items manually or tap scan.",
    "addIngredient": "Add Ingredient",
    "urgentCook": "Cook Now",
    "urgentUse": "Use {ingredient}",
    "noItemsMatch": "No items match your filters",
    "clearFilters": "Clear filters",
    "expiryAlertsTitle": "🔔 Expiry Alerts",
    "allFresh": "All items are fresh! 🎉",
    "expiredCount": "❌ Expired ({count})",
    "expiringSoonCount": "⚠️ Expiring Soon ({count})",
}

l10n_dir = r"d:\dev\projects\iFridge\frontend\lib\l10n"

for lang in ["en", "ko", "ru", "uz", "uz_Cyrl"]:
    path = os.path.join(l10n_dir, f"app_{lang}.arb")
    with open(path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    for k, v in keys.items():
        if k not in data:
            data[k] = v
            # If placeholders are needed:
            if "{" in v:
                ph = {}
                if "{count}" in v: ph["count"] = {"type": "int"}
                if "{zone}" in v: ph["zone"] = {"type": "String"}
                if "{ingredient}" in v: ph["ingredient"] = {"type": "String"}
                if ph:
                    data[f"@{k}"] = {"placeholders": ph}
                    
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=4, ensure_ascii=False)
