// I-Fridge — Cook Screen
// =======================
// Displays recipe recommendations sorted into 5 tiers by ingredient match %.
// Queries recipes + recipe_ingredients from Supabase, compares against the
// user's inventory, and computes a match score.

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ifridge_app/core/theme/app_theme.dart';
import 'package:ifridge_app/core/widgets/shimmer_loading.dart';
import 'package:ifridge_app/core/widgets/slide_in_item.dart';
import 'package:ifridge_app/core/services/api_service.dart';
import 'package:ifridge_app/features/cook/presentation/screens/recipe_detail_screen.dart';
import 'package:ifridge_app/core/services/auth_helper.dart';

class CookScreen extends StatefulWidget {
  const CookScreen({super.key});

  @override
  State<CookScreen> createState() => _CookScreenState();
}

class _CookScreenState extends State<CookScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool _loading = true;
  String? _error;

  // Recipes grouped by tier key ('1'–'5')
  Map<String, List<Map<String, dynamic>>> _tiers = {};
  Set<String> _ownedIngredientIds = {};

  // Cuisine filter (Batch 2)
  String? _cuisineFilter;

  static const _tierMeta = [
    (label: 'Perfect', icon: Icons.verified, key: '1'),
    (label: 'For You', icon: Icons.auto_awesome, key: '2'),
    (label: 'Use It Up', icon: Icons.timer, key: '3'),
    (label: 'Almost', icon: Icons.shopping_cart_outlined, key: '4'),
    (label: 'Explore', icon: Icons.explore, key: '5'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tierMeta.length, vsync: this);
    _fetchRecipes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Data Loading ─────────────────────────────────────────────

  Future<void> _fetchRecipes() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final client = Supabase.instance.client;

      // 1. Get user's inventory ingredient IDs for "Missing" badges
      final inventoryRows = await client
          .from('inventory_items')
          .select('ingredient_id')
          .eq('user_id', currentUserId());

      final ownedIds = (inventoryRows as List)
          .map((r) => r['ingredient_id'] as String)
          .toSet();

      // 2. Try RPC first, fall back to direct query
      List<dynamic> rpcResponse = [];
      bool useDirectQuery = false;

      try {
        rpcResponse = await client.rpc('get_recommended_recipes', params: {
          'p_user_id': currentUserId(),
          'p_limit': 50,
        });
        if (rpcResponse.isEmpty) useDirectQuery = true;
      } catch (_) {
        useDirectQuery = true;
      }

      List<Map<String, dynamic>> scored = [];

      if (useDirectQuery) {
        // ── Direct Query Fallback ─────────────────────────────
        final recipeRows = await client
            .from('recipes')
            .select(
              '*, recipe_ingredients(ingredient_id, quantity, unit, is_optional, prep_note, ingredients(display_name_en))',
            )
            .limit(50);

        for (final recipe in (recipeRows as List)) {
          final ri = (recipe['recipe_ingredients'] as List?) ?? [];
          final required = ri.where((r) => r['is_optional'] != true).toList();
          final totalRequired = required.length;
          final matchedCount = required
              .where((r) => ownedIds.contains(r['ingredient_id']))
              .length;
          final matchPct = totalRequired > 0 ? matchedCount / totalRequired : 0.0;

          final missing = required
              .where((r) => !ownedIds.contains(r['ingredient_id']))
              .map((r) {
                final ing = r['ingredients'] as Map<String, dynamic>?;
                return ing?['display_name_en'] ?? 'unknown';
              })
              .toList();

          scored.add({
            'id': recipe['id'],
            'title': recipe['title'],
            'description': recipe['description'],
            'cuisine': recipe['cuisine'] ?? '',
            'difficulty': recipe['difficulty'] ?? 1,
            'prep_time_minutes': recipe['prep_time_minutes'],
            'cook_time_minutes': recipe['cook_time_minutes'],
            'servings': recipe['servings'],
            'tags': (recipe['tags'] as List?)?.cast<String>() ?? [],
            'match_pct': matchPct,
            'matched': matchedCount,
            'total': totalRequired,
            'missing': missing,
          });
        }
      } else {
        // ── RPC Path ──────────────────────────────────────────
        final recipeIds = rpcResponse.map((r) => r['recipe_id'] as String).toList();

        final recipeRows = await client
            .from('recipes')
            .select(
              '*, recipe_ingredients(ingredient_id, quantity, unit, is_optional, prep_note, ingredients(display_name_en))',
            )
            .inFilter('id', recipeIds);

        for (final r in rpcResponse) {
          final recipeId = r['recipe_id'];
          final scoreRaw = r['match_score'];
          double score = 0.0;
          if (scoreRaw is num) {
            score = scoreRaw.toDouble();
          } else if (scoreRaw is String) {
            score = double.tryParse(scoreRaw) ?? 0.0;
          }

          final recipeDetails = (recipeRows as List).firstWhere(
              (row) => row['id'] == recipeId,
              orElse: () => null);

          if (recipeDetails == null) continue;

          final ri = (recipeDetails['recipe_ingredients'] as List?) ?? [];
          final requiredIngredients = ri
              .where((req) => req['is_optional'] != true)
              .toList();
          final totalRequired = requiredIngredients.length;
          final matchedCount = requiredIngredients
              .where((req) => ownedIds.contains(req['ingredient_id']))
              .length;

          final missing = requiredIngredients
              .where((req) => !ownedIds.contains(req['ingredient_id']))
              .map((req) {
                final ing = req['ingredients'] as Map<String, dynamic>?;
                return ing?['display_name_en'] ?? 'unknown';
              })
              .toList();

          scored.add({
            'id': recipeDetails['id'],
            'title': recipeDetails['title'],
            'description': recipeDetails['description'],
            'cuisine': recipeDetails['cuisine'] ?? '',
            'difficulty': recipeDetails['difficulty'] ?? 1,
            'prep_time_minutes': recipeDetails['prep_time_minutes'],
            'cook_time_minutes': recipeDetails['cook_time_minutes'],
            'servings': recipeDetails['servings'],
            'tags': (recipeDetails['tags'] as List?)?.cast<String>() ?? [],
            'match_pct': score,
            'matched': matchedCount,
            'total': totalRequired,
            'missing': missing,
          });
        }
      }

      // 3. Sort into 5 Tiers
      final Map<String, List<Map<String, dynamic>>> tiers = {
        '1': [], '2': [], '3': [], '4': [], '5': [],
      };

      for (final r in scored) {
        final score = (r['match_pct'] as num).toDouble();
        if (score >= 0.90) {
          tiers['1']!.add(r);
        } else if (score >= 0.70) {
          tiers['2']!.add(r);
        } else if (score >= 0.50) {
          tiers['3']!.add(r);
        } else if (score >= 0.30) {
          tiers['4']!.add(r);
        } else {
          tiers['5']!.add(r);
        }
      }

      setState(() {
        _tiers = tiers;
        _ownedIngredientIds = ownedIds;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _openSearch(BuildContext context) {
    // Collect all recipes across tiers for search
    final allRecipes = <Map<String, dynamic>>[];
    for (final tier in _tiers.values) {
      allRecipes.addAll(tier);
    }
    showSearch(
      context: context,
      delegate: _RecipeSearchDelegate(
        allRecipes: allRecipes,
        ownedIngredientIds: _ownedIngredientIds,
      ),
    );
  }

  void _openAiGenerate(BuildContext context) async {
    // Get user's inventory ingredient names
    final client = Supabase.instance.client;
    final rows = await client
        .from('inventory_items')
        .select('ingredients(display_name_en)')
        .eq('user_id', currentUserId());
    final ingredientNames = (rows as List)
        .map((r) => r['ingredients']?['display_name_en'] as String?)
        .whereType<String>()
        .toList();

    if (!context.mounted) return;
    if (ingredientNames.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add some ingredients to your shelf first!')),
      );
      return;
    }

    // Show options sheet before generating
    String? selectedCuisine;
    int selectedDifficulty = 2;
    int selectedMaxTime = 30;
    int selectedServings = 2;
    bool shelfOnly = false;

    final shouldGenerate = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          decoration: const BoxDecoration(
            color: IFridgeTheme.bgCard,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: IFridgeTheme.textMuted,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            const Row(children: [
              Icon(Icons.auto_awesome, color: IFridgeTheme.primary),
              SizedBox(width: 8),
              Text('AI Recipe Generator',
                  style: TextStyle(
                      color: IFridgeTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 6),
            Text('Using your ${ingredientNames.length} ingredients',
                style: const TextStyle(
                    color: IFridgeTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 20),

            // Cuisine
            _aiOptionRow('Cuisine', DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                value: selectedCuisine,
                isDense: true,
                dropdownColor: IFridgeTheme.bgElevated,
                style: const TextStyle(color: IFridgeTheme.textPrimary, fontSize: 14),
                hint: const Text('Any', style: TextStyle(color: IFridgeTheme.textMuted)),
                items: [null, 'Korean', 'Italian', 'Japanese', 'Mexican', 'Chinese', 'Indian', 'American']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c ?? 'Any')))
                    .toList(),
                onChanged: (v) => setSheetState(() => selectedCuisine = v),
              ),
            )),
            const SizedBox(height: 12),

            // Max time
            _aiOptionRow('Max Time', Row(children: [
              Text('$selectedMaxTime min',
                  style: const TextStyle(
                      color: IFridgeTheme.textPrimary, fontSize: 14)),
              Expanded(
                child: Slider(
                  value: selectedMaxTime.toDouble(),
                  min: 10, max: 120, divisions: 11,
                  activeColor: IFridgeTheme.primary,
                  onChanged: (v) => setSheetState(() => selectedMaxTime = v.round()),
                ),
              ),
            ])),
            const SizedBox(height: 12),

            // Servings
            _aiOptionRow('Servings', Row(children: [
              ...List.generate(4, (i) {
                final s = i + 1;
                final active = s == selectedServings;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setSheetState(() => selectedServings = s),
                    child: Container(
                      width: 36, height: 36, alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: active ? IFridgeTheme.primary.withValues(alpha: 0.15) : IFridgeTheme.bgElevated,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: active ? IFridgeTheme.primary : Colors.white.withValues(alpha: 0.06)),
                      ),
                      child: Text('$s',
                          style: TextStyle(
                              color: active ? IFridgeTheme.primary : IFridgeTheme.textSecondary,
                              fontWeight: active ? FontWeight.w700 : FontWeight.w400)),
                    ),
                  ),
                );
              }),
            ])),
            const SizedBox(height: 16),

            // Shelf Only toggle
            Container(
              decoration: BoxDecoration(
                color: IFridgeTheme.bgElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: SwitchListTile(
                value: shelfOnly,
                onChanged: (v) => setSheetState(() => shelfOnly = v),
                title: const Text('Shelf Only',
                    style: TextStyle(
                        color: IFridgeTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
                subtitle: Text(
                  shelfOnly
                      ? 'Only use ingredients from your shelf'
                      : 'AI may suggest extra ingredients',
                  style: const TextStyle(
                      color: IFridgeTheme.textMuted, fontSize: 11),
                ),
                secondary: Icon(
                  shelfOnly ? Icons.kitchen : Icons.add_shopping_cart,
                  color: shelfOnly ? IFridgeTheme.primary : IFridgeTheme.textMuted,
                  size: 20,
                ),
                activeThumbColor: IFridgeTheme.primary,
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.pop(ctx, true),
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: const Text('Generate Recipe'),
                style: FilledButton.styleFrom(
                  backgroundColor: IFridgeTheme.primary,
                  foregroundColor: IFridgeTheme.bgDark,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ]),
        ),
      ),
    );

    if (shouldGenerate != true || !context.mounted) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: IFridgeTheme.bgCard,
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 8),
          const CircularProgressIndicator(color: IFridgeTheme.primary),
          const SizedBox(height: 20),
          Text('Generating your ${selectedCuisine ?? ''} recipe...',
              style: const TextStyle(color: IFridgeTheme.textSecondary, fontSize: 14)),
        ]),
      ),
    );

    try {
      final api = ApiService();
      final result = await api.generateRecipe(
        ingredients: ingredientNames,
        cuisine: selectedCuisine,
        maxTimeMinutes: selectedMaxTime,
        difficulty: selectedDifficulty,
        servings: selectedServings,
        shelfOnly: shelfOnly,
      );
      api.dispose();
      if (!context.mounted) return;
      Navigator.of(context).pop();

      final data = result['data'] ?? {};
      final title = data['title'] ?? 'AI Recipe';
      final desc = data['description'] ?? '';
      final stepsList = (data['steps'] as List?) ?? [];
      final aiIngredients = (data['ingredients'] as List?) ?? [];

      // Show formatted result bottom sheet
      if (!context.mounted) return;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, scrollCtrl) => Container(
            decoration: const BoxDecoration(
              color: IFridgeTheme.bgCard,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: ListView(
              controller: scrollCtrl,
              padding: const EdgeInsets.all(24),
              children: [
                Center(child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: IFridgeTheme.textMuted,
                      borderRadius: BorderRadius.circular(2)),
                )),
                const SizedBox(height: 16),
                Row(children: [
                  const Icon(Icons.auto_awesome, color: IFridgeTheme.primary),
                  const SizedBox(width: 8),
                  Expanded(child: Text(title,
                      style: const TextStyle(
                          color: IFridgeTheme.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700))),
                ]),
                if (desc.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(desc,
                      style: const TextStyle(
                          color: IFridgeTheme.textSecondary,
                          fontSize: 13,
                          height: 1.5)),
                ],

                // Ingredients
                if (aiIngredients.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text('🧂 Ingredients',
                      style: TextStyle(
                          color: IFridgeTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ...aiIngredients.map((ing) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(children: [
                          const Icon(Icons.circle, size: 6,
                              color: IFridgeTheme.primary),
                          const SizedBox(width: 10),
                          Expanded(child: Text(
                            ing is Map ? '${ing['quantity'] ?? ''} ${ing['unit'] ?? ''} ${ing['name'] ?? ing}' : '$ing',
                            style: const TextStyle(
                                color: IFridgeTheme.textSecondary,
                                fontSize: 13),
                          )),
                        ]),
                      )),
                ],

                // Steps
                if (stepsList.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text('👨‍🍳 Steps',
                      style: TextStyle(
                          color: IFridgeTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ...List.generate(stepsList.length, (i) {
                    final step = stepsList[i];
                    final text = step is Map ? (step['text'] ?? '') : '$step';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: IFridgeTheme.bgElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.06)),
                      ),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 28, height: 28,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: IFridgeTheme.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text('${i + 1}',
                                  style: const TextStyle(
                                      color: IFridgeTheme.primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(text,
                                style: const TextStyle(
                                    color: IFridgeTheme.textPrimary,
                                    fontSize: 13,
                                    height: 1.5))),
                          ]),
                    );
                  }),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('AI error: $e')),
      );
    }
  }

  Widget _aiOptionRow(String label, Widget child) {
    return Row(children: [
      SizedBox(
        width: 80,
        child: Text(label,
            style: const TextStyle(
                color: IFridgeTheme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500)),
      ),
      Expanded(child: child),
    ]);
  }

  // ── UI ───────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'What to Cook?',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _openSearch(context),
            tooltip: 'Search recipes',
          ),
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            onPressed: () => _openAiGenerate(context),
            tooltip: 'AI Generate',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchRecipes,
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppTheme.accent,
          labelColor: AppTheme.accent,
          unselectedLabelColor: Colors.white54,
          tabAlignment: TabAlignment.start,
          tabs: _tierMeta.map((t) {
            final count = (_tiers[t.key] ?? []).length;
            return Tab(
              icon: Icon(t.icon, size: 18),
              text: count > 0 ? '${t.label} ($count)' : t.label,
            );
          }).toList(),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const RecipeListSkeleton();
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off,
                size: 64,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              const Text(
                'Couldn\'t load recipes',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Check your connection and try again.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _fetchRecipes,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: FilledButton.styleFrom(backgroundColor: AppTheme.accent),
              ),
            ],
          ),
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: _tierMeta.map((t) => _buildTierList(t.key, t.label)).toList(),
    );
  }

  /// All unique cuisines across all loaded recipes.
  List<String> get _allCuisines {
    final c = <String>{};
    for (final tier in _tiers.values) {
      for (final r in tier) {
        final cuisine = (r['cuisine'] ?? '').toString().trim();
        if (cuisine.isNotEmpty) c.add(cuisine);
      }
    }
    final list = c.toList()..sort();
    return list;
  }

  Widget _buildTierList(String tierKey, String tierLabel) {
    var recipes = _tiers[tierKey] ?? [];

    // Apply cuisine filter
    if (_cuisineFilter != null) {
      recipes = recipes
          .where((r) => (r['cuisine'] ?? '').toString().toLowerCase() ==
              _cuisineFilter!.toLowerCase())
          .toList();
    }

    if ((_tiers[tierKey] ?? []).isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.restaurant_menu,
                size: 56, color: Colors.white.withValues(alpha: 0.2)),
            const SizedBox(height: 12),
            Text('No $tierLabel recipes yet',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5), fontSize: 15)),
            const SizedBox(height: 6),
            Text('Add items to your shelf to get recommendations',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3), fontSize: 12)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchRecipes,
      color: AppTheme.accent,
      child: CustomScrollView(
        slivers: [
          // Cuisine filter chips
          if (_allCuisines.isNotEmpty)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
                  children: [
                    _cuisineChip(null, 'All'),
                    ..._allCuisines.map((c) => _cuisineChip(c, c)),
                  ],
                ),
              ),
            ),

          // Empty filter result
          if (recipes.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.search_off, size: 48,
                      color: IFridgeTheme.textMuted.withValues(alpha: 0.5)),
                  const SizedBox(height: 12),
                  const Text('No recipes match this cuisine',
                      style: TextStyle(
                          color: IFridgeTheme.textSecondary, fontSize: 14)),
                  TextButton(
                    onPressed: () => setState(() => _cuisineFilter = null),
                    child: const Text('Clear filter'),
                  ),
                ]),
              ),
            ),

          // Recipe list
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => SlideInItem(
                  delay: index * 80,
                  child: _RecipeCard(
                    recipe: recipes[index],
                    tierKey: tierKey,
                    ownedIngredientIds: _ownedIngredientIds,
                  ),
                ),
                childCount: recipes.length,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _cuisineChip(String? cuisine, String label) {
    final active = _cuisineFilter == cuisine;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: active,
        label: Text(label,
            style: TextStyle(
                color: active ? IFridgeTheme.bgDark : IFridgeTheme.textSecondary,
                fontSize: 12,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400)),
        onSelected: (_) => setState(() => _cuisineFilter = cuisine),
        selectedColor: IFridgeTheme.primary,
        backgroundColor: IFridgeTheme.bgElevated,
        checkmarkColor: IFridgeTheme.bgDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: BorderSide(
          color: active ? IFridgeTheme.primary : Colors.white.withValues(alpha: 0.08)),
        padding: const EdgeInsets.symmetric(horizontal: 4),
      ),
    );
  }
}

