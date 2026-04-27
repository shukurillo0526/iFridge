// I-Fridge — Enhanced Post Upload Form
// =======================================
// Real post creation with:
// - Multi-image picker (camera/gallery)
// - Post type selector (Photo, Restaurant Visit, Food Tip)
// - Location attachment for restaurant visits
// - Caption with hashtag support
// - Recipe link
// - Visibility toggle (public/friends)
// - Real Supabase upload

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ifridge_app/core/theme/app_theme.dart';
import 'package:ifridge_app/core/services/social_service.dart';
import 'package:ifridge_app/core/widgets/recipe_attachment_widget.dart';
import 'package:ifridge_app/core/services/recipe_monetization_service.dart';

class EnhancedPostUploadForm extends StatefulWidget {
  const EnhancedPostUploadForm({super.key});

  @override
  State<EnhancedPostUploadForm> createState() => _EnhancedPostUploadFormState();
}

class _EnhancedPostUploadFormState extends State<EnhancedPostUploadForm> {
  final _captionController = TextEditingController();
  final _locationController = TextEditingController();
  final _tagsController = TextEditingController();

  List<XFile> _selectedImages = [];
  String _postType = 'photo';
  String _visibility = 'public';
  bool _uploading = false;
  double _uploadProgress = 0;
  RecipeAttachmentResult? _recipeAttachment;

  final _postTypes = [
    ('photo', '📸', 'Photo', 'Share what you cooked'),
    ('restaurant_visit', '🍽️', 'Restaurant', 'Share a dining experience'),
    ('food_tip', '💡', 'Food Tip', 'Share a cooking tip'),
  ];

