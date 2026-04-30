import 'package:flutter/material.dart';
import 'package:ifridge_app/core/services/api_service.dart';
import 'package:ifridge_app/core/services/auth_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Import Recipe', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Paste Raw Recipe', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Copy and paste instructions from a website, book, or notes app. Our AI will magically convert it into a step-by-step smart recipe.',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 14)),
            SizedBox(height: 24),
            
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
                    hintText: "e.g. Grandma's Cookies\\nMix 2 cups flour with 1 cup sugar... bake at 350 for 10 mins.",
                    hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: _isProcessing ? null : _parseRecipe,
                icon: _isProcessing
                    ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Theme.of(context).colorScheme.onSurface, strokeWidth: 2))
                    : Icon(Icons.auto_awesome),
                label: Text(_isProcessing ? 'Analyzing Recipe...' : 'Parse with AI', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

  void _saveToDb() async {
    setState(() => _isSaving = true);
    
    try {
      final userId = currentUserId();
      final title = widget.data['title'] ?? 'Imported Recipe';
      final desc = widget.data['description'] ?? '';
      final pt = widget.data['prep_time_minutes'] ?? 0;
      final ct = widget.data['cook_time_minutes'] ?? 0;
      final diff = widget.data['difficulty'] ?? 1;
      final serv = widget.data['servings'] ?? 2;
      
      // 1. Insert recipe
      final resp = await Supabase.instance.client.from('recipes').insert({
        'author_id': userId,
        'title': title,
        'description': desc,
        'prep_time_minutes': pt,
        'cook_time_minutes': ct,
        'difficulty': diff,
        'servings': serv,
        'is_public': false,
        'calories_per_serving': 0, // Could ask AI for this too
      }).select().single();
      
      final recipeId = resp['id'] as String;
      
      // 2. Insert ingredients
      final ings = widget.data['ingredients'] as List? ?? [];
      for (var ing in ings) {
        final name = ing['name'];
        final qty = ing['quantity'];
        final String unit = ing['unit'] ?? 'pcs';
        
        // Lookup canonical ingredient or create proxy
        final searchResp = await Supabase.instance.client
            .from('ingredients')
            .select('id')
            .ilike('display_name_en', '%$name%')
            .limit(1);
            
        String? cIngId;
        if ((searchResp as List).isNotEmpty) {
          cIngId = searchResp.first['id'];
        }
        
        await Supabase.instance.client.from('recipe_ingredients').insert({
          'recipe_id': recipeId,
          'ingredient_id': cIngId,
          'raw_text': '$qty $unit $name',
          'quantity': qty,
          'unit': unit,
        });
      }
      
      // 3. Format steps
      final stepsRaw = widget.data['steps'] as List? ?? [];
      final stepsFormatted = stepsRaw.map((s) => s['text'] ?? '').toList();
      await Supabase.instance.client.from('recipes').update({
        'instructions': stepsFormatted,
      }).eq('id', recipeId);
      
      if (!mounted) return;
      Navigator.pop(context); // Close sheet
      Navigator.pop(context); // Close import screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recipe imported successfully!'), backgroundColor: Theme.of(context).colorScheme.tertiary)
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
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 12),
                width: 40, height: 4,
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24), borderRadius: BorderRadius.circular(2)),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Row(
                  children: [
                    Expanded(child: Text(widget.data['title'] ?? 'Parsed Recipe', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.bold))),
                    IconButton(icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54)), onPressed: () => Navigator.pop(context)),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildSectionHeader('Ingredients'),
                    ...(widget.data['ingredients'] as List? ?? []).map((ing) => Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Text('• ${ing['quantity']} ${ing['unit']} ${ing['name']}', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
                    )),
                    
                    SizedBox(height: 24),
                    _buildSectionHeader('Steps'),
                    ...(widget.data['steps'] as List? ?? []).map((step) => Padding(
                      padding: EdgeInsets.only(bottom: 12.0),
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
                padding: EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: _isSaving ? null : _saveToDb,
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isSaving 
                      ? CircularProgressIndicator(color: Theme.of(context).colorScheme.onSurface)
                      : Text('Looks Good — Save to My Recipes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
      padding: EdgeInsets.only(bottom: 12),
      child: Text(title, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}
