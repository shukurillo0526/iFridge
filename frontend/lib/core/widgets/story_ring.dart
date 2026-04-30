// I-Fridge — Story Ring
// ======================
// Horizontal scrollable row of user story avatars.
// - Gradient ring = has unviewed stories
// - Grey ring = all viewed
// - "+" button = add your own story
// Lives at top of the Community feed tab.

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ifridge_app/core/services/story_service.dart';
import 'package:ifridge_app/core/widgets/story_viewer.dart';

class StoryRing extends StatefulWidget {
  const StoryRing({super.key});

  @override
  State<StoryRing> createState() => StoryRingState();
}

class StoryRingState extends State<StoryRing> {
  List<StoryGroup> _groups = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    loadStories();
  }

  Future<void> loadStories() async {
    final groups = await StoryService.getStoryGroups();
    if (mounted) setState(() { _groups = groups; _loading = false; });
  }

  void _openStoryViewer(int index) async {
    final result = await Navigator.push<bool>(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, _, _) => StoryViewer(
          groups: _groups,
          initialGroupIndex: index,
        ),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
    if (result == true) loadStories(); // Refresh if a story was deleted
  }

  void _addStory() async {
    // Show bottom sheet to pick camera or gallery
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text('Add Story',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.w700)),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _sourceButton(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () => Navigator.pop(ctx, ImageSource.camera),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _sourceButton(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
          ],
        ),
      ),
    );

    if (source == null) return;

    // Pick image
    final file = await StoryService.pickStoryImage(source: source);
    if (file == null) return;

    // Show uploading indicator
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          SizedBox(width: 16, height: 16,
            child: CircularProgressIndicator(color: Theme.of(context).colorScheme.onSurface, strokeWidth: 2)),
          SizedBox(width: 12),
          Text('Uploading story...'),
        ]),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 10),
      ),
    );

    // Upload media
    final url = await StoryService.uploadStoryMedia(file);
    if (url == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    // Create story
    final success = await StoryService.createStory(mediaUrl: url);
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Story posted!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      loadStories(); // Refresh ring
    }
  }

  Widget _sourceButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
            SizedBox(height: 6),
            Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: _loading
          ? Center(
              child: SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary, strokeWidth: 2)),
            )
          : ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 12),
              children: [
                // ── Add Story Button ──
                _AddStoryAvatar(onTap: _addStory),

                // ── Story groups ──
                ..._groups.asMap().entries.map((entry) {
                  final group = entry.value;
                  return _StoryAvatar(
                    name: group.isOwn ? 'You' : group.userName,
                    hasUnviewed: group.hasUnviewed,
                    isOwn: group.isOwn,
                    storyCount: group.stories.length,
                    onTap: () => _openStoryViewer(entry.key),
                  );
                }),
              ],
            ),
    );
  }
}

// ── Add Story Avatar ──

class _AddStoryAvatar extends StatelessWidget {
  final VoidCallback onTap;
  const _AddStoryAvatar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 68,
        margin: EdgeInsets.only(right: 8),
        child: Column(
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4), width: 2),
              ),
              child: Center(
                child: Icon(Icons.add, color: Theme.of(context).colorScheme.primary, size: 26),
              ),
            ),
            SizedBox(height: 4),
            Text('Add',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 11, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ── Story Avatar Ring ──

class _StoryAvatar extends StatelessWidget {
  final String name;
  final bool hasUnviewed;
  final bool isOwn;
  final int storyCount;
  final VoidCallback onTap;

  const _StoryAvatar({
    required this.name,
    required this.hasUnviewed,
    required this.isOwn,
    required this.storyCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 68,
        margin: EdgeInsets.only(right: 8),
        child: Column(
          children: [
            // Avatar with gradient ring
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: hasUnviewed
                    ? SweepGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                          Color(0xFF00E5FF),
                          Theme.of(context).colorScheme.primary,
                        ],
                      )
                    : null,
                border: hasUnviewed
                    ? null
                    : Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2), width: 2),
              ),
              padding: EdgeInsets.all(2.5),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: hasUnviewed ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54),
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 4),
            Text(
              name.length > 8 ? '${name.substring(0, 7)}…' : name,
              style: TextStyle(
                color: hasUnviewed ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54),
                fontSize: 11,
                fontWeight: hasUnviewed ? FontWeight.w700 : FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