// ── Recipe Card Widget ─────────────────────────────────────────────

class _RecipeCard extends StatelessWidget {
  final Map<String, dynamic> recipe;
  final String tierKey;
  final Set<String> ownedIngredientIds;

  const _RecipeCard({
    required this.recipe,
    required this.tierKey,
    required this.ownedIngredientIds,
  });

  Color get _tierColor {
    switch (tierKey) {
      case '1':
        return IFridgeTheme.tier1;
      case '2':
        return IFridgeTheme.tier2;
      case '3':
        return IFridgeTheme.tier3;
      case '4':
        return IFridgeTheme.tier4;
      default:
        return IFridgeTheme.tier5;
    }
  }

  String get _tierBadge {
    switch (tierKey) {
      case '1':
        return '✅ Everything you need!';
      case '2':
        return '🔥 Recommended for you';
      case '3':
        return '⏰ Use expiring items';
      case '4':
        return '🛒 Just a few items away';
      default:
        return '🌍 Discover something new';
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = recipe['title'] ?? 'Untitled';
    final description = recipe['description'] ?? '';
    final matchPct = ((recipe['match_pct'] ?? 0.0) as double) * 100;
    final matched = recipe['matched'] ?? 0;
    final total = recipe['total'] ?? 0;
    final missing = (recipe['missing'] as List?) ?? [];
    final cuisine = recipe['cuisine'] ?? '';
    final prepTime = recipe['prep_time_minutes'];
    final cookTime = recipe['cook_time_minutes'];
    final difficulty = recipe['difficulty'] ?? 1;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RecipeDetailScreen(
              recipeId: recipe['id'] as String,
              title: title,
              description: description,
              cuisine: cuisine,
              difficulty: difficulty as int?,
              prepTime: prepTime as int?,
              cookTime: cookTime as int?,
              servings: recipe['servings'] as int?,
              matchPct: recipe['match_pct'] as double? ?? 0.0,
              tierColor: _tierColor,
              ownedIngredientIds: ownedIngredientIds,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _tierColor.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _tierColor.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image header
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    _cuisineImageUrl(cuisine),
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppTheme.surface.withValues(alpha: 0.95),
                    ],
                  ),
                ),
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.all(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _tierColor.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('${matchPct.toInt()}%',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),

              // Recommendation Reason Badge
              const SizedBox(height: 6),
              Text(
                _tierBadge,
                style: TextStyle(
                  color: _tierColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),

              if (description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 13,
                  ),
                ),
              ],

