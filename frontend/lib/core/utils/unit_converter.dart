/// I-Fridge — Unit Converter
/// =============================
/// Converts between ingredient measurement units using the
/// `unit_conversions` JSONB data from the ingredients table.
///
/// Usage:
///   final converter = UnitConverter(conversions);
///   final grams = converter.toGrams(2, 'cup');    // 370g for rice
///   final display = converter.humanize(200, 'g');  // "≈ 1⅓ cups"
library;

class UnitConverter {
  final Map<String, dynamic> _conversions;

  UnitConverter(this._conversions);

  /// Convert a quantity in the given unit to grams.
  /// Returns null if no conversion is available.
  double? toGrams(double quantity, String unit) {
    final key = '${unit.toLowerCase()}_to_g';
    final mlKey = '${unit.toLowerCase()}_to_ml';

    if (_conversions.containsKey(key)) {
      return quantity * (_conversions[key] as num).toDouble();
    }
    // ml ≈ g for most liquids
    if (_conversions.containsKey(mlKey)) {
      return quantity * (_conversions[mlKey] as num).toDouble();
    }
    // Already grams
    if (unit.toLowerCase() == 'g') return quantity;
    if (unit.toLowerCase() == 'kg') return quantity * 1000;
    if (unit.toLowerCase() == 'ml') return quantity; // approx
    if (unit.toLowerCase() == 'l') return quantity * 1000;

    return null;
  }

  /// Convert grams to a given unit.
  double? fromGrams(double grams, String targetUnit) {
    final key = '${targetUnit.toLowerCase()}_to_g';
    final mlKey = '${targetUnit.toLowerCase()}_to_ml';

    if (_conversions.containsKey(key)) {
      return grams / (_conversions[key] as num).toDouble();
    }
    if (_conversions.containsKey(mlKey)) {
      return grams / (_conversions[mlKey] as num).toDouble();
    }
    if (targetUnit.toLowerCase() == 'g') return grams;
    if (targetUnit.toLowerCase() == 'kg') return grams / 1000;

    return null;
  }

  /// Scale a recipe quantity.
  static double scale(double original, int originalServings, int newServings) {
    if (originalServings <= 0) return original;
    return (original / originalServings) * newServings;
  }

  /// Format a quantity for display.
  /// Handles fractions: 0.25 → "¼", 0.5 → "½", 1.333 → "1⅓"
  static String formatQuantity(double qty) {
    if (qty <= 0) return '0';

    final whole = qty.floor();
    final frac = qty - whole;

    String fracStr = '';
    if (frac >= 0.875) {
      return '${whole + 1}';
    } else if (frac >= 0.7) {
      fracStr = '¾';
    } else if (frac >= 0.58) {
      fracStr = '⅔';
    } else if (frac >= 0.4) {
      fracStr = '½';
    } else if (frac >= 0.29) {
      fracStr = '⅓';
    } else if (frac >= 0.2) {
      fracStr = '¼';
    } else if (frac >= 0.1) {
      fracStr = '⅛';
    }

    if (whole == 0 && fracStr.isNotEmpty) return fracStr;
    if (fracStr.isEmpty) {
      // Clean decimal: 2.0 → "2", 1.5 → handled above
      return qty == qty.roundToDouble()
          ? qty.toInt().toString()
          : qty.toStringAsFixed(1);
    }
    return '$whole$fracStr';
  }

  /// Simplify metric units for display (e.g. 2500g -> 2.5kg, 0.5L -> 500ml)
  static String simplifyMetric(double qty, String unit) {
    if (qty <= 0) return '';
    
    final u = unit.toLowerCase();
    
    if (qty >= 1000 && u == 'g') {
      return '${formatQuantity(qty / 1000)} kg';
    }
    if (qty >= 1000 && u == 'ml') {
      return '${formatQuantity(qty / 1000)} L';
    }
    if (qty < 1 && u == 'kg') {
      return '${formatQuantity(qty * 1000)} g';
    }
    if (qty < 1 && u == 'l') {
      return '${formatQuantity(qty * 1000)} ml';
    }
    
    final displayUnit = (u == 'pcs' || u == 'pack' || u == 'bunch') ? '' : ' $unit';
    return '${formatQuantity(qty)}$displayUnit'.trim();
  }

  /// Generate a human-readable hint for a quantity.
  /// e.g., "200g onion" → "≈ 1⅓ medium onions"
  String? humanHint(double quantity, String unit) {
    // Try converting to pieces for whole items
    if (unit.toLowerCase() == 'g' && _conversions.containsKey('piece_to_g')) {
      final pieceWeight = (_conversions['piece_to_g'] as num).toDouble();
      final pieces = quantity / pieceWeight;
      return '≈ ${formatQuantity(pieces)} piece${pieces > 1 ? 's' : ''}';
    }
    // Try converting g to cups for dry ingredients
    if (unit.toLowerCase() == 'g' && _conversions.containsKey('cup_to_g')) {
      final cupWeight = (_conversions['cup_to_g'] as num).toDouble();
      final cups = quantity / cupWeight;
      if (cups >= 0.2) {
        return '≈ ${formatQuantity(cups)} cup${cups > 1 ? 's' : ''}';
      }
    }
    return null;
  }

  /// Check if user has enough of an ingredient.
  /// Returns true if owned >= needed (after unit conversion).
  bool hasEnough({
    required double ownedQty,
    required String ownedUnit,
    required double neededQty,
    required String neededUnit,
  }) {
    // Same unit → direct comparison
    if (ownedUnit.toLowerCase() == neededUnit.toLowerCase()) {
      return ownedQty >= neededQty;
    }

    // Convert both to grams and compare
    final ownedGrams = toGrams(ownedQty, ownedUnit);
    final neededGrams = toGrams(neededQty, neededUnit);

    if (ownedGrams != null && neededGrams != null) {
      return ownedGrams >= neededGrams;
    }

    // Can't convert — assume not enough
    return false;
  }
}
