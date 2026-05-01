// I-Fridge — Story Viewer
// ========================
// Full-screen story viewer with:
// - Auto-advance timer (5s per story)
// - Progress bars at top (Instagram-style)
// - Tap left/right to navigate
// - Swipe down to dismiss
// - Author info overlay
// - Caption at bottom

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ifridge_app/core/services/story_service.dart';

class StoryViewer extends StatefulWidget {
  final List<StoryGroup> groups;
  final int initialGroupIndex;

  const StoryViewer({
    super.key,
    required this.groups,
    this.initialGroupIndex = 0,
  });

  @override
  State<StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends State<StoryViewer> with SingleTickerProviderStateMixin {
  late int _groupIndex;
  int _storyIndex = 0;
  late AnimationController _progressController;
  Timer? _autoAdvanceTimer;

  static const _storyDuration = Duration(seconds: 5);

  StoryGroup get _currentGroup => widget.groups[_groupIndex];
  StoryItem get _currentStory => _currentGroup.stories[_storyIndex];

  @override
  void initState() {
    super.initState();
    _groupIndex = widget.initialGroupIndex;
    _progressController = AnimationController(
      vsync: this,
      duration: _storyDuration,
    );
    _startStory();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _autoAdvanceTimer?.cancel();
    super.dispose();
  }

  void _startStory() {
    _progressController.reset();
    _progressController.forward();

    // Mark as viewed
    StoryService.markViewed(_currentStory.id);

    // Auto-advance after duration
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = Timer(_storyDuration, _nextStory);
  }

  void _nextStory() {
    if (_storyIndex < _currentGroup.stories.length - 1) {
      setState(() => _storyIndex++);
      _startStory();
    } else {
      _nextGroup();
    }
  }

  void _prevStory() {
    if (_storyIndex > 0) {
      setState(() => _storyIndex--);
      _startStory();
    } else {
      _prevGroup();
    }
  }

  void _nextGroup() {
    if (_groupIndex < widget.groups.length - 1) {
      setState(() {
        _groupIndex++;
        _storyIndex = 0;
      });
      _startStory();
    } else {
      Navigator.pop(context);
    }
  }

  void _prevGroup() {
    if (_groupIndex > 0) {
      setState(() {
        _groupIndex--;
        _storyIndex = 0;
      });
      _startStory();
    }
  }

  void _pause() {
    _progressController.stop();
    _autoAdvanceTimer?.cancel();
  }

  void _resume() {
    _progressController.forward();
    final remaining = _storyDuration * (1 - _progressController.value);
    _autoAdvanceTimer = Timer(remaining, _nextStory);
  }

  @override
  Widget build(BuildContext context) {
    final story = _currentStory;
    final group = _currentGroup;
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: GestureDetector(
        // Tap left half = prev, right half = next
        onTapUp: (details) {
          final w = MediaQuery.of(context).size.width;
          if (details.globalPosition.dx < w / 3) {
            _prevStory();
          } else {
            _nextStory();
          }
        },
        // Long press to pause
        onLongPressStart: (_) => _pause(),
        onLongPressEnd: (_) => _resume(),
        // Swipe down to dismiss
        onVerticalDragEnd: (details) {
          if ((details.primaryVelocity ?? 0) > 300) {
            Navigator.pop(context);
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Story Image ──
            CachedNetworkImage(
              imageUrl: story.mediaUrl,
              fit: BoxFit.cover,
              placeholder: (_, _) => Center(
                child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary, strokeWidth: 2),
              ),
              errorWidget: (_, _, _) => Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Center(
                  child: Icon(Icons.broken_image, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24), size: 56),
                ),
              ),
            ),

            // ── Top gradient ──
            Positioned(
              top: 0, left: 0, right: 0,
              child: Container(
                height: 120 + topPad,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // ── Bottom gradient ──
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // ── Progress bars ──
            Positioned(
              top: topPad + 8,
              left: 8, right: 8,
              child: Row(
                children: List.generate(group.stories.length, (i) {
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 2),
                      height: 2.5,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: i < _storyIndex
                            ? Container(color: Theme.of(context).colorScheme.onSurface)
                            : i == _storyIndex
                                ? AnimatedBuilder(
                                    animation: _progressController,
                                    builder: (_, _) => LinearProgressIndicator(
                                      value: _progressController.value,
                                      backgroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.onSurface),
                                      minHeight: 2.5,
                                    ),
                                  )
                                : Container(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // ── Author info ──
            Positioned(
              top: topPad + 20,
              left: 12, right: 12,
              child: Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                    child: Text(
                      group.userName.isNotEmpty ? group.userName[0].toUpperCase() : '?',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 12, fontWeight: FontWeight.w800),
                    ),
                  ),
                  SizedBox(width: 8),
                  // Name
                  Text(
                    group.userName,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(width: 8),
                  // Time ago
                  Text(
                    _timeAgo(story.createdAt),
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12),
                  ),
                  Spacer(),
                  // Close button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            // ── Caption ──
            if (story.caption != null && story.caption!.isNotEmpty)
              Positioned(
                bottom: 24 + MediaQuery.of(context).padding.bottom,
                left: 16, right: 16,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    story.caption!,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 15, height: 1.4),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

            // ── Delete button (own stories) ──
            if (group.isOwn)
              Positioned(
                top: topPad + 20,
                right: 52,
                child: GestureDetector(
                  onTap: () async {
                    await StoryService.deleteStory(story.id);
                    if (group.stories.length <= 1) {
                      if (mounted) Navigator.pop(context, true); // refresh
                    } else {
                      setState(() {
                        group.stories.removeAt(_storyIndex);
                        if (_storyIndex >= group.stories.length) {
                          _storyIndex = group.stories.length - 1;
                        }
                      });
                      _startStory();
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), size: 18),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