              const SizedBox(height: 10),

              // Info chips
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _InfoChip(
                    icon: Icons.inventory_2,
                    label: '$matched/$total ingredients',
                    color: matchPct >= 100
                        ? AppTheme.freshGreen
                        : Colors.orange,
                  ),
                  if (cuisine.isNotEmpty)
                    _InfoChip(
                      icon: Icons.public,
                      label: cuisine,
                      color: Colors.white54,
                    ),
                  if (prepTime != null)
                    _InfoChip(
                      icon: Icons.timer,
                      label: cookTime != null
                          ? '${prepTime + cookTime} min'
                          : '$prepTime min',
                      color: Colors.white54,
                    ),
                  _InfoChip(
                    icon: Icons.signal_cellular_alt,
                    label: '⚡' * (difficulty as int),
                    color: Colors.white54,
                  ),
                ],
              ),

              // Missing ingredients
              if (missing.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.shopping_cart_outlined,
                        size: 14,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Need: ${missing.join(", ")}',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
          ],
        ),
      ),
    );
  }

  /// Maps cuisine names to category image URLs for the hero header.
  String _cuisineImageUrl(String cuisine) {
    const cuisineImages = <String, String>{
      'korean': 'https://images.unsplash.com/photo-1498654896293-37aacf113fd9?w=600&q=80',
      'japanese': 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=600&q=80',
      'chinese': 'https://images.unsplash.com/photo-1585032226651-759b368d7246?w=600&q=80',
      'italian': 'https://images.unsplash.com/photo-1498579150354-977475b7ea0b?w=600&q=80',
      'indian': 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=600&q=80',
      'mexican': 'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?w=600&q=80',
      'american': 'https://images.unsplash.com/photo-1550547660-d9450f859349?w=600&q=80',
      'thai': 'https://images.unsplash.com/photo-1559314809-0d155014e29e?w=600&q=80',
      'french': 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=600&q=80',
      'mediterranean': 'https://images.unsplash.com/photo-1544025162-d76694265947?w=600&q=80',
    };
    return cuisineImages[cuisine.toLowerCase()] ??
        'https://images.unsplash.com/photo-1606787366850-de6330128bfc?w=600&q=80';
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 11)),
        ],
      ),
    );
  }
}

