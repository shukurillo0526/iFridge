import os
import re

path = r'd:\dev\projects\iFridge\frontend\lib\features\cook\presentation\screens\recipe_detail_screen.dart'
with open(path, 'r', encoding='utf-8') as f: content = f.read()

# 1. Imports
if "import 'dart:convert';" not in content:
    content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'dart:convert';\nimport 'package:shared_preferences/shared_preferences.dart';")

# 2. State variables
content = content.replace(
    "List<Map<String, dynamic>> _steps = [];",
    "List<Map<String, dynamic>> _steps = [];\n  String _displayTitle = '';\n  String? _displayDescription;"
)

# 3. Add translation logic to _loadDetails
old_load = """      setState(() {
        _ingredients = List<Map<String, dynamic>>.from(ingredientRows);
        _steps = List<Map<String, dynamic>>.from(stepRows);
        _loading = false;
      });"""

new_load = """      _ingredients = List<Map<String, dynamic>>.from(ingredientRows);
      _steps = List<Map<String, dynamic>>.from(stepRows);
      _displayTitle = widget.title;
      _displayDescription = widget.description;

      // 1. Detect language
      final userLanguage = Localizations.localeOf(context).languageCode;
      
      // If not English, translate & cache
      if (userLanguage != 'en') {
        try {
          final prefs = await SharedPreferences.getInstance();
          final cacheKey = 'translation_${widget.recipeId}_$userLanguage';
          final cached = prefs.getString(cacheKey);

          if (cached != null) {
            final data = jsonDecode(cached);
            _applyTranslation(data);
          } else {
            // Build text payload
            final ingText = _ingredients.map((i) {
              final name = (i['ingredients'] as Map?)?['display_name_en'] ?? 'Unknown';
              final qty = i['quantity'] ?? '';
              final unit = i['unit'] ?? '';
              return "- $qty $unit $name";
            }).join('\\n');

            final stepsText = _steps.map((s) {
              final num = s['step_number'] ?? 0;
              final text = s['human_text'] ?? '';
              return "$num. $text";
            }).join('\\n');

            final api = ApiService();
            final response = await api.translateRecipe(
              title: widget.title,
              ingredients: ingText,
              steps: stepsText,
              targetLanguage: userLanguage,
            );

            if (response['status'] == 'success') {
              final data = response['data'] as Map<String, dynamic>;
              prefs.setString(cacheKey, jsonEncode(data));
              _applyTranslation(data);
            }
          }
        } catch (e) {
          debugPrint('Translation failed: $e');
        }
      }

      setState(() {
        _loading = false;
      });"""

content = content.replace(old_load, new_load)

# 4. Add _applyTranslation method
apply_translation = """
  void _applyTranslation(Map<String, dynamic> data) {
    setState(() {
      if (data['title'] != null) _displayTitle = data['title'];
      // The AI returns a string of ingredients and steps. We need to parse them back.
      // But it's easier to just use the original lists and replace their text if they match line by line.
      
      try {
        final ingLines = (data['ingredients'] as String).split('\\n');
        for (int i = 0; i < _ingredients.length && i < ingLines.length; i++) {
            // Replace the display name temporarily by injecting a translated_name field
            _ingredients[i]['translated_name'] = ingLines[i].replaceFirst(RegExp(r'^-\\s*'), '').trim();
        }

        final stepLines = (data['steps'] as String).split('\\n');
        for (int i = 0; i < _steps.length && i < stepLines.length; i++) {
            _steps[i]['human_text'] = stepLines[i].replaceFirst(RegExp(r'^\\d+\\.\\s*'), '').trim();
        }
      } catch (e) {
         debugPrint('Failed to map translation: $e');
      }
    });
  }

  void _showAdjustPortionsDialog() {"""

content = content.replace("  void _showAdjustPortionsDialog() {", apply_translation)

# 5. Use _displayTitle and translated_name in the UI
content = content.replace(
    "Text(\n                          widget.title,",
    "Text(\n                          _displayTitle,"
)

# In the SliverList for _ingredients:
content = content.replace(
    "final name = ingData?['display_name_en'] ?? 'Unknown';",
    "final name = ing['translated_name'] ?? ingData?['display_name_en'] ?? 'Unknown';"
)

with open(path, 'w', encoding='utf-8') as f: f.write(content)
print("Updated frontend recipe_detail_screen.dart!")
