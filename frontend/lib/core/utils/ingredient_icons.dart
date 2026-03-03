/// I-Fridge — Ingredient Icons
/// ==============================
/// Maps ingredient canonical names and categories to emojis.
/// Provides per-ingredient icons (preferred) with category fallback.
/// 220+ ingredients covered.

class IngredientIcons {
  IngredientIcons._();

  // ── Per-Ingredient Emoji Map ───────────────────────────────
  static const Map<String, String> _ingredientEmoji = {
    // ── Vegetables ──
    'potato': '🥔', 'sweet potato': '🍠', 'carrot': '🥕',
    'onion': '🧅', 'green onion': '🧅', 'leek': '🧅',
    'garlic': '🧄', 'ginger': '🫚',
    'tomato': '🍅', 'tomato paste': '🍅',
    'bell pepper': '🫑', 'hot pepper': '🌶️', 'jalapeno': '🌶️',
    'korean chili pepper': '🌶️',
    'broccoli': '🥦', 'cauliflower': '🥦',
    'corn': '🌽', 'lettuce': '🥬', 'spinach': '🥬', 'kale': '🥬',
    'cabbage': '🥬', 'cucumber': '🥒', 'zucchini': '🥒',
    'eggplant': '🍆', 'mushroom': '🍄',
    'avocado': '🥑', 'peas': '🫛', 'green bean': '🫛',
    'celery': '🥬', 'asparagus': '🥦',
    'beet': '🫒', 'radish': '🫒', 'turnip': '🫒', 'parsnip': '🥕',
    'daikon': '🫒', 'pumpkin': '🎃',
    'bean sprouts': '🌱', 'bamboo shoots': '🎋',
    'artichoke': '🥦', 'fennel': '🌿', 'okra': '🫑',

    // ── Protein ──
    'egg': '🥚', 'quail egg': '🥚',
    'chicken': '🍗', 'chicken breast': '🍗', 'chicken thigh': '🍗',
    'chicken wing': '🍗', 'turkey': '🦃', 'duck': '🦆',
    'beef': '🥩', 'beef ground': '🥩', 'ground beef': '🥩',
    'beef steak': '🥩', 'lamb': '🥩',
    'pork': '🥓', 'pork belly': '🥓', 'bacon': '🥓',
    'sausage': '🌭', 'ham': '🍖',
    'tofu': '🧊',

    // ── Seafood ──
    'fish': '🐟', 'salmon': '🍣', 'tuna': '🐟', 'cod': '🐟',
    'mackerel': '🐟', 'sardine': '🐟', 'anchovy': '🐟',
    'shrimp': '🦐', 'crab': '🦀', 'squid': '🦑', 'octopus': '🐙',
    'clam': '🦪', 'mussel': '🦪', 'seaweed': '🌿',

    // ── Dairy ──
    'milk': '🥛', 'cream': '🥛', 'heavy cream': '🥛',
    'sour cream': '🥛', 'condensed milk': '🥛',
    'yogurt': '🥛', 'butter': '🧈',
    'cheese': '🧀', 'mozzarella': '🧀', 'parmesan': '🧀',
    'cream cheese': '🧀', 'feta': '🧀',
    'whipped cream': '🍦',

    // ── Grains ──
    'rice': '🍚', 'brown rice': '🍚', 'basmati rice': '🍚',
    'glutinous rice': '🍚',
    'bread': '🍞', 'naan': '🫓', 'tortilla': '🫓',
    'pasta': '🍝', 'spaghetti': '🍝', 'penne': '🍝',
    'ramen noodles': '🍜', 'rice noodles': '🍜', 'udon': '🍜',
    'oats': '🌾', 'quinoa': '🌾', 'couscous': '🌾',
    'breadcrumbs': '🍞', 'cornstarch': '🌽',

    // ── Baking ──
    'flour': '🌾', 'whole wheat flour': '🌾',
    'sugar': '🍬', 'brown sugar': '🍬', 'powdered sugar': '🍬',
    'honey': '🍯', 'maple syrup': '🍯',
    'baking soda': '🧂', 'baking powder': '🧂',
    'yeast': '🧫', 'vanilla extract': '🧴',
    'cocoa powder': '🍫', 'chocolate': '🍫',
    'gelatin': '🍮',

    // ── Spices & Herbs ──
    'salt': '🧂', 'black pepper': '🫚', 'white pepper': '🫚',
    'cumin': '🫙', 'paprika': '🫙', 'turmeric': '🫙',
    'cinnamon': '🫙', 'nutmeg': '🫙', 'curry powder': '🫙',
    'oregano': '🌿', 'basil': '🌿', 'parsley': '🌿',
    'cilantro': '🌿', 'rosemary': '🌿', 'thyme': '🌿',
    'bay leaf': '🍃', 'dill': '🌿', 'mint': '🌿',
    'chili flakes': '🌶️', 'korean chili flakes': '🌶️',
    'five spice': '🫙', 'msg': '🧂',
    'cardamom': '🫙', 'star anise': '⭐', 'clove': '🫙',
    'coriander': '🫙',

    // ── Condiments ──
    'soy sauce': '🫘', 'fish sauce': '🐟', 'oyster sauce': '🦪',
    'sesame oil': '🫒', 'vinegar': '🫗', 'rice vinegar': '🫗',
    'ketchup': '🍅', 'mustard': '🟡', 'mayonnaise': '🥚',
    'hot sauce': '🌶️', 'sriracha': '🌶️',
    'gochujang': '🫙', 'doenjang': '🫙', 'miso': '🫙',
    'tahini': '🫘', 'peanut butter': '🥜',
    'barbecue sauce': '🍖', 'worcestershire': '🫗',
    'cooking oil': '🫒', 'olive oil': '🫒',

    // ── Fruits ──
    'apple': '🍎', 'banana': '🍌', 'orange': '🍊',
    'lemon': '🍋', 'lime': '🍋', 'strawberry': '🍓',
    'blueberry': '🫐', 'raspberry': '🫐', 'grape': '🍇',
    'watermelon': '🍉', 'melon': '🍈',
    'peach': '🍑', 'plum': '🍑', 'pineapple': '🍍',
    'mango': '🥭', 'coconut': '🥥', 'kiwi': '🥝',
    'pear': '🍐', 'cherry': '🍒', 'fig': '🫒',
    'date': '🫒', 'raisin': '🍇',
    'pomegranate': '🫒', 'coconut milk': '🥥',

    // ── Nuts & Seeds ──
    'almond': '🥜', 'walnut': '🥜', 'cashew': '🥜',
    'pistachio': '🥜', 'peanut': '🥜', 'pine nut': '🥜',
    'sesame seed': '🥜', 'sesame seeds': '🥜',
    'sunflower seed': '🌻', 'sunflower seeds': '🌻',
    'flax seed': '🥜', 'chia seed': '🥜',

    // ── Legumes ──
    'beans': '🫘', 'black bean': '🫘', 'kidney bean': '🫘',
    'chickpea': '🫘', 'lentil': '🫘', 'lentils': '🫘',
    'green lentil': '🫘', 'red lentil': '🫘',
    'edamame': '🫛', 'mung bean': '🫘',

    // ── Oils ──
    'sunflower oil': '🌻', 'coconut oil': '🥥',
    'canola oil': '🫒', 'avocado oil': '🥑',

    // ── Beverages ──
    'coffee': '☕', 'tea': '🍵', 'green tea': '🍵',
    'orange juice': '🍊', 'apple juice': '🍎',
    'lemon juice': '🍋', 'wine': '🍷', 'beer': '🍺',
    'rice wine': '🍶',
  };