// -- Search Delegate --

class _RecipeSearchDelegate extends SearchDelegate<void> {
  final List<Map<String, dynamic>> allRecipes;
  final Set<String> ownedIngredientIds;

  _RecipeSearchDelegate({
    required this.allRecipes,
    required this.ownedIngredientIds,
  }) : super(
          searchFieldLabel: 'Search recipes...',
          searchFieldStyle: const TextStyle(color: Colors.white70, fontSize: 16),
        );

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppTheme.surface,
        iconTheme: IconThemeData(color: Colors.white70),
      ),
      scaffoldBackgroundColor: AppTheme.background,
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white38),
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));
  }

  List<Map<String, dynamic>> _filterResults() {
    if (query.isEmpty) return [];
    final q = query.toLowerCase();
    return allRecipes.where((r) {
      final title = (r['title'] ?? '').toString().toLowerCase();
      final desc = (r['description'] ?? '').toString().toLowerCase();
      return title.contains(q) || desc.contains(q);
    }).toList();
  }

  @override
  Widget buildResults(BuildContext context) => _buildResultsList();
  @override
  Widget buildSuggestions(BuildContext context) => _buildResultsList();

  Widget _buildResultsList() {
    final results = _filterResults();
    if (query.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.search, size: 64, color: Colors.white.withValues(alpha: 0.15)),
          const SizedBox(height: 12),
          Text('Type to search ${allRecipes.length} recipes',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 14)),
        ]),
      );
    }
    if (results.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.search_off, size: 64, color: Colors.white.withValues(alpha: 0.15)),
          const SizedBox(height: 12),
          Text('No recipes matching "$query"',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 14)),
        ]),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final r = results[index];
        final title = r['title'] ?? 'Untitled';
        final desc = (r['description'] ?? '').toString();
        final matchPct = r['match_pct'] ?? 0.0;
        final pctLabel = '${(matchPct * 100).round()}% match';
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            subtitle: Text(
              desc.length > 80 ? '${desc.substring(0, 80)}...' : desc,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: IFridgeTheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8)),
              child: Text(pctLabel, style: const TextStyle(color: IFridgeTheme.primary, fontSize: 11, fontWeight: FontWeight.w700))),
            onTap: () {
              close(context, null);
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => RecipeDetailScreen(
                  recipeId: r['id'] ?? '',
                  title: r['title'] ?? 'Untitled',
                  description: r['description'],
                  cuisine: r['cuisine'],
                  difficulty: r['difficulty'],
                  prepTime: r['prep_time_minutes'],
                  cookTime: r['cook_time_minutes'],
                  servings: r['servings'],
                  matchPct: (r['match_pct'] ?? 0.0).toDouble(),
                  tierColor: IFridgeTheme.primary,
                  ownedIngredientIds: ownedIngredientIds,
                ),
              ));
            },
          ),
        );
      },
    );
  }
}
