// I-Fridge — Recipe Detail Screen
// =================================
// Full recipe view with hero header, ingredient checklist,
// and step-by-step cooking instructions.
// Fetches recipe_ingredients and recipe_steps from Supabase.

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ifridge_app/core/theme/app_theme.dart';
import 'package:ifridge_app/core/widgets/shimmer_loading.dart';
import 'package:ifridge_app/core/widgets/slide_in_item.dart';
import 'package:ifridge_app/features/cook/presentation/screens/cooking_run_screen.dart';
import 'package:ifridge_app/core/services/auth_helper.dart';
import 'package:ifridge_app/core/services/api_service.dart';
import 'dart:convert';

class RecipeDetailScreen extends StatefulWidget {
  final String recipeId;
  final String title;
  final String? description;
  final String? cuisine;
  final int? difficulty;
  final int? prepTime;
  final int? cookTime;
  final int? servings;
  final double matchPct;
  final Color tierColor;
  final Set<String> ownedIngredientIds;

  const RecipeDetailScreen({
    super.key,
    required this.recipeId,
    required this.title,
    this.description,
    this.cuisine,
    this.difficulty,
    this.prepTime,
    this.cookTime,
    this.servings,
    this.matchPct = 0,
    required this.tierColor,
    required this.ownedIngredientIds,
  });

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _ingredients = [];
  List<Map<String, dynamic>> _steps = [];

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
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
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _showAdjustPortionsDialog() {
    int _newServings = widget.servings ?? 2;
    showModalBottomSheet(
      context: context,
      backgroundColor: IFridgeTheme.bgElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateSB) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Adjust Portions',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Current recipe makes ${widget.servings ?? "?"} servings.',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _newServings > 1 ? () => setStateSB(() => _newServings--) : null,
                        icon: const Icon(Icons.remove_circle_outline, color: IFridgeTheme.primary, size: 32),
                      ),
                      const SizedBox(width: 24),
                      Text(
                        '$_newServings',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 24),
                      IconButton(
                        onPressed: () => setStateSB(() => _newServings++),
                        icon: const Icon(Icons.add_circle_outline, color: IFridgeTheme.primary, size: 32),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _adjustWithAi(_newServings);
                      },
                      icon: const Icon(Icons.auto_awesome),
                      label: Text('Scale to $_newServings Servings'),
                      style: FilledButton.styleFrom(
                        backgroundColor: IFridgeTheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _adjustWithAi(int newServings) async {
    if (newServings == widget.servings) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: IFridgeTheme.primary),
            SizedBox(width: 8),
            Text('AI Chef', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Scaling recipe to $newServings servings...',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            const LinearProgressIndicator(color: IFridgeTheme.primary),
          ],
        ),
      ),
    );

    try {
      final ingredientNames = _ingredients.map((ing) {
        final ingData = ing['ingredients'] as Map<String, dynamic>?;
        return ingData?['display_name_en'] as String? ?? '';
      }).where((name) => name.isNotEmpty).toList();

      final api = ApiService();
      final result = await api.generateRecipe(
        ingredients: ingredientNames,
        cuisine: widget.cuisine,
        servings: newServings,
      );
      api.dispose();

      if (!mounted) return;
      Navigator.pop(context); // close dialog

      if (result['status'] == 'success' && result['recipe'] != null) {
        final r = result['recipe'];
        // Show success snackbar and reload the UI state if you want to replace the current display,
        // but since AI returns a full new recipe (without DB IDs), 
        // it's easier to just push a new generic RecipeDetail Screen or show a dialog.
        // For Phase 18, we can just show a modal or update state:
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppTheme.surface,
            title: Text(r['title'] ?? 'Adjusted Recipe', style: const TextStyle(color: Colors.white)),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Makes $newServings servings', style: TextStyle(color: IFridgeTheme.primary, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const Text('Ingredients:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (r['ingredients'] != null)
                    ...(r['ingredients'] as List).map((ing) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text('• ${ing['amount']} ${ing['unit']} ${ing['name']}', style: const TextStyle(color: Colors.white70)),
                        )),
                  const SizedBox(height: 16),
                  const Text('Steps:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (r['instructions'] != null)
                    ...(r['instructions'] as List).map((step) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text('${step['step_number']}. ${step['instruction_text']}', style: const TextStyle(color: Colors.white70)),
                        )),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
            ],
          ),
        );

      } else {
        throw Exception('Failed to parse AI output');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // close dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('AI scaling failed: $e'), backgroundColor: Colors.redAccent),
      );
    }
  }

  int get _totalTime => (widget.prepTime ?? 0) + (widget.cookTime ?? 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // ── Hero Header ──────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppTheme.surface,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.tierColor.withValues(alpha: 0.4),
                      AppTheme.background,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(60, 16, 20, 60),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Match badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: widget.tierColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: widget.tierColor.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Text(
                            '${(widget.matchPct * 100).toInt()}% Match',
                            style: TextStyle(
                              color: widget.tierColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Title
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                        ),
                        if (widget.description != null &&
                            widget.description!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            widget.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Quick Info Chips ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  if (widget.cuisine != null && widget.cuisine!.isNotEmpty)
                    _QuickChip(icon: Icons.public, label: widget.cuisine!),
                  if (_totalTime > 0)
                    _QuickChip(icon: Icons.timer, label: '$_totalTime min'),
                  if (widget.servings != null)
                    _QuickChip(
                      icon: Icons.people,
                      label: '${widget.servings} servings',
                    ),
                  if (widget.difficulty != null)
                    _QuickChip(
                      icon: Icons.signal_cellular_alt,
                      label: '${'⚡' * widget.difficulty!} Difficulty',
                    ),
                ],
              ),
            ),
          ),

          // ── Loading / Content ────────────────────────────────────
          if (_loading)
            const SliverFillRemaining(child: RecipeListSkeleton())
          else ...[
            // ── Ingredients Section ────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.checklist,
                      color: IFridgeTheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Ingredients (${_ingredients.length})',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: _showAdjustPortionsDialog,
                      icon: const Icon(Icons.auto_awesome, size: 16),
                      label: const Text('Scale'),
                      style: TextButton.styleFrom(
                        foregroundColor: IFridgeTheme.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    )
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final ing = _ingredients[index];
                  final ingData = ing['ingredients'] as Map<String, dynamic>?;
                  final name = ingData?['display_name_en'] ?? 'Unknown';
                  final ingId = ingData?['id'] ?? '';
                  final qty = ing['quantity'];
                  final unit = ing['unit'] ?? '';
                  final isOptional = ing['is_optional'] == true;
                  final prepNote = ing['prep_note'] ?? '';
                  final isOwned = widget.ownedIngredientIds.contains(ingId);

                  return SlideInItem(
                    delay: index * 50,
                    child: _IngredientRow(
                      name: name,
                      quantity: '$qty $unit',
                      prepNote: prepNote,
                      isOptional: isOptional,
                      isOwned: isOwned,
                    ),
                  );
                }, childCount: _ingredients.length),
              ),
            ),

            // ── Add Missing to Shopping List Button ────────────────
            if (_ingredients.any((ing) {
              final id = (ing['ingredients'] as Map?)?['id'];
              return !widget.ownedIngredientIds.contains(id) &&
                  ing['is_optional'] != true;
            }))
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final missingItems = _ingredients.where((ing) {
                        final id = (ing['ingredients'] as Map?)?['id'];
                        return !widget.ownedIngredientIds.contains(id) &&
                            ing['is_optional'] != true;
                      }).toList();

                      if (missingItems.isEmpty) return;

                      final insertData = missingItems.map((ing) {
                        final ingData = ing['ingredients'] as Map<String, dynamic>?;
                        final name = ingData?['display_name_en'] ?? 'Unknown';
                        return {
                          'user_id': currentUserId(),
                          'ingredient_name': name,
                          'quantity': ing['quantity'],
                          'unit': ing['unit'],
                          'is_purchased': false,
                        };
                      }).toList();

                      try {
                        await Supabase.instance.client
                            .from('shopping_list')
                            .insert(insertData);
                            
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Added missing items to Shopping List!'),
                              backgroundColor: IFridgeTheme.primary,
                            ),
                          );
                        }
                      } catch (e) {
                         if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to add items: $e'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.shopping_cart_outlined, size: 20),
                    label: const Text(
                      'Add missing to Shopping List',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: IFridgeTheme.primary,
                      side: const BorderSide(color: IFridgeTheme.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),

            // ── Steps Section ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 28, 16, 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.format_list_numbered,
                      color: widget.tierColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Cooking Steps (${_steps.length})',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (_steps.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.auto_fix_high,
                          size: 40,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No steps available yet',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final step = _steps[index];
                    final isLast = index == _steps.length - 1;
                    return SlideInItem(
                      delay: (_ingredients.length + index) * 50,
                      child: _StepCard(
                        stepNumber: step['step_number'] ?? (index + 1),
                        humanText: step['human_text'] ?? '',
                        estimatedSeconds: step['estimated_seconds'],
                        requiresAttention: step['requires_attention'] == true,
                        tierColor: widget.tierColor,
                        isLast: isLast,
                      ),
                    );
                  }, childCount: _steps.length),
                ),
              ),

            // ── Bottom spacing ─────────────────────────────────────
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _steps.isNotEmpty
          ? SlideInItem(
              delay: 300,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  child: FloatingActionButton.extended(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CookingRunScreen(
                            recipeId: widget.recipeId,
                            title: widget.title,
                            steps: _steps,
                            matchedIngredientsCount:
                                widget.ownedIngredientIds.length,
                            matchPct: widget.matchPct,
                          ),
                        ),
                      );
                    },
                    backgroundColor: IFridgeTheme.primary,
                    icon: const Icon(Icons.play_arrow, size: 24),
                    label: const Text(
                      'Start Cooking',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

// ── Quick Info Chip ─────────────────────────────────────────────────

class _QuickChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _QuickChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white54),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ── Ingredient Row ──────────────────────────────────────────────────

