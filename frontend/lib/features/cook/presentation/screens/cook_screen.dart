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
import 'package:ifridge_app/features/cook/presentation/screens/recipe_import_screen.dart';
import 'package:ifridge_app/core/services/auth_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';

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

      // 2. Try server-side 6-signal scoring first (fastest, most accurate)
      bool useServerScoring = false;
      try {
        final api = ApiService();
        final serverResult = await api.getRecommendations(
          userId: currentUserId(),
          maxPerTier: 10,
          cuisineFilter: _cuisineFilter,
        );

        final data = serverResult['data'] as Map<String, dynamic>?;
        if (data != null && data['tiers'] != null) {
          final serverTiers = data['tiers'] as Map<String, dynamic>;
          final Map<String, List<Map<String, dynamic>>> tiers = {
            '1': [], '2': [], '3': [], '4': [], '5': [],
          };

          for (final entry in serverTiers.entries) {
            final tierKey = entry.key;
            final recipes = entry.value as List? ?? [];
            tiers[tierKey] = recipes.map((r) {
              final recipe = r as Map<String, dynamic>;
              return {
                'id': recipe['recipe_id'],
                'title': recipe['title'],
                'description': '',
                'cuisine': recipe['cuisine'] ?? '',
                'difficulty': 1,
                'prep_time_minutes': recipe['prep_time_minutes'],
                'cook_time_minutes': null,
                'servings': null,
                'tags': <String>[],
                'match_pct': recipe['match_percentage'] ?? recipe['relevance_score'] ?? 0.0,
                'matched': 0,
                'total': 0,
                'missing': (recipe['missing_ingredients'] as List?)?.cast<String>() ?? [],
                'relevance_score': recipe['relevance_score'] ?? 0.0,
                'image_url': recipe['image_url'],
              };
            }).toList();
          }

          setState(() {
            _tiers = tiers;
            _ownedIngredientIds = ownedIds;
            _loading = false;
          });
          useServerScoring = true;
        }
      } catch (e) {
        debugPrint('[Cook] Server scoring unavailable, falling back to client: $e');
      }

      if (useServerScoring) return;

      // 3. Fallback: Client-side scoring (RPC → direct query)
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
            .limit(200);

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
        SnackBar(content: Text('Add some ingredients to your shelf first!')),
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
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2)),
            ),
            SizedBox(height: 16),
            Row(children: [
              Icon(Icons.auto_awesome, color: Theme.of(context).colorScheme.primary),
              SizedBox(width: 8),
              Text('AI Recipe Generator',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w700)),
            ]),
            SizedBox(height: 6),
            Text('Using your ${ingredientNames.length} ingredients',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 13)),
            SizedBox(height: 20),

            // Cuisine
            _aiOptionRow('Cuisine', DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                value: selectedCuisine,
                isDense: true,
                dropdownColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
                hint: Text('Any', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4))),
                items: [null, 'Korean', 'Italian', 'Japanese', 'Mexican', 'Chinese', 'Indian', 'American']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c ?? 'Any')))
                    .toList(),
                onChanged: (v) => setSheetState(() => selectedCuisine = v),
              ),
            )),
            SizedBox(height: 12),

            // Max time
            _aiOptionRow('Max Time', Row(children: [
              Text('$selectedMaxTime min',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface, fontSize: 14)),
              Expanded(
                child: Slider(
                  value: selectedMaxTime.toDouble(),
                  min: 10, max: 120, divisions: 11,
                  activeColor: Theme.of(context).colorScheme.primary,
                  onChanged: (v) => setSheetState(() => selectedMaxTime = v.round()),
                ),
              ),
            ])),
            SizedBox(height: 12),

            // Servings
            _aiOptionRow('Servings', Row(children: [
              ...List.generate(4, (i) {
                final s = i + 1;
                final active = s == selectedServings;
                return Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setSheetState(() => selectedServings = s),
                    child: Container(
                      width: 36, height: 36, alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: active ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15) : Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: active ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06)),
                      ),
                      child: Text('$s',
                          style: TextStyle(
                              color: active ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                              fontWeight: active ? FontWeight.w700 : FontWeight.w400)),
                    ),
                  ),
                );
              }),
            ])),
            SizedBox(height: 16),

            // Shelf Only toggle
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06)),
              ),
              child: SwitchListTile(
                value: shelfOnly,
                onChanged: (v) => setSheetState(() => shelfOnly = v),
                title: Text('Shelf Only',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
                subtitle: Text(
                  shelfOnly
                      ? 'Only use ingredients from your shelf'
                      : 'AI may suggest extra ingredients',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 11),
                ),
                secondary: Icon(
                  shelfOnly ? Icons.kitchen : Icons.add_shopping_cart,
                  color: shelfOnly ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                  size: 20,
                ),
                activeThumbColor: Theme.of(context).colorScheme.primary,
                dense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.pop(ctx, true),
                icon: Icon(Icons.auto_awesome, size: 18),
                label: Text('Generate Recipe'),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).scaffoldBackgroundColor,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            SizedBox(height: 8),
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
        backgroundColor: Theme.of(context).colorScheme.surface,
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(height: 8),
          CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
          SizedBox(height: 20),
          Text('Generating your ${selectedCuisine ?? ''} recipe...',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 14)),
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
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: ListView(
              controller: scrollCtrl,
              padding: EdgeInsets.all(24),
              children: [
                Center(child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2)),
                )),
                SizedBox(height: 16),
                Row(children: [
                  Icon(Icons.auto_awesome, color: Theme.of(context).colorScheme.primary),
                  SizedBox(width: 8),
                  Expanded(child: Text(title,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 20,
                          fontWeight: FontWeight.w700))),
                ]),
                if (desc.isNotEmpty) ...[
                  SizedBox(height: 8),
                  Text(desc,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          fontSize: 13,
                          height: 1.5)),
                ],

                // Ingredients
                if (aiIngredients.isNotEmpty) ...[
                  SizedBox(height: 20),
                  Text('🧂 Ingredients',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 15,
                          fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  ...aiIngredients.map((ing) => Padding(
                        padding: EdgeInsets.symmetric(vertical: 3),
                        child: Row(children: [
                          Icon(Icons.circle, size: 6,
                              color: Theme.of(context).colorScheme.primary),
                          SizedBox(width: 10),
                          Expanded(child: Text(
                            ing is Map ? '${ing['quantity'] ?? ''} ${ing['unit'] ?? ''} ${ing['name'] ?? ing}' : '$ing',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                fontSize: 13),
                          )),
                        ]),
                      )),
                ],

                // Steps
                if (stepsList.isNotEmpty) ...[
                  SizedBox(height: 20),
                  Text('👨‍🍳 Steps',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 15,
                          fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  ...List.generate(stepsList.length, (i) {
                    final step = stepsList[i];
                    final text = step is Map ? (step['text'] ?? '') : '$step';
                    return Container(
                      margin: EdgeInsets.only(bottom: 10),
                      padding: EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06)),
                      ),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 28, height: 28,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text('${i + 1}',
                                  style: TextStyle(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13)),
                            ),
                            SizedBox(width: 12),
                            Expanded(child: Text(text,
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontSize: 13,
                                    height: 1.5))),
                          ]),
                    );
                  }),
                ],
                SizedBox(height: 24),
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
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'What to Cook?',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => _openSearch(context),
            tooltip: 'Search recipes',
          ),
          IconButton(
            icon: Icon(Icons.auto_awesome),
            onPressed: () => _openAiGenerate(context),
            tooltip: 'AI Generate',
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchRecipes,
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Theme.of(context).colorScheme.primary,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54),
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const RecipeImportScreen()));
        },
        icon: Icon(Icons.content_paste, color: Theme.of(context).colorScheme.onSurface),
        label: Text('Import Recipe', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const RecipeListSkeleton();
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off,
                size: 64,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              SizedBox(height: 16),
              Text(
                'Couldn\'t load recipes',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Check your connection and try again.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  fontSize: 13,
                ),
              ),
              SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _fetchRecipes,
                icon: Icon(Icons.refresh),
                label: Text('Retry'),
                style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
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
  /// Uzbek is always pinned as the first option.
  static const _pinnedCuisines = ['Uzbek', 'Korean', 'Japanese', 'Italian', 'Mexican', 'Indian', 'Chinese'];
  List<String> get _allCuisines {
    final c = <String>{};
    for (final tier in _tiers.values) {
      for (final r in tier) {
        final cuisine = (r['cuisine'] ?? '').toString().trim();
        if (cuisine.isNotEmpty) c.add(cuisine);
      }
    }
    // Ensure pinned cuisines are always present
    c.addAll(_pinnedCuisines);
    final pinned = _pinnedCuisines.where((p) => c.contains(p)).toList();
    final rest = (c.toList()..sort()).where((e) => !_pinnedCuisines.contains(e)).toList();
    return [...pinned, ...rest];
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
                size: 56, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2)),
            SizedBox(height: 12),
            Text('No $tierLabel recipes yet',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 15)),
            SizedBox(height: 6),
            Text('Add items to your shelf to get recommendations',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3), fontSize: 12)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchRecipes,
      color: Theme.of(context).colorScheme.primary,
      child: CustomScrollView(
        slivers: [
          // Cuisine filter chips
          if (_allCuisines.isNotEmpty)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.fromLTRB(16, 10, 16, 2),
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
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                  SizedBox(height: 12),
                  Text('No recipes match this cuisine',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 14)),
                  TextButton(
                    onPressed: () => setState(() => _cuisineFilter = null),
                    child: Text('Clear filter'),
                  ),
                ]),
              ),
            ),

          // Recipe list
          SliverPadding(
            padding: EdgeInsets.all(16),
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
      padding: EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: active,
        label: Text(label,
            style: TextStyle(
                color: active ? Theme.of(context).scaffoldBackgroundColor : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400)),
        onSelected: (_) => setState(() => _cuisineFilter = cuisine),
        selectedColor: Theme.of(context).colorScheme.primary,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        checkmarkColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: BorderSide(
          color: active ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08)),
        padding: EdgeInsets.symmetric(horizontal: 4),
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
        return AppTheme.tier1;
      case '2':
        return AppTheme.tier2;
      case '3':
        return AppTheme.tier3;
      case '4':
        return AppTheme.tier4;
      default:
        return AppTheme.tier5;
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
              caloriesPerServing: recipe['calories_per_serving'] as int?,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _tierColor.withValues(alpha: matchPct >= 90 ? 0.6 : 0.3),
            width: matchPct >= 90 ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _tierColor.withValues(alpha: matchPct >= 90 ? 0.2 : 0.1),
              blurRadius: matchPct >= 90 ? 20 : 12,
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
                  image: CachedNetworkImageProvider(
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
                      Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
                    ],
                  ),
                ),
                alignment: Alignment.bottomRight,
                padding: EdgeInsets.all(10),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _tierColor.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('${matchPct.toInt()}%',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 13,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),

              // Recommendation Reason Badge
              SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _tierBadge,
                      style: TextStyle(
                        color: _tierColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // Relevance score (if available from server scoring)
                  if (recipe['relevance_score'] != null)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _tierColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${((recipe['relevance_score'] as num) * 100).toInt()}% fit',
                        style: TextStyle(
                          color: _tierColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              // Relevance score bar
              if (recipe['relevance_score'] != null) ...[
                SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: (recipe['relevance_score'] as num).toDouble().clamp(0.0, 1.0),
                    minHeight: 4,
                    backgroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
                    valueColor: AlwaysStoppedAnimation<Color>(_tierColor),
                  ),
                ),
              ],

              if (description.isNotEmpty) ...[
                SizedBox(height: 6),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 13,
                  ),
                ),
              ],

              SizedBox(height: 10),

              // Info chips
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _InfoChip(
                    icon: Icons.inventory_2,
                    label: '$matched/$total ingredients',
                    color: matchPct >= 100
                        ? Theme.of(context).colorScheme.tertiary
                        : Colors.orange,
                  ),
                  if (cuisine.isNotEmpty)
                    _InfoChip(
                      icon: Icons.public,
                      label: cuisine,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54),
                    ),
                  if (prepTime != null)
                    _InfoChip(
                      icon: Icons.timer,
                      label: cookTime != null
                          ? '${prepTime + cookTime} min'
                          : '$prepTime min',
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54),
                    ),
                  _InfoChip(
                    icon: Icons.signal_cellular_alt,
                    label: '⚡' * (difficulty as int),
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54),
                  ),
                ],
              ),

              // Missing ingredients
              if (missing.isNotEmpty) ...[
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 14,
                        color: Colors.orange,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Need: ${missing.join(", ")}',
                          style: TextStyle(
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
      'uzbek': 'https://images.unsplash.com/photo-1631515243349-e0cb75fb8d3a?w=600&q=80',
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
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          SizedBox(width: 4),
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
        );

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: Theme.of(context).colorScheme.surface,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
      ),
      scaffoldBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38)),
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(icon: Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(icon: Icon(Icons.arrow_back), onPressed: () => close(context, null));
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
  Widget buildResults(BuildContext context) => _buildResultsList(context);
  @override
  Widget buildSuggestions(BuildContext context) => _buildResultsList(context);

  Widget _buildResultsList(BuildContext context) {
    final results = _filterResults();
    if (query.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.search, size: 64, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15)),
          SizedBox(height: 12),
          Text('Type to search ${allRecipes.length} recipes',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 14)),
        ]),
      );
    }
    if (results.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.search_off, size: 64, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15)),
          SizedBox(height: 12),
          Text('No recipes matching "$query"',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 14)),
        ]),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.all(16),
      itemCount: results.length,
      separatorBuilder: (_, _) => SizedBox(height: 8),
      itemBuilder: (context, index) {
        final r = results[index];
        final title = r['title'] ?? 'Untitled';
        final desc = (r['description'] ?? '').toString();
        final matchPct = r['match_pct'] ?? 0.0;
        final pctLabel = '${(matchPct * 100).round()}% match';
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05)),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(title, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600)),
            subtitle: Text(
              desc.length > 80 ? '${desc.substring(0, 80)}...' : desc,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 12)),
            trailing: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8)),
              child: Text(pctLabel, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 11, fontWeight: FontWeight.w700))),
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
                  tierColor: Theme.of(context).colorScheme.primary,
                  ownedIngredientIds: ownedIngredientIds,
                  caloriesPerServing: r['calories_per_serving'] as int?,
                ),
              ));
            },
          ),
        );
      },
    );
  }
}