  @override
  void dispose() {
    _captionController.dispose();
    _locationController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickFromGallery() async {
    final images = await SocialService.pickMultipleImages();
    if (images.isNotEmpty) {
      setState(() => _selectedImages.addAll(images.take(10 - _selectedImages.length)));
    }
  }

  Future<void> _pickFromCamera() async {
    final image = await SocialService.pickImage(source: ImageSource.camera);
    if (image != null && _selectedImages.length < 10) {
      setState(() => _selectedImages.add(image));
    }
  }

  void _removeImage(int index) {
    setState(() => _selectedImages.removeAt(index));
  }

  Future<void> _submit() async {
    final caption = _captionController.text.trim();
    if (caption.isEmpty && _selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a photo or write something!'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() { _uploading = true; _uploadProgress = 0; });

    try {
      // Upload images
      final mediaUrls = <String>[];
      for (int i = 0; i < _selectedImages.length; i++) {
        setState(() => _uploadProgress = (i / _selectedImages.length));
        final url = await SocialService.uploadMedia(_selectedImages[i]);
        if (url != null) mediaUrls.add(url);
      }
      setState(() => _uploadProgress = 0.9);

      // Parse tags
      final tags = _tagsController.text
          .split(RegExp(r'[,\s#]+'))
          .map((t) => t.trim().toLowerCase())
          .where((t) => t.isNotEmpty)
          .toList();

      // Create post
      final result = await SocialService.createPost(
        caption: caption,
        postType: _postType,
        mediaUrls: mediaUrls,
        tags: tags,
        locationName: _postType == 'restaurant_visit' ? _locationController.text.trim() : null,
        visibility: _visibility,
      );

      // Handle recipe attachment if enabled
      if (result != null && _recipeAttachment != null) {
        final postId = result['id'] as String;
        final att = _recipeAttachment!;

        if (att.existingRecipeId != null) {
          // Link existing recipe to this post
          await RecipeMonetizationService.linkRecipeToPost(att.existingRecipeId!, postId);
        } else if (att.newRecipe != null) {
          // Create new recipe and link it
          final nr = att.newRecipe!;
          final recipe = await RecipeMonetizationService.createRecipe(
            title: nr.title,
            description: nr.description,
            cuisine: nr.cuisine,
            difficulty: nr.difficulty,
            prepTime: nr.prepTime,
            cookTime: nr.cookTime,
            servings: nr.servings,
            isPremium: att.isPremium,
            priceCents: att.priceCents,
            linkedPostId: postId,
            steps: nr.stepLines.map((s) => {'text': s}).toList(),
          );
          if (recipe != null) {
            await RecipeMonetizationService.linkRecipeToPost(recipe.id, postId);
          }
        }
      }

      setState(() => _uploadProgress = 1.0);

      if (!mounted) return;

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Posted successfully!'),
            backgroundColor: IFridgeTheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context, true); // Return true to trigger feed refresh
      } else {
        setState(() => _uploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Failed to post. Try again.'), backgroundColor: Colors.redAccent),
        );
      }
    } catch (e) {
      setState(() => _uploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('New Post', style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_uploading)
            TextButton(
              onPressed: _submit,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: IFridgeTheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Post', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
              ),
            ),
        ],
      ),
      body: _uploading ? _buildUploadingState() : _buildForm(),
    );
  }

  Widget _buildUploadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 80, height: 80,
            child: CircularProgressIndicator(
              value: _uploadProgress > 0 ? _uploadProgress : null,
              color: IFridgeTheme.primary,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _uploadProgress < 0.9 ? 'Uploading photos...' : 'Publishing...',
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          if (_uploadProgress > 0)
            Text(
              '${(_uploadProgress * 100).toInt()}%',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 14),
            ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Post Type Selector ──
          const Text('What are you sharing?',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Row(
            children: _postTypes.map((type) {
              final isSelected = _postType == type.$1;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _postType = type.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? IFridgeTheme.primary.withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? IFridgeTheme.primary.withValues(alpha: 0.5)
                            : Colors.white.withValues(alpha: 0.08),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(type.$2, style: const TextStyle(fontSize: 22)),
                        const SizedBox(height: 4),
                        Text(type.$3,
                            style: TextStyle(
                              color: isSelected ? IFridgeTheme.primary : Colors.white54,
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            )),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // ── Image Picker ──
          const Text('Photos',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),

          SizedBox(
            height: 110,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // Add buttons
                _addImageButton(Icons.photo_library, 'Gallery', _pickFromGallery),
                const SizedBox(width: 8),
                _addImageButton(Icons.camera_alt, 'Camera', _pickFromCamera),
                const SizedBox(width: 8),

                // Selected image previews
                ..._selectedImages.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: FutureBuilder<dynamic>(
                            future: entry.value.readAsBytes(),
                            builder: (_, snap) {
                              if (!snap.hasData) {
                                return Container(width: 100, height: 100, color: IFridgeTheme.bgElevated);
                              }
                              return Image.memory(snap.data!, width: 100, height: 100, fit: BoxFit.cover);
                            },
                          ),
                        ),
                        Positioned(
                          top: 2, right: 2,
                          child: GestureDetector(
                            onTap: () => _removeImage(entry.key),
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, color: Colors.white, size: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          if (_selectedImages.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                '${_selectedImages.length}/10 photos selected',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12),
              ),
            ),

          const SizedBox(height: 20),

          // ── Caption ──
          TextField(
            controller: _captionController,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Write a caption...',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
              filled: true,
              fillColor: IFridgeTheme.bgElevated,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),

          const SizedBox(height: 14),

          // ── Tags ──
          TextField(
            controller: _tagsController,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Tags (comma separated): pasta, italian, dinner',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.25)),
              filled: true,
              fillColor: IFridgeTheme.bgElevated,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              prefixIcon: Icon(Icons.tag, color: IFridgeTheme.primary.withValues(alpha: 0.5)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),

          const SizedBox(height: 14),

          // ── Location (for restaurant visits) ──
          if (_postType == 'restaurant_visit') ...[
            TextField(
              controller: _locationController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Restaurant name & location',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.25)),
                filled: true,
                fillColor: IFridgeTheme.bgElevated,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.location_on, color: const Color(0xFFFF6D00).withValues(alpha: 0.7)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 14),
          ],

          // ── Recipe Attachment ──
          RecipeAttachmentWidget(
            onChanged: (result) => _recipeAttachment = result,
          ),

          const SizedBox(height: 14),

          // ── Visibility ──
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: IFridgeTheme.bgElevated,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(
                  _visibility == 'public' ? Icons.public : Icons.people,
                  color: IFridgeTheme.primary.withValues(alpha: 0.7),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Visibility', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                      Text(
                        _visibility == 'public' ? 'Everyone can see this' : 'Only your followers',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11),
                      ),
                    ],
                  ),
                ),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'public', icon: Icon(Icons.public, size: 16)),
                    ButtonSegment(value: 'friends', icon: Icon(Icons.people, size: 16)),
                  ],
                  selected: {_visibility},
                  onSelectionChanged: (v) => setState(() => _visibility = v.first),
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      return states.contains(WidgetState.selected)
                          ? IFridgeTheme.primary.withValues(alpha: 0.2)
                          : Colors.transparent;
                    }),
                    foregroundColor: WidgetStateProperty.resolveWith((states) {
                      return states.contains(WidgetState.selected)
                          ? IFridgeTheme.primary
                          : Colors.white38;
                    }),
                    side: WidgetStateProperty.all(BorderSide(color: Colors.white.withValues(alpha: 0.1))),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _addImageButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: _selectedImages.length >= 10 ? null : onTap,
      child: Container(
        width: 100, height: 100,
        decoration: BoxDecoration(
          color: IFridgeTheme.bgElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: IFridgeTheme.primary.withValues(alpha: 0.3),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: IFridgeTheme.primary.withValues(alpha: 0.6), size: 28),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(color: IFridgeTheme.primary.withValues(alpha: 0.6), fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