class _IngredientRow extends StatelessWidget {
  final String name;
  final String quantity;
  final String prepNote;
  final bool isOptional;
  final bool isOwned;

  const _IngredientRow({
    required this.name,
    required this.quantity,
    required this.prepNote,
    required this.isOptional,
    required this.isOwned,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOwned
              ? IFridgeTheme.freshGreen.withValues(alpha: 0.2)
              : Colors.orange.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          // Owned / Missing indicator
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isOwned
                  ? IFridgeTheme.freshGreen.withValues(alpha: 0.15)
                  : Colors.orange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isOwned ? Icons.check : Icons.shopping_cart_outlined,
              size: 16,
              color: isOwned ? IFridgeTheme.freshGreen : Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          // Name + prep note
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isOptional) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'optional',
                          style: TextStyle(color: Colors.white38, fontSize: 9),
                        ),
                      ),
                    ],
                  ],
                ),
                if (prepNote.isNotEmpty)
                  Text(
                    prepNote,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
          // Quantity
          Text(
            quantity,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step Card ───────────────────────────────────────────────────────

class _StepCard extends StatelessWidget {
  final int stepNumber;
  final String humanText;
  final int? estimatedSeconds;
  final bool requiresAttention;
  final Color tierColor;
  final bool isLast;

  const _StepCard({
    required this.stepNumber,
    required this.humanText,
    this.estimatedSeconds,
    required this.requiresAttention,
    required this.tierColor,
    required this.isLast,
  });

  String get _timeLabel {
    if (estimatedSeconds == null) return '';
    if (estimatedSeconds! < 60) return '${estimatedSeconds}s';
    final min = estimatedSeconds! ~/ 60;
    final sec = estimatedSeconds! % 60;
    return sec > 0 ? '${min}m ${sec}s' : '${min}m';
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline indicator
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: tierColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: tierColor.withValues(alpha: 0.4)),
                  ),
                  child: Center(
                    child: Text(
                      '$stepNumber',
                      style: TextStyle(
                        color: tierColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: tierColor.withValues(alpha: 0.15),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Step content
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    humanText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (_timeLabel.isNotEmpty) ...[
                        Icon(
                          Icons.timer_outlined,
                          size: 14,
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _timeLabel,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: requiresAttention
                              ? Colors.orange.withValues(alpha: 0.1)
                              : IFridgeTheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              requiresAttention ? '👨‍🍳' : '🤖',
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              requiresAttention ? 'Hands-on' : 'Automatic',
                              style: TextStyle(
                                color: requiresAttention
                                    ? Colors.orange
                                    : IFridgeTheme.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
