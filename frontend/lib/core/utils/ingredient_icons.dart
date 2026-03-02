/// I-Fridge — Ingredient Icons
/// ==============================
/// Maps ingredient canonical names and categories to emojis.
/// Provides per-ingredient icons (preferred) with category fallback.

class IngredientIcons {
  IngredientIcons._();

  // ── Per-Ingredient Emoji Map ───────────────────────────────
  static const Map<String, String> _ingredientEmoji = {
    // Vegetables
    'potato': '🥔',
    'carrot': '🥕',
    'onion': '🧅',
    'garlic': '🧄',
    'peas': '🫛',
    'tomato': '🍅',
    'tomato paste': '🍅',
    'broccoli': '🥦',
    'corn': '🌽',
    'lettuce': '🥬',
    'cucumber': '🥒',
    'eggplant': '🍆',
    'mushroom': '🍄',
    'bell pepper': '🫑',
    'hot pepper': '🌶️',
    'avocado': '🥑',

    // Protein
    'egg': '🥚',
    'chicken': '🍗',
    'beef': '🥩',
    'pork': '🥓',
    'fish': '🐟',
    'shrimp': '🦐',

    // Grains
    'rice': '🍚',
    'bread': '🍞',
    'pasta': '🍝',

    // Dairy
    'milk': '🥛',
    'butter': '🧈',
    'cheese': '🧀',

    // Baking
    'flour': '🌾',
    'sugar': '🍬',
    'baking soda': '🧂',

    // Seasoning / Condiment
    'salt': '🧂',
    'black pepper': '🫚',
    'soy sauce': '🫘',
    'cooking oil': '🫒',
    'olive oil': '🫒',
    'honey': '🍯',
    'vinegar': '🫗',

    // Legumes
    'beans': '🫘',
    'lentils': '🫘',

    // Beverages
    'coffee': '☕',
    'tea': '🍵',

    // Fruits
    'apple': '🍎',
    'banana': '🍌',
    'orange': '🍊',
    'lemon': '🍋',
    'strawberry': '🍓',
    'blueberry': '🫐',
    'grape': '🍇',
    'watermelon': '🍉',
    'peach': '🍑',
    'pineapple': '🍍',
    'cherry': '🍒',
    'mango': '🥭',
    'coconut': '🥥',
    'kiwi': '🥝',
    'pear': '🍐',
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
    'beverage': '☕',
    'snack': '🍿',
    'seafood': '🦐',
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
