// I-Fridge — Recipe Prep Screen
// ===============================
// Intermediate screen between recipe detail and cooking.
// Shows ingredient checklist with have/missing status,
// AI substitution suggestions, manual ingredient swaps,
// and serving size scaler with proper math.

import 'package:flutter/material.dart';
import 'package:ifridge_app/core/theme/app_theme.dart';
import 'package:ifridge_app/core/services/api_service.dart';
import 'package:ifridge_app/core/utils/unit_converter.dart';
import 'package:ifridge_app/core/utils/ingredient_icons.dart';
import 'package:ifridge_app/features/cook/presentation/screens/cooking_run_screen.dart';

class RecipePrepScreen extends StatefulWidget {
  final String recipeId;
  final String title;
  final int originalServings;
  final List<Map<String, dynamic>> ingredients;
  final List<Map<String, dynamic>> steps;
  final List<String>? prepNotes;
  final Set<String> ownedIngredientIds;
  final double matchPct;
  final Color tierColor;

  const RecipePrepScreen({
    super.key,
    required this.recipeId,
    required this.title,
    required this.originalServings,
    required this.ingredients,
    required this.steps,
    this.prepNotes,
    required this.ownedIngredientIds,
    required this.matchPct,
    required this.tierColor,
  });

  @override
  State<RecipePrepScreen> createState() => _RecipePrepScreenState();
}

class _RecipePrepScreenState extends State<RecipePrepScreen> {
  late int _servings;
  final ApiService _api = ApiService();

  // Substitution state: ingredient index → substitution text
  final Map<int, String> _substitutions = {};
  final Map<int, bool> _loadingSub = {};

  // AI chat
  String _aiQuestion = '';
  String? _aiResponse;
  bool _aiLoading = false;

  @override
  void initState() {
    super.initState();
    _servings = widget.originalServings;
  }

  @override
  void dispose() {
    _api.dispose();
    super.dispose();
  }

  double _scaleQuantity(dynamic original) {
    final qty = (original is num) ? original.toDouble() : (double.tryParse('$original') ?? 0);
    return UnitConverter.scale(qty, widget.originalServings, _servings);
  }

  void _incrementServings() => setState(() => _servings = (_servings + 1).clamp(1, 20));
  void _decrementServings() => setState(() => _servings = (_servings - 1).clamp(1, 20));

  Future<void> _askSubstitute(int index) async {
    final ing = widget.ingredients[index];
    final ingData = ing['ingredients'] as Map<String, dynamic>?;
    final name = ingData?['display_name_en'] ?? 'Unknown';

    setState(() => _loadingSub[index] = true);

    try {
      final result = await _api.suggestSubstitute(
        ingredient: name,
        recipeContext: widget.title,
      );
      final data = result['data'];
      if (data != null && data['substitutes'] != null) {
        final subs = data['substitutes'] as List;
        final text = subs.map((s) => '• ${s['name']} (${s['ratio']}) — ${s['notes']}').join('\n');
        setState(() {
          _substitutions[index] = text;
          _loadingSub[index] = false;
        });
      } else {
        setState(() {
          _substitutions[index] = 'No substitutions found.';
          _loadingSub[index] = false;
        });
      }
    } catch (e) {
      setState(() {
        _substitutions[index] = 'Error: Could not reach AI.';
        _loadingSub[index] = false;
      });
    }
  }

  Future<void> _askAiChat() async {
    if (_aiQuestion.trim().isEmpty || _aiLoading) return;
    setState(() => _aiLoading = true);

    try {
      final ingNames = widget.ingredients.map((i) {
        final d = i['ingredients'] as Map<String, dynamic>?;
        return d?['display_name_en'] ?? '';
      }).where((n) => n.isNotEmpty).join(', ');

      final result = await _api.getCookingTip(
        stepText: 'Recipe: ${widget.title}. Ingredients: $ingNames',
        question: _aiQuestion,
      );
      setState(() {
        _aiResponse = result['data']?['tip'] ?? 'No response.';
        _aiLoading = false;
      });
    } catch (e) {
      setState(() {
        _aiResponse = 'Error: $e';
        _aiLoading = false;
      });
    }
  }

