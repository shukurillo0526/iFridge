// I-Fridge — Recipe Attachment Widget
// =====================================
// Toggleable section for attaching a recipe to a reel/post.
// Modes:
//   1. Pick existing recipe from own collection
//   2. Create new recipe inline (title, ingredients, steps)
//   3. AI-generate from video (placeholder for now)
// Pricing: Free or Premium (creator sets price)

import 'package:flutter/material.dart';
import 'package:ifridge_app/core/theme/app_theme.dart';
import 'package:ifridge_app/core/services/recipe_monetization_service.dart';

class RecipeAttachmentWidget extends StatefulWidget {
  final ValueChanged<RecipeAttachmentResult?> onChanged;

  const RecipeAttachmentWidget({super.key, required this.onChanged});

  @override
  State<RecipeAttachmentWidget> createState() => _RecipeAttachmentWidgetState();
}

/// Data returned from the widget to the parent form.
class RecipeAttachmentResult {
  final String? existingRecipeId;   // If attaching existing
  final NewRecipeData? newRecipe;   // If creating new
  final bool isPremium;
  final int priceCents;

  RecipeAttachmentResult({
    this.existingRecipeId,
    this.newRecipe,
    this.isPremium = false,
    this.priceCents = 0,
  });
}

class NewRecipeData {
  final String title;
  final String? description;
  final String? cuisine;
  final int? difficulty;
  final int? prepTime;
  final int? cookTime;
  final int? servings;
  final List<String> ingredientLines;
  final List<String> stepLines;

  NewRecipeData({
    required this.title,
    this.description,
    this.cuisine,
    this.difficulty,
    this.prepTime,
    this.cookTime,
    this.servings,
    this.ingredientLines = const [],
    this.stepLines = const [],
  });
}

class _RecipeAttachmentWidgetState extends State<RecipeAttachmentWidget> {
  bool _enabled = false;
  String _mode = 'existing'; // 'existing', 'new', 'ai'
  bool _isPremium = false;
  int _priceCents = 199; // Default $1.99

  // Existing recipe
  RecipeModel? _selectedRecipe;
  List<RecipeModel> _myRecipes = [];
  bool _loadingRecipes = false;

