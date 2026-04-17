// I-Fridge — Video Feed Service
// ================================
// Fetches video feed data from Supabase (video_feeds table).
// Provides VideoFeed model with YouTube embed URLs and recipe data.

import 'package:supabase_flutter/supabase_flutter.dart';

class VideoFeed {
  final String id;
  final String youtubeId;
  final String tabType; // 'cook' or 'order'
  final String title;
  final String? description;
  final String thumbnailUrl;
  final String embedUrl;
  final String authorName;
  final List<String> tags;
  final Map<String, dynamic>? recipeJson;
  final String? restaurantId;
  final int likes;

  VideoFeed({
    required this.id,
    required this.youtubeId,
    required this.tabType,
    required this.title,
    this.description,
    required this.thumbnailUrl,
    required this.embedUrl,
    required this.authorName,
    this.tags = const [],
    this.recipeJson,
    this.restaurantId,
    required this.likes,
  });

  factory VideoFeed.fromMap(Map<String, dynamic> map) {
    return VideoFeed(
      id: map['id'] as String? ?? '',
      youtubeId: map['youtube_id'] as String? ?? '',
      tabType: map['tab_type'] as String? ?? 'cook',
      title: map['title'] as String? ?? '',
      description: map['description'] as String?,
      thumbnailUrl: map['thumbnail_url'] as String? ?? '',
      embedUrl: map['embed_url'] as String? ?? '',
      authorName: map['author_name'] as String? ?? 'Unknown',
      tags: (map['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      recipeJson: map['recipe_json'] as Map<String, dynamic>?,
      restaurantId: map['restaurant_id'] as String?,
      likes: (map['likes'] as num?)?.toInt() ?? 0,
    );
  }

  /// Embed URL with autoplay for inline playback
  String get autoplayEmbedUrl =>
      '$embedUrl?autoplay=1&mute=1&loop=1&controls=0&playsinline=1&rel=0';

  /// YouTube Shorts URL for opening externally
  String get shortsUrl => 'https://youtube.com/shorts/$youtubeId';

  /// YouTube watch URL
  String get watchUrl => 'https://www.youtube.com/watch?v=$youtubeId';

  /// Has a recipe (cook tab)
  bool get hasRecipe => recipeJson != null && recipeJson!.isNotEmpty;

  /// Extract recipe fields
  String get recipeTitle => recipeJson?['title'] as String? ?? title;
  String get recipePrepTime => recipeJson?['prep_time'] as String? ?? '';
  String get recipeCookTime => recipeJson?['cook_time'] as String? ?? '';
  String get recipeDifficulty => recipeJson?['difficulty'] as String? ?? '';
  int get recipeServings => (recipeJson?['servings'] as num?)?.toInt() ?? 0;

  List<String> get recipeIngredients =>
      (recipeJson?['ingredients'] as List<dynamic>?)?.cast<String>() ?? [];

  List<String> get recipeSteps =>
      (recipeJson?['steps'] as List<dynamic>?)?.cast<String>() ?? [];

  /// Formatted likes
  String get likesLabel {
    if (likes >= 1000) {
      return '${(likes / 1000).toStringAsFixed(1)}k';
    }
    return '$likes';
  }
}

class VideoFeedService {
  /// Fetch video feeds by tab type
  static Future<List<VideoFeed>> getFeeds({required String tabType}) async {
    try {
      final data = await Supabase.instance.client
          .rpc('get_video_feeds', params: {'feed_type': tabType}) as List<dynamic>;
      return data.map((e) => VideoFeed.fromMap(e as Map<String, dynamic>)).toList();
    } catch (_) {
      // RPC not available, try direct query
      try {
        final data = await Supabase.instance.client
            .from('video_feeds')
            .select()
            .eq('tab_type', tabType)
            .eq('is_active', true)
            .order('likes', ascending: false);
        return (data as List<dynamic>)
            .map((e) => VideoFeed.fromMap(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        return [];
      }
    }
  }

  /// Fetch cook videos
  static Future<List<VideoFeed>> getCookFeeds() => getFeeds(tabType: 'cook');

  /// Fetch order videos
  static Future<List<VideoFeed>> getOrderFeeds() => getFeeds(tabType: 'order');
}
