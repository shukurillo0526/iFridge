// Stub implementation for non-web platforms.
// These functions are never actually called on mobile
// (YouTubeEmbed checks kIsWeb first), but must exist for compilation.

import 'package:flutter/material.dart';

Widget buildWebEmbed(String youtubeId, {bool autoplay = false}) {
  // Should never be called on mobile — YouTubeEmbed checks kIsWeb
  return SizedBox.shrink();
}

void registerView(String youtubeId) {
  // No-op on mobile
}
