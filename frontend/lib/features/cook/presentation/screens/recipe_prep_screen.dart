// I-Fridge — Recipe Prep Screen
// ===============================
// Intermediate screen between recipe detail and cooking.
// Shows ingredient checklist with have/missing status,
// AI substitution suggestions, manual ingredient swaps,
// and serving size scaler with proper math.

import 'package:flutter/material.dart';
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
  final int? caloriesPerServing;

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
    this.caloriesPerServing,
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

  Future<void> _editIngredient(int index) async {
    final ing = widget.ingredients[index];
    final ingData = ing['ingredients'] as Map<String, dynamic>?;
    final nameC = TextEditingController(text: ingData?['display_name_en'] ?? '');
    final qtyC = TextEditingController(text: '${ing['quantity'] ?? ''}');
    final unitC = TextEditingController(text: ing['unit'] ?? '');

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text('Edit Ingredient', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameC, autofocus: true,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'Name', labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                filled: true, fillColor: Theme.of(context).scaffoldBackgroundColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextField(
                  controller: qtyC, keyboardType: TextInputType.number,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Qty', labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                    filled: true, fillColor: Theme.of(context).scaffoldBackgroundColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)))),
                SizedBox(width: 12),
                Expanded(child: TextField(
                  controller: unitC,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Unit', labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                    filled: true, fillColor: Theme.of(context).scaffoldBackgroundColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)))),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, {
              'name': nameC.text.trim(),
              'qty': double.tryParse(qtyC.text) ?? ing['quantity'],
              'unit': unitC.text.trim(),
            }),
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
            child: Text('Save')),
        ],
      ),
    );
    if (result == null) return;
    setState(() {
      if (ingData != null) ingData['display_name_en'] = result['name'];
      ing['quantity'] = result['qty'];
      ing['unit'] = result['unit'];
    });
  }

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        title: Text(widget.title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // ── Serving Scaler ───────────────────────────
                  Container(
                    margin: EdgeInsets.only(top: 8, bottom: 16),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.people, color: Theme.of(context).colorScheme.primary, size: 20),
                        SizedBox(width: 12),
                        Text('Servings', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w600)),
                        Spacer(),
                        IconButton(
                          onPressed: _decrementServings,
                          icon: Icon(Icons.remove_circle_outline, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54)),
                          iconSize: 28,
                        ),
                        Text('$_servings',
                          style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 22, fontWeight: FontWeight.w800)),
                        IconButton(
                          onPressed: _incrementServings,
                          icon: Icon(Icons.add_circle_outline, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54)),
                          iconSize: 28,
                        ),
                      ],
                    ),
                  ),

                  // Scaled calorie info
                  if (widget.caloriesPerServing != null && widget.caloriesPerServing! > 0)
                    Container(
                      margin: EdgeInsets.only(bottom: 16),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.orange.withValues(alpha: 0.12), Theme.of(context).colorScheme.surface],
                          begin: Alignment.topLeft, end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.local_fire_department, color: Colors.orange, size: 22),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${widget.caloriesPerServing! * _servings} cal total',
                                style: TextStyle(color: Colors.orange, fontSize: 18, fontWeight: FontWeight.w800)),
                              Text('${widget.caloriesPerServing} cal × $_servings servings',
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),

                  // ── Ingredient Status Summary ────────────────
                  Row(
                    children: [
                      _StatusChip(
                        icon: Icons.check_circle, color: Theme.of(context).colorScheme.tertiary,
                        label: '$haveCount have'),
                      SizedBox(width: 8),
                      if (missingCount > 0)
                        _StatusChip(
                          icon: Icons.warning_amber, color: Colors.orange,
                          label: '$missingCount missing'),
                    ],
                  ),
                  SizedBox(height: 12),

                  // ── Ingredients List ──────────────────────────
                  Text('📋 Ingredients',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 14, fontWeight: FontWeight.w700)),
                  SizedBox(height: 8),

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
                          margin: EdgeInsets.only(bottom: 6),
                          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isOwned
                                  ? Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.2)
                                  : Colors.orange.withValues(alpha: 0.15)),
                          ),
                          child: GestureDetector(
                            onTap: () => _editIngredient(i),
                            child: Row(
                            children: [
                              Text(emoji, style: TextStyle(fontSize: 22)),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(name, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14, fontWeight: FontWeight.w600)),
                                    Text(UnitConverter.simplifyMetric(scaledQty, unit),
                                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 12)),
                                  ],
                                ),
                              ),
                              if (isOwned)
                                Icon(Icons.check_circle, color: Theme.of(context).colorScheme.tertiary, size: 20)
                              else
                                GestureDetector(
                                  onTap: () => _askSubstitute(i),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: _loadingSub[i] == true
                                        ? SizedBox(width: 14, height: 14,
                                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange))
                                        : Text('Swap →',
                                            style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.w700)),
                                  ),
                                ),
                            ],
                          ),
                          ),
                        ),
                        // Substitution suggestions
                        if (_substitutions[i] != null)
                          Container(
                            margin: EdgeInsets.only(bottom: 8, left: 12),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.auto_awesome, size: 16, color: Theme.of(context).colorScheme.primary),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(_substitutions[i]!,
                                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8), fontSize: 13, height: 1.5)),
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
                  }),

                  // ── AI Assistant ─────────────────────────────
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.auto_awesome, color: Theme.of(context).colorScheme.primary, size: 18),
                            SizedBox(width: 8),
                            Text('🤖 AI Assistant',
                              style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 14, fontWeight: FontWeight.w700)),
                          ],
                        ),
                        SizedBox(height: 10),
                        TextField(
                          onChanged: (v) => _aiQuestion = v,
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'e.g. "I don\'t have lamb, suggest alternatives"',
                            hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3), fontSize: 13),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none),
                            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            suffixIcon: _aiLoading
                                ? Padding(padding: EdgeInsets.all(12),
                                    child: SizedBox(width: 18, height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.primary)))
                                : IconButton(
                                    onPressed: _askAiChat,
                                    icon: Icon(Icons.send, color: Theme.of(context).colorScheme.primary, size: 20)),
                          ),
                        ),
                        if (_aiResponse != null) ...[
                          SizedBox(height: 10),
                          Text(_aiResponse!,
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85), fontSize: 13, height: 1.5)),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                ],
              ),
            ),

            // ── Start Cooking Button ─────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _startCooking,
                  icon: Icon(Icons.restaurant, size: 22),
                  label: Text('🍳 Start Cooking',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: EdgeInsets.symmetric(vertical: 18),
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
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