  void _startCooking() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CookingRunScreen(
          recipeId: widget.recipeId,
          title: widget.title,
          steps: widget.steps,
          ingredients: widget.ingredients,
          prepNotes: widget.prepNotes,
          matchedIngredientsCount: widget.ownedIngredientIds.length,
          matchPct: widget.matchPct,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final haveCount = widget.ingredients.where((ing) {
      final id = (ing['ingredients'] as Map?)?['id'];
      return widget.ownedIngredientIds.contains(id);
    }).length;
    final missingCount = widget.ingredients.length - haveCount;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        title: Text(widget.title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // ── Serving Scaler ───────────────────────────
                  Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.people, color: IFridgeTheme.primary, size: 20),
                        const SizedBox(width: 12),
                        const Text('Servings', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                        const Spacer(),
                        IconButton(
                          onPressed: _decrementServings,
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.white54),
                          iconSize: 28,
                        ),
                        Text('$_servings',
                          style: const TextStyle(color: IFridgeTheme.primary, fontSize: 22, fontWeight: FontWeight.w800)),
                        IconButton(
                          onPressed: _incrementServings,
                          icon: const Icon(Icons.add_circle_outline, color: Colors.white54),
                          iconSize: 28,
                        ),
                      ],
                    ),
                  ),

                  // ── Ingredient Status Summary ────────────────
                  Row(
                    children: [
                      _StatusChip(
                        icon: Icons.check_circle, color: IFridgeTheme.freshGreen,
                        label: '$haveCount have'),
                      const SizedBox(width: 8),
                      if (missingCount > 0)
                        _StatusChip(
                          icon: Icons.warning_amber, color: Colors.orange,
                          label: '$missingCount missing'),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Ingredients List ──────────────────────────
                  Text('📋 Ingredients',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),

                  ...List.generate(widget.ingredients.length, (i) {
                    final ing = widget.ingredients[i];
                    final ingData = ing['ingredients'] as Map<String, dynamic>?;
                    final name = ingData?['display_name_en'] ?? 'Unknown';
                    final ingId = ingData?['id'] ?? '';
                    final rawQty = ing['quantity'];
                    final unit = ing['unit'] ?? '';
                    final isOwned = widget.ownedIngredientIds.contains(ingId);
                    final scaledQty = _scaleQuantity(rawQty);
                    final emoji = IngredientIcons.getEmoji(name, category: ingData?['category']);

                    return Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isOwned
                                  ? IFridgeTheme.freshGreen.withValues(alpha: 0.2)
                                  : Colors.orange.withValues(alpha: 0.15)),
                          ),
                          child: Row(
                            children: [
                              Text(emoji, style: const TextStyle(fontSize: 22)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                                    Text('${UnitConverter.formatQuantity(scaledQty)} $unit',
                                      style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
                                  ],
                                ),
                              ),
                              if (isOwned)
                                const Icon(Icons.check_circle, color: IFridgeTheme.freshGreen, size: 20)
                              else
                                GestureDetector(
                                  onTap: () => _askSubstitute(i),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: _loadingSub[i] == true
                                        ? const SizedBox(width: 14, height: 14,
                                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange))
                                        : const Text('Swap →',
                                            style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.w700)),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        // Substitution suggestions
                        if (_substitutions[i] != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 8, left: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: IFridgeTheme.primary.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: IFridgeTheme.primary.withValues(alpha: 0.15)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.auto_awesome, size: 16, color: IFridgeTheme.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(_substitutions[i]!,
                                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13, height: 1.5)),
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
                  }),

                  // ── AI Assistant ─────────────────────────────
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: IFridgeTheme.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: IFridgeTheme.primary.withValues(alpha: 0.15)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.auto_awesome, color: IFridgeTheme.primary, size: 18),
                            SizedBox(width: 8),
                            Text('🤖 AI Assistant',
                              style: TextStyle(color: IFridgeTheme.primary, fontSize: 14, fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          onChanged: (v) => _aiQuestion = v,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'e.g. "I don\'t have lamb, suggest alternatives"',
                            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 13),
                            filled: true,
                            fillColor: AppTheme.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            suffixIcon: _aiLoading
                                ? const Padding(padding: EdgeInsets.all(12),
                                    child: SizedBox(width: 18, height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: IFridgeTheme.primary)))
                                : IconButton(
                                    onPressed: _askAiChat,
                                    icon: const Icon(Icons.send, color: IFridgeTheme.primary, size: 20)),
                          ),
                        ),
                        if (_aiResponse != null) ...[
                          const SizedBox(height: 10),
                          Text(_aiResponse!,
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13, height: 1.5)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // ── Start Cooking Button ─────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _startCooking,
                  icon: const Icon(Icons.restaurant, size: 22),
                  label: const Text('🍳 Start Cooking',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  style: FilledButton.styleFrom(
                    backgroundColor: IFridgeTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  const _StatusChip({required this.icon, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
