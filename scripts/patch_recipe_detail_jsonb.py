import os
import re

path = r'd:\dev\projects\iFridge\frontend\lib\features\cook\presentation\screens\recipe_detail_screen.dart'
with open(path, 'r', encoding='utf-8') as f: content = f.read()

# Replace _loadDetails entirely
old_load = """  Future<void> _loadDetails() async {
    try {
      final supabase = Supabase.instance.client;

      // Fetch ingredients with their display names
      final ingredientRows = await supabase
          .from('recipe_ingredients')
          .select('*, ingredients(id, display_name_en, category)')
          .eq('recipe_id', widget.recipeId)
          .order('is_optional', ascending: true);

      // Fetch cooking steps
      final stepRows = await supabase
          .from('recipe_steps')
          .select()
          .eq('recipe_id', widget.recipeId)
          .order('step_number', ascending: true);

      setState(() {
      _ingredients = List<Map<String, dynamic>>.from(ingredientRows);
      _steps = List<Map<String, dynamic>>.from(stepRows);
      _displayTitle = widget.title;
      if (widget.description != null) _displayDescription = widget.description;

      // If not English, fetch translation from backend (cached in DB)
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
      }

      setState(() {
        _loading = false;
      });
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }"""

new_load = """  Future<void> _loadDetails() async {
    try {
      final supabase = Supabase.instance.client;

      // Fetch JSONB ingredients and steps directly from the recipes table
      final recipeData = await supabase
          .from('recipes')
          .select('ingredients, steps')
          .eq('id', widget.recipeId)
          .maybeSingle();
          
      if (recipeData == null) {
         setState(() => _loading = false);
         return;
      }

      _ingredients = List<Map<String, dynamic>>.from(recipeData['ingredients'] ?? []);
      _steps = List<Map<String, dynamic>>.from(recipeData['steps'] ?? []);
      _displayTitle = widget.title;
      _displayDescription = widget.description;
      
      final userLanguage = Localizations.localeOf(context).languageCode;

      // If not English, fetch translation from backend (cached in DB)
      if (userLanguage != 'en') {
        try {
          final ingText = _ingredients.map((i) {
            final name = i['name'] ?? 'Unknown';
            final qty = i['quantity'] ?? '';
            final unit = i['unit'] ?? '';
            return "- $qty $unit $name";
          }).join('\\n');

          final stepsText = _steps.map((s) {
            final num = s['step_number'] ?? 0;
            final text = s['text'] ?? '';
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
      }

      setState(() {
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }"""

# Fix the regex mismatch by just using a custom patch logic:
content = re.sub(
    r"Future<void> _loadDetails\(\) async \{.*?\s*setState\(\(\) => _loading = false\);\s*\}\s*\}",
    new_load,
    content,
    flags=re.DOTALL
)

# Replace applyTranslation
content = re.sub(
    r"void _applyTranslation\(Map<String, dynamic> data\) \{.*?void _showAdjustPortionsDialog",
    """void _applyTranslation(Map<String, dynamic> data) {
    setState(() {
      if (data['title'] != null) _displayTitle = data['title'];
      if (data['description'] != null) _displayDescription = data['description'];
      
      try {
        final translatedIngs = data['ingredients'] as List<dynamic>?;
        if (translatedIngs != null) {
            for (int i = 0; i < _ingredients.length && i < translatedIngs.length; i++) {
                _ingredients[i]['translated_name'] = translatedIngs[i]['name'];
            }
        }

        final translatedSteps = data['steps'] as List<dynamic>?;
        if (translatedSteps != null) {
            for (int i = 0; i < _steps.length && i < translatedSteps.length; i++) {
                _steps[i]['translated_text'] = translatedSteps[i]['text'];
            }
        }
      } catch (e) {
         debugPrint('Failed to map translation: $e');
      }
    });
  }

  void _showAdjustPortionsDialog""",
    content,
    flags=re.DOTALL
)

# Update UI mapping for ingredients and steps
content = content.replace("final ingData = ing['ingredients'] as Map<String, dynamic>?;", "")
content = content.replace("final name = ing['translated_name'] ?? ingData?['display_name_en'] ?? 'Unknown';", "final name = ing['translated_name'] ?? ing['name'] ?? 'Unknown';")
content = content.replace("final ingId = ingData?['id'] ?? '';", "final ingId = ing['ingredient_id'] ?? '';")
content = content.replace("final id = (ing['ingredients'] as Map?)?['id'];", "final id = ing['ingredient_id'];")

content = content.replace("humanText: step['human_text'] ?? '',", "humanText: step['translated_text'] ?? step['text'] ?? '',")
content = content.replace("estimatedSeconds: step['estimated_seconds'],", "estimatedSeconds: step['timer_seconds'],")

with open(path, 'w', encoding='utf-8') as f: f.write(content)
print("Updated frontend recipe_detail_screen.dart for JSONB schema!")
