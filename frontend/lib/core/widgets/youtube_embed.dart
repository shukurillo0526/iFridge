// Platform-aware YouTube embed widget.
// Web: uses HtmlElementView with iframe
// Mobile: shows thumbnail + tap-to-open in external YouTube app

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// Conditional imports for web-only dart:html / dart:ui_web
import 'youtube_embed_stub.dart'
    if (dart.library.html) 'youtube_embed_web.dart' as platform;

/// A YouTube video embed that works on both web and mobile.
///
/// On **web**: renders an iframe via HtmlElementView.
/// On **mobile**: shows a thumbnail with a play button; tapping opens YouTube.
class YouTubeEmbed extends StatelessWidget {
  final String youtubeId;
  final bool autoplay;

  const YouTubeEmbed({
    super.key,
    required this.youtubeId,
    this.autoplay = false,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return platform.buildWebEmbed(youtubeId, autoplay: autoplay);
    }

    // Mobile: thumbnail + tap to open YouTube
    return GestureDetector(
      onTap: () => _openYouTube(youtubeId),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // YouTube thumbnail
          Image.network(
            'https://img.youtube.com/vi/$youtubeId/hqdefault.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Center(
                child: Icon(Icons.play_circle_outline, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54), size: 64),
              ),
            ),
          ),
          // Play overlay
          Center(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.play_arrow, color: Theme.of(context).colorScheme.onSurface, size: 48),
            ),
          ),
          // "Opens in YouTube" label
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Tap to open in YouTube',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 11),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> _openYouTube(String id) async {
    final url = Uri.parse('https://www.youtube.com/watch?v=$id');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}

/// Register a YouTube view factory (no-op on mobile).
void registerYouTubeView(String youtubeId) {
  if (kIsWeb) {
    platform.registerView(youtubeId);
  }
}
