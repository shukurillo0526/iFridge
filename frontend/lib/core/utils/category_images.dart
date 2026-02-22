// iFridge — Category Image Mapping
// =================================
// Maps ingredient categories to representative stock images.
// Used as a fallback when an ingredient has no individual image_url.
// All images are free-to-use from Unsplash/Pexels via direct URLs.

/// Returns a network image URL representing the given category.
/// Falls back to a generic fresh food image if category is unknown.
String categoryImageUrl(String? category) {
  final cat = (category ?? '').toLowerCase().trim();
  return _categoryImages[cat] ?? _categoryImages['default']!;
}

/// Category emoji for minimal/offline fallback.
String categoryEmoji(String? category) {
  final cat = (category ?? '').toLowerCase().trim();
  return _categoryEmojis[cat] ?? '🍽️';
}

// ── Image URLs ──────────────────────────────────────────────────
// Using high-quality, royalty-free images resized to 400px wide.

const _categoryImages = <String, String>{
  'produce':    'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=400&q=80',
  'vegetable':  'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=400&q=80',
  'fruit':      'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=400&q=80',
  'meat':       'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=400&q=80',
  'seafood':    'https://images.unsplash.com/photo-1615141982883-c7ad0e69fd62?w=400&q=80',
  'poultry':    'https://images.unsplash.com/photo-1604503468506-a8da13d82571?w=400&q=80',
  'dairy':      'https://images.unsplash.com/photo-1628088062854-d1870b4553da?w=400&q=80',
  'milk':       'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=400&q=80',
  'eggs':       'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=400&q=80',
  'bakery':     'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400&q=80',
  'bread':      'https://images.unsplash.com/photo-1549931319-a545753467c8?w=400&q=80',
  'grain':      'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400&q=80',
  'pasta':      'https://images.unsplash.com/photo-1551462147-37885acc36f1?w=400&q=80',
  'pantry':     'https://images.unsplash.com/photo-1584568694244-14fbdf83bd30?w=400&q=80',
  'canned':     'https://images.unsplash.com/photo-1534483509719-3feaee7c30da?w=400&q=80',
  'frozen':     'https://images.unsplash.com/photo-1584568694244-14fbdf83bd30?w=400&q=80',
  'beverage':   'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=400&q=80',
  'juice':      'https://images.unsplash.com/photo-1621506289937-a8e4df240d0b?w=400&q=80',
  'snack':      'https://images.unsplash.com/photo-1621939514649-280e2ee25f60?w=400&q=80',
  'condiment':  'https://images.unsplash.com/photo-1472476443507-c7a5948772fc?w=400&q=80',
  'spice':      'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?w=400&q=80',
  'oil':        'https://images.unsplash.com/photo-1474979266404-7eaacdc64d28?w=400&q=80',
  'sauce':      'https://images.unsplash.com/photo-1472476443507-c7a5948772fc?w=400&q=80',
  'nuts':       'https://images.unsplash.com/photo-1599599810769-bcde5a160d32?w=400&q=80',
  'legumes':    'https://images.unsplash.com/photo-1515543904279-3f9980e35ec3?w=400&q=80',
  'tofu':       'https://images.unsplash.com/photo-1628557044797-f21a177c37ec?w=400&q=80',
  'protein':    'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=400&q=80',
  'default':    'https://images.unsplash.com/photo-1606787366850-de6330128bfc?w=400&q=80',
};

const _categoryEmojis = <String, String>{
  'produce':    '🥬',
  'vegetable':  '🥕',
  'fruit':      '🍎',
  'meat':       '🥩',
  'seafood':    '🐟',
  'poultry':    '🍗',
  'dairy':      '🧀',
  'milk':       '🥛',
  'eggs':       '🥚',
  'bakery':     '🥐',
  'bread':      '🍞',
  'grain':      '🌾',
  'pasta':      '🍝',
  'pantry':     '🫙',
  'canned':     '🥫',
  'frozen':     '🧊',
  'beverage':   '🥤',
  'juice':      '🧃',
  'snack':      '🍿',
  'condiment':  '🫗',
  'spice':      '🌶️',
  'oil':        '🫒',
  'sauce':      '🥫',
  'nuts':       '🥜',
  'legumes':    '🫘',
  'tofu':       '🧈',
  'protein':    '🥩',
};