  // ── Category Fallback Emoji Map ──────────────────────────
  static const Map<String, String> _categoryEmoji = {
    'vegetable': '🥬',
    'fruit': '🍎',
    'protein': '🥩',
    'meat': '🥩',
    'dairy': '🧀',
    'grain': '🌾',
    'baking': '🧁',
    'seasoning': '🧂',
    'condiment': '🫗',
    'oil': '🫒',
    'legume': '🫘',
    'nut': '🥜',
    'seafood': '🦐',
    'beverage': '☕',
    'snack': '🍿',
    'frozen': '🧊',
    'other': '🍽️',
  };

  /// Returns the best emoji for an ingredient.
  /// Priority: exact name match → category fallback → default.
  static String getEmoji(String name, {String? category}) {
    final key = name.trim().toLowerCase();

    // 1. Exact ingredient match
    if (_ingredientEmoji.containsKey(key)) {
      return _ingredientEmoji[key]!;
    }

    // 2. Partial match (e.g., "Chicken breast" → "chicken")
    for (final entry in _ingredientEmoji.entries) {
      if (key.contains(entry.key) || entry.key.contains(key)) {
        return entry.value;
      }
    }

    // 3. Category fallback
    if (category != null) {
      final catKey = category.trim().toLowerCase();
      if (_categoryEmoji.containsKey(catKey)) {
        return _categoryEmoji[catKey]!;
      }
    }

    // 4. Default
    return '🍽️';
  }
}
