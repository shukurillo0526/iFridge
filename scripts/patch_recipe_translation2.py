import os
import re

path = r'd:\dev\projects\iFridge\frontend\lib\features\cook\presentation\screens\recipe_detail_screen.dart'
with open(path, 'r', encoding='utf-8') as f: content = f.read()

old_load = """      // If not English, translate & cache
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
      }"""

new_load = """      // If not English, fetch translation from backend (cached in DB)
      if (userLanguage != 'en') {
        try {
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
            recipeId: widget.recipeId,
            title: widget.title,
            ingredients: ingText,
            steps: stepsText,
            targetLanguage: userLanguage,
          );

          if (response['status'] == 'success') {
            final data = response['data'] as Map<String, dynamic>;
            _applyTranslation(data);
          }
        } catch (e) {
          debugPrint('Translation failed: $e');
        }
      }"""

content = content.replace(old_load, new_load)

with open(path, 'w', encoding='utf-8') as f: f.write(content)
print("Updated frontend recipe_detail_screen.dart!")