  // New recipe fields
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _cuisineCtrl = TextEditingController();
  final _ingredientsCtrl = TextEditingController();
  final _stepsCtrl = TextEditingController();
  int _difficulty = 2;
  int _prepTime = 15;
  int _cookTime = 30;
  int _servings = 2;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _cuisineCtrl.dispose();
    _ingredientsCtrl.dispose();
    _stepsCtrl.dispose();
    super.dispose();
  }

  void _notifyParent() {
    if (!_enabled) {
      widget.onChanged(null);
      return;
    }

    if (_mode == 'existing' && _selectedRecipe != null) {
      widget.onChanged(RecipeAttachmentResult(
        existingRecipeId: _selectedRecipe!.id,
        isPremium: _isPremium,
        priceCents: _isPremium ? _priceCents : 0,
      ));
    } else if (_mode == 'new' && _titleCtrl.text.trim().isNotEmpty) {
      widget.onChanged(RecipeAttachmentResult(
        newRecipe: NewRecipeData(
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim().isNotEmpty ? _descCtrl.text.trim() : null,
          cuisine: _cuisineCtrl.text.trim().isNotEmpty ? _cuisineCtrl.text.trim() : null,
          difficulty: _difficulty,
          prepTime: _prepTime,
          cookTime: _cookTime,
          servings: _servings,
          ingredientLines: _ingredientsCtrl.text
              .split('\n')
              .map((l) => l.trim())
              .where((l) => l.isNotEmpty)
              .toList(),
          stepLines: _stepsCtrl.text
              .split('\n')
              .map((l) => l.trim())
              .where((l) => l.isNotEmpty)
              .toList(),
        ),
        isPremium: _isPremium,
        priceCents: _isPremium ? _priceCents : 0,
      ));
    } else if (_mode == 'ai') {
      widget.onChanged(RecipeAttachmentResult(
        isPremium: _isPremium,
        priceCents: _isPremium ? _priceCents : 0,
      ));
    }
  }

  Future<void> _loadMyRecipes() async {
    setState(() => _loadingRecipes = true);
    final recipes = await RecipeMonetizationService.getMyRecipes();
    if (mounted) {
      setState(() {
        _myRecipes = recipes;
        _loadingRecipes = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: _enabled
            ? IFridgeTheme.primary.withValues(alpha: 0.06)
            : IFridgeTheme.bgElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _enabled
              ? IFridgeTheme.primary.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Toggle Header ──
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              setState(() {
                _enabled = !_enabled;
                if (_enabled && _myRecipes.isEmpty) _loadMyRecipes();
              });
              _notifyParent();
            },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _enabled
                          ? IFridgeTheme.primary.withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.menu_book,
                      color: _enabled ? IFridgeTheme.primary : Colors.white38,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Attach Recipe',
                          style: TextStyle(
                            color: _enabled ? Colors.white : Colors.white70,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          _enabled ? 'Viewers can save or buy your recipe' : 'Let viewers cook what they see',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.35),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _enabled ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.expand_more,
                      color: _enabled ? IFridgeTheme.primary : Colors.white38,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Expanded Content ──
          if (_enabled) ...[
            Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Mode selector ──
                  _buildModeSelector(),

                  const SizedBox(height: 16),

                  // ── Mode content ──
                  if (_mode == 'existing') _buildExistingPicker(),
                  if (_mode == 'new') _buildNewRecipeForm(),
                  if (_mode == 'ai') _buildAiSection(),

                  const SizedBox(height: 16),

                  // ── Pricing Toggle ──
                  _buildPricingSection(),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Mode Selector ──
  Widget _buildModeSelector() {
    final modes = [
      ('existing', '📚', 'Existing'),
      ('new', '✏️', 'Create New'),
      ('ai', '🤖', 'AI Generate'),
    ];

    return Row(
      children: modes.map((m) {
        final isSelected = _mode == m.$1;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() => _mode = m.$1);
              if (m.$1 == 'existing' && _myRecipes.isEmpty) _loadMyRecipes();
              _notifyParent();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? IFridgeTheme.primary.withValues(alpha: 0.12)
                    : Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? IFridgeTheme.primary.withValues(alpha: 0.4)
                      : Colors.white.withValues(alpha: 0.06),
                ),
              ),
              child: Column(
                children: [
                  Text(m.$2, style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 2),
                  Text(m.$3,
                      style: TextStyle(
                        color: isSelected ? IFridgeTheme.primary : Colors.white54,
                        fontSize: 10,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      )),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Existing Recipe Picker ──
  Widget _buildExistingPicker() {
    if (_loadingRecipes) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(color: IFridgeTheme.primary, strokeWidth: 2),
        ),
      );
    }

    if (_myRecipes.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.restaurant_menu, size: 36, color: Colors.white.withValues(alpha: 0.15)),
              const SizedBox(height: 8),
              Text("You haven't created any recipes yet",
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13)),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => setState(() => _mode = 'new'),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Create one now'),
                style: TextButton.styleFrom(foregroundColor: IFridgeTheme.primary),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select a recipe',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
        const SizedBox(height: 8),
        ...(_myRecipes.take(5).map((r) => _RecipeTile(
          recipe: r,
          isSelected: _selectedRecipe?.id == r.id,
          onTap: () {
            setState(() => _selectedRecipe = r);
            _notifyParent();
          },
        ))),
        if (_myRecipes.length > 5)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text('+ ${_myRecipes.length - 5} more recipes',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 11)),
          ),
      ],
    );
  }

  // ── New Recipe Form ──
  Widget _buildNewRecipeForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FormField(controller: _titleCtrl, label: 'Recipe Title *', icon: Icons.restaurant_menu,
            onChanged: (_) => _notifyParent()),
        const SizedBox(height: 10),
        _FormField(controller: _descCtrl, label: 'Description', icon: Icons.notes, maxLines: 2,
            onChanged: (_) => _notifyParent()),
        const SizedBox(height: 10),
        _FormField(controller: _cuisineCtrl, label: 'Cuisine (Italian, Korean...)', icon: Icons.public,
            onChanged: (_) => _notifyParent()),
        const SizedBox(height: 12),

        // Quick settings row
        Row(
          children: [
            Expanded(child: _NumberPicker(
              label: '⏱️ Prep', value: _prepTime, unit: 'min',
              onChanged: (v) { setState(() => _prepTime = v); _notifyParent(); },
            )),
            const SizedBox(width: 8),
            Expanded(child: _NumberPicker(
              label: '🍳 Cook', value: _cookTime, unit: 'min',
              onChanged: (v) { setState(() => _cookTime = v); _notifyParent(); },
            )),
            const SizedBox(width: 8),
            Expanded(child: _NumberPicker(
              label: '🍽️ Serves', value: _servings, unit: '',
              onChanged: (v) { setState(() => _servings = v); _notifyParent(); },
            )),
          ],
        ),

        const SizedBox(height: 10),

        // Difficulty
        Row(
          children: [
            Text('Difficulty: ', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
            ...List.generate(5, (i) => GestureDetector(
              onTap: () { setState(() => _difficulty = i + 1); _notifyParent(); },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Icon(
                  i < _difficulty ? Icons.star : Icons.star_border,
                  size: 20,
                  color: i < _difficulty ? Colors.amber : Colors.white24,
                ),
              ),
            )),
          ],
        ),

        const SizedBox(height: 12),

        _FormField(
          controller: _ingredientsCtrl,
          label: 'Ingredients (one per line)',
          icon: Icons.list,
          maxLines: 5,
          hint: '2 cups flour\n3 eggs\n1 cup milk\n...',
          onChanged: (_) => _notifyParent(),
        ),
        const SizedBox(height: 10),
        _FormField(
          controller: _stepsCtrl,
          label: 'Steps (one per line)',
          icon: Icons.format_list_numbered,
          maxLines: 5,
          hint: 'Preheat oven to 350°F\nMix dry ingredients\nAdd wet ingredients\n...',
          onChanged: (_) => _notifyParent(),
        ),
      ],
    );
  }

  // ── AI Generate Section ──
  Widget _buildAiSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: IFridgeTheme.secondary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome, color: IFridgeTheme.secondary, size: 28),
          ),
          const SizedBox(height: 12),
          const Text('AI Recipe Generation',
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(
            'After uploading, our AI will analyze your video and automatically generate a recipe with ingredients and steps.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: IFridgeTheme.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('✨ Will generate after posting',
                style: TextStyle(color: IFridgeTheme.secondary, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // ── Pricing Section ──
  Widget _buildPricingSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _isPremium
            ? Colors.amber.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isPremium
              ? Colors.amber.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                _isPremium ? Icons.monetization_on : Icons.volunteer_activism,
                color: _isPremium ? Colors.amber : IFridgeTheme.primary,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isPremium ? 'Premium Recipe 💰' : 'Free Recipe 🎁',
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      _isPremium
                          ? 'Viewers pay to copy this recipe'
                          : 'Anyone can copy this recipe for free',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _isPremium,
                onChanged: (v) {
                  setState(() => _isPremium = v);
                  _notifyParent();
                },
                activeColor: Colors.amber,
              ),
            ],
          ),

          // Price picker (only if premium)
          if (_isPremium) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Text('Price: ', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13)),
                const SizedBox(width: 8),
                ...[99, 199, 299, 499, 999].map((cents) {
                  final isSelected = _priceCents == cents;
                  final label = '\$${(cents / 100).toStringAsFixed(2)}';
                  return GestureDetector(
                    onTap: () {
                      setState(() => _priceCents = cents);
                      _notifyParent();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.amber.withValues(alpha: 0.2)
                            : Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? Colors.amber.withValues(alpha: 0.5)
                              : Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Text(label,
                          style: TextStyle(
                            color: isSelected ? Colors.amber : Colors.white54,
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          )),
                    ),
                  );
                }),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Supporting Widgets ──

