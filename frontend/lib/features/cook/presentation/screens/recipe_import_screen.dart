import 'package:flutter/material.dart';
import 'package:plately_app/core/services/api_service.dart';
import 'package:plately_app/core/services/auth_helper.dart';
import 'package:plately_app/core/services/cache_service.dart';
import 'package:plately_app/l10n/app_localizations.dart';

class RecipeImportScreen extends StatefulWidget {
  const RecipeImportScreen({super.key});

  @override
  State<RecipeImportScreen> createState() => _RecipeImportScreenState();
}

class _RecipeImportScreenState extends State<RecipeImportScreen> {
  final TextEditingController _rawTextController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isProcessing = false;

  void _parseRecipe() async {
    final text = _rawTextController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isProcessing = true);
    try {
      final res = await _apiService.parseRawRecipe(rawText: text);
      if (res['status'] == 'success' && mounted) {
        final data = res['data'] as Map<String, dynamic>;
        _showPreviewDialog(data);
      } else {
        throw Exception(res['message'] ?? 'Failed to parse');
      }
    } catch (e) {
      if (mounted) {
        String msg = e.toString();
        if (msg.contains('Failed to fetch') || msg.contains('SocketException') || msg.contains('Connection')) {
          msg = 'Backend AI is offline or unreachable. Please check your Railway/server status.';
        } else {
          msg = msg.replaceAll('Exception: ', '');
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $msg'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showPreviewDialog(Map<String, dynamic> parsedData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ParsedRecipePreview(data: parsedData),
    );
  }

  @override
  void dispose() {
    _rawTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n?.import_recipe ?? 'Import Recipe', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n?.import_pasteRaw ?? 'Paste Raw Recipe', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(l10n?.import_description ?? 'Copy and paste instructions from a website, book, or notes app. Our AI will magically convert it into a step-by-step smart recipe.',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 14)),
            const SizedBox(height: 24),
            
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12)),
                ),
                child: TextField(
                  controller: _rawTextController,
                  maxLines: null,
                  expands: true,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface, height: 1.5),
                  decoration: InputDecoration(
                    hintText: l10n?.import_hint ?? "e.g. Grandma's Cookies\nMix 2 cups flour with 1 cup sugar... bake at 350 for 10 mins.",
                    hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: _isProcessing ? null : _parseRecipe,
                icon: _isProcessing
                    ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Theme.of(context).colorScheme.onSurface, strokeWidth: 2))
                    : const Icon(Icons.auto_awesome),
                label: Text(_isProcessing ? (l10n?.import_analyzing ?? 'Analyzing Recipe...') : (l10n?.import_parseWithAi ?? 'Parse with AI'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _ParsedRecipePreview extends StatefulWidget {
  final Map<String, dynamic> data;
  const _ParsedRecipePreview({required this.data});

  @override
  State<_ParsedRecipePreview> createState() => _ParsedRecipePreviewState();
}

class _ParsedRecipePreviewState extends State<_ParsedRecipePreview> {
  bool _isSaving = false;

  /// Save recipe to local Hive storage instead of Supabase.
  /// This is the local-first approach: imported recipes stay on-device,
  /// keeping the main database clean while giving AI full context access.
  void _saveLocally() {
    setState(() => _isSaving = true);
    
    try {
      final userId = currentUserId();
      final title = widget.data['title'] ?? 'Imported Recipe';
      final desc = widget.data['description'] ?? '';
      final pt = widget.data['prep_time_minutes'] ?? 0;
      final ct = widget.data['cook_time_minutes'] ?? 0;
      final diff = widget.data['difficulty'] ?? 1;
      final serv = widget.data['servings'] ?? 2;
      
      final ingsRaw = widget.data['ingredients'] as List? ?? [];
      final jsonIngredients = ingsRaw.map((ing) => {
        'name': ing['name'],
        'quantity': ing['quantity'],
        'unit': ing['unit'] ?? 'pcs',
        'prep_note': ''
      }).toList();

      final stepsRaw = widget.data['steps'] as List? ?? [];
      final jsonSteps = stepsRaw.map((s) => {
        'step_number': s['step'],
        'text': s['text'],
        'timer_seconds': null
      }).toList();

      final recipeData = {
        'title': title,
        'description': desc,
        'prep_time_minutes': pt,
        'cook_time_minutes': ct,
        'difficulty': diff,
        'servings': serv,
        'calories_per_serving': 0,
        'ingredients': jsonIngredients,
        'steps': jsonSteps,
        'cuisine': widget.data['cuisine'] ?? 'Unknown',
      };

      // Save to local Hive box
      CacheService().saveLocalRecipe(userId, recipeData);
      
      if (!mounted) return;
      Navigator.pop(context); // Close sheet
      Navigator.pop(context); // Close import screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)?.import_savedLocally ?? 'Recipe saved to My Recipes!'),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
        ),
      );
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save error: $e')));
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40, height: 4,
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24), borderRadius: BorderRadius.circular(2)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Row(
                  children: [
                    Expanded(child: Text(widget.data['title'] ?? (l10n?.import_parsedRecipe ?? 'Parsed Recipe'), style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.bold))),
                    IconButton(icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54)), onPressed: () => Navigator.pop(context)),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildSectionHeader(l10n?.ingredientsHeader ?? 'Ingredients'),
                    ...(widget.data['ingredients'] as List? ?? []).map((ing) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text('• ${ing['quantity']} ${ing['unit']} ${ing['name']}', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
                    )),
                    
                    const SizedBox(height: 24),
                    _buildSectionHeader(l10n?.import_steps ?? 'Steps'),
                    ...(widget.data['steps'] as List? ?? []).map((step) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${step['step']}. ', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                          Expanded(child: Text('${step['text']}', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), height: 1.4))),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: _isSaving ? null : _saveLocally,
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isSaving 
                      ? CircularProgressIndicator(color: Theme.of(context).colorScheme.onSurface)
                      : Text(l10n?.import_saveButton ?? 'Looks Good — Save to My Recipes', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}