class _RecipeTile extends StatelessWidget {
  final RecipeModel recipe;
  final bool isSelected;
  final VoidCallback onTap;

  const _RecipeTile({required this.recipe, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected
              ? IFridgeTheme.primary.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? IFridgeTheme.primary.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.06),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? IFridgeTheme.primary : Colors.white24,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(recipe.title,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                  if (recipe.cuisine != null)
                    Text(recipe.cuisine!,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 11)),
                ],
              ),
            ),
            if (recipe.isPremium)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(recipe.priceDisplay,
                    style: const TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.w700)),
              ),
          ],
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;
  final String? hint;
  final ValueChanged<String>? onChanged;

  const _FormField({
    required this.controller, required this.label, required this.icon,
    this.maxLines = 1, this.hint, this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12),
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2), fontSize: 12),
        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: maxLines > 1 ? 60 : 0),
          child: Icon(icon, color: IFridgeTheme.primary.withValues(alpha: 0.5), size: 18),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.03),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        isDense: true,
      ),
    );
  }
}

class _NumberPicker extends StatelessWidget {
  final String label;
  final int value;
  final String unit;
  final ValueChanged<int> onChanged;

  const _NumberPicker({required this.label, required this.value, required this.unit, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => onChanged((value - (unit == 'min' ? 5 : 1)).clamp(1, 999)),
                child: Icon(Icons.remove_circle_outline, size: 18, color: Colors.white.withValues(alpha: 0.4)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text('$value${unit.isNotEmpty ? ' $unit' : ''}',
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
              ),
              GestureDetector(
                onTap: () => onChanged(value + (unit == 'min' ? 5 : 1)),
                child: Icon(Icons.add_circle_outline, size: 18, color: IFridgeTheme.primary.withValues(alpha: 0.7)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
