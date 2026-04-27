// I-Fridge — Explore Screen
// ===========================
// Social discovery hub with two tabs:
// 1. Reels — vertical video/tip feed
// 2. Community — recipe cards from the community
// Features: likes, bookmarks, external video links, tags.

import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ifridge_app/core/theme/app_theme.dart';
import 'package:ifridge_app/core/services/video_feed_service.dart';
import 'package:ifridge_app/core/services/auth_helper.dart';
import 'package:ifridge_app/features/explore/presentation/screens/creator_page.dart';
import 'package:ifridge_app/features/cook/presentation/screens/recipe_detail_screen.dart';
import 'package:ifridge_app/core/widgets/youtube_embed.dart';
import 'package:ifridge_app/core/widgets/community_post_card.dart';
import 'package:ifridge_app/core/services/social_service.dart';
import 'package:ifridge_app/features/profile/presentation/screens/post_upload_form.dart';
import 'package:ifridge_app/core/widgets/story_ring.dart';
import 'package:ifridge_app/features/explore/presentation/screens/social_search_page.dart';
import 'package:share_plus/share_plus.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});
  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  const Text('✨', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 10),
                  const Text('Explore',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.search, color: Colors.white54),
                      onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const SocialSearchPage())),
                      tooltip: 'Search',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.bookmark_outline, color: Colors.white54),
                      onPressed: () => _showBookmarks(context),
                      tooltip: 'Saved',
                    ),
                  ),
                ],
              ),
            ),

            // ── Tab Bar ─────────────────────────────────
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: IFridgeTheme.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                labelColor: IFridgeTheme.primary,
                unselectedLabelColor: Colors.white54,
                labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                tabs: const [
                  Tab(text: '🎬 Reels'),
                  Tab(text: '🍽️ Community'),
                ],
              ),
            ),

            // ── Tab Content ─────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  _ReelsFeed(),
                  _CommunityFeed(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBookmarks(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => const _BookmarksSheet(),
    );
  }
}

// ── YouTube-Backed Reels Feed ──────────────────────────────────────────

class _ReelsFeed extends StatefulWidget {
  const _ReelsFeed();
  @override
  State<_ReelsFeed> createState() => _ReelsFeedState();
}

class _ReelsFeedState extends State<_ReelsFeed> {
  final PageController _pgCtrl = PageController();
  List<VideoFeed> _videos = [];
  int _current = 0;
  bool _loading = true;
  final Set<String> _registered = {};

  @override
  void initState() { super.initState(); _load(); }

  @override
  void dispose() { _pgCtrl.dispose(); super.dispose(); }

  Future<void> _load() async {
    final v = await VideoFeedService.getCookFeeds();
    if (mounted) setState(() { _videos = v; _loading = false; });
  }

  void _reg(String ytId) {
    registerYouTubeView(ytId);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: IFridgeTheme.primary));
    if (_videos.isEmpty) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Text('🎬', style: TextStyle(fontSize: 48)),
      const SizedBox(height: 12),
      Text('No reels yet', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 16)),
    ]));

    return PageView.builder(
      controller: _pgCtrl,
      scrollDirection: Axis.vertical,
      itemCount: _videos.length,
      onPageChanged: (i) => setState(() => _current = i),
      itemBuilder: (ctx, i) => _YTReelCard(video: _videos[i], isActive: i == _current, reg: _reg),
    );
  }
}

class _YTReelCard extends StatefulWidget {
  final VideoFeed video;
  final bool isActive;
  final void Function(String) reg;
  const _YTReelCard({required this.video, required this.isActive, required this.reg});
  @override
  State<_YTReelCard> createState() => _YTReelCardState();
}

class _YTReelCardState extends State<_YTReelCard> {
  bool _liked = false;
  bool _playing = false;
  bool _showRecipe = false;
  bool _saved = false;

  @override
  void didUpdateWidget(covariant _YTReelCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Auto-stop playback when scrolled off-screen to free iframe memory
    if (oldWidget.isActive && !widget.isActive && _playing) {
      setState(() => _playing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.video;
    const green = Color(0xFF4CAF50);
    final viewKey = 'yt-reel-${v.youtubeId}';

    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Video or Thumbnail ──────────────────
          if (_playing && widget.isActive) ...[
            Builder(builder: (_) { widget.reg(v.youtubeId); return YouTubeEmbed(youtubeId: v.youtubeId); }),
            // Close button to stop video and resume scrolling
            Positioned(top: 12, right: 12, child: GestureDetector(
              onTap: () => setState(() => _playing = false),
              child: Container(padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), shape: BoxShape.circle),
                child: const Icon(Icons.close, color: Colors.white, size: 20)))),
          ] else
            GestureDetector(
              onTap: () => setState(() => _playing = true),
              child: Stack(fit: StackFit.expand, children: [
                Image.network(v.thumbnailUrl, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade900)),
                Container(decoration: BoxDecoration(gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.black.withValues(alpha: 0.05), Colors.black.withValues(alpha: 0.75)]))),
                Center(child: Container(padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: green.withValues(alpha: 0.25), shape: BoxShape.circle),
                  child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 44))),
              ]),
            ),

          // ── Recipe overlay ──────────────────────
          if (_showRecipe && v.hasRecipe)
            _VideoRecipeSheet(video: v, onClose: () => setState(() => _showRecipe = false)),

          // ── Sidebar ──────────────────────────────
          if (!_showRecipe && !_playing)
            Positioned(right: 12, bottom: 80, child: Column(children: [
              _FeedSideBtn(icon: _liked ? Icons.favorite : Icons.favorite_border,
                label: v.likesLabel, color: _liked ? Colors.red : Colors.white,
                onTap: () => setState(() => _liked = !_liked)),
              const SizedBox(height: 16),
              if (v.hasRecipe)
                _FeedSideBtn(icon: Icons.restaurant_menu, label: 'Cook', color: green,
                  highlighted: true, onTap: () => setState(() => _showRecipe = true)),
              if (v.hasRecipe) const SizedBox(height: 16),
              _FeedSideBtn(icon: Icons.reply_outlined, label: 'Share', color: Colors.white,
                onTap: () => SharePlus.instance.share(ShareParams(
                  text: '${v.title}\nhttps://youtube.com/watch?v=${v.youtubeId}',
                ))),
              const SizedBox(height: 16),
              _FeedSideBtn(icon: _saved ? Icons.bookmark : Icons.bookmark_outline,
                label: _saved ? 'Saved' : 'Save',
                color: _saved ? green : Colors.white,
                onTap: () => setState(() => _saved = !_saved)),
              const SizedBox(height: 16),
              Container(width: 38, height: 38, decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF81C784)]),
                border: Border.all(color: Colors.white, width: 2)),
                child: Center(child: Text(v.authorName.isNotEmpty ? v.authorName[0] : '?',
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)))),
            ])),

          // ── Bottom info ──────────────────────────
          if (!_showRecipe && !_playing)
            Positioned(left: 16, right: 70, bottom: 12, child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('@${v.authorName.replaceAll(' ', '_').toLowerCase()}',
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(v.title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                if (v.hasRecipe) Row(children: [
                  if (v.recipePrepTime.isNotEmpty) _pill('⏱ ${v.recipePrepTime}', green),
                  if (v.recipeCookTime.isNotEmpty) ...[const SizedBox(width: 5), _pill('🔥 ${v.recipeCookTime}', Colors.orange)],
                ]),
                const SizedBox(height: 4),
                if (v.tags.isNotEmpty) Wrap(spacing: 5, children: v.tags.take(3).map((t) =>
                  Text('#$t', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 10, fontWeight: FontWeight.w600))).toList()),
              ])),
        ],
      ),
    );
  }

  Widget _pill(String t, Color c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(color: c.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
    child: Text(t, style: TextStyle(color: c, fontSize: 9, fontWeight: FontWeight.w700)));
}

class _FeedSideBtn extends StatelessWidget {
  final IconData icon; final String label; final Color color;
  final bool highlighted; final VoidCallback onTap;
  const _FeedSideBtn({required this.icon, required this.label, required this.color, this.highlighted = false, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap, behavior: HitTestBehavior.opaque,
    child: Column(children: [
      Container(width: 40, height: 40,
        decoration: BoxDecoration(shape: BoxShape.circle,
          color: highlighted ? color.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.08),
          border: highlighted ? Border.all(color: color.withValues(alpha: 0.5), width: 1.5) : null),
        child: Icon(icon, size: 20, color: color)),
      const SizedBox(height: 2),
      Text(label, style: TextStyle(color: color.withValues(alpha: 0.9), fontSize: 9, fontWeight: FontWeight.w600)),
    ]));
}

class _VideoRecipeSheet extends StatelessWidget {
  final VideoFeed video;
  final VoidCallback onClose;
  const _VideoRecipeSheet({required this.video, required this.onClose});
  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF4CAF50);
    return Container(
      color: Colors.black.withValues(alpha: 0.92),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(video.recipeTitle,
            style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800))),
          GestureDetector(onTap: onClose, child: Container(padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.close, color: Colors.white, size: 16))),
        ]),
        const SizedBox(height: 8),
        Expanded(child: ListView(children: [
          const Text('Ingredients', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          ...video.recipeIngredients.map((i) => Padding(padding: const EdgeInsets.only(bottom: 2),
            child: Row(children: [
              Container(width: 4, height: 4, decoration: const BoxDecoration(color: green, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Expanded(child: Text(i, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12))),
            ]))),
          const SizedBox(height: 10),
          const Text('Steps', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          ...video.recipeSteps.asMap().entries.map((e) => Padding(padding: const EdgeInsets.only(bottom: 6),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 20, height: 20,
                decoration: BoxDecoration(color: green.withValues(alpha: 0.2), shape: BoxShape.circle),
                child: Center(child: Text('${e.key + 1}', style: TextStyle(color: green, fontSize: 10, fontWeight: FontWeight.w700)))),
              const SizedBox(width: 8),
              Expanded(child: Text(e.value, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12, height: 1.3))),
            ]))),
        ])),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () { ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('✅ "${video.recipeTitle}" saved!'),
            backgroundColor: green, behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))); onClose(); },
          child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF81C784)]),
              borderRadius: BorderRadius.circular(12)),
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.restaurant_menu, color: Colors.white, size: 16),
              SizedBox(width: 6),
              Text('Cook This Recipe', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
            ])),
        ),
      ]),
    );
  }
}



class _ReelCard extends StatefulWidget {
  final Map<String, dynamic> post;
  const _ReelCard({required this.post});
  @override
  State<_ReelCard> createState() => _ReelCardState();
}

class _ReelCardState extends State<_ReelCard> {
  bool _liked = false;
  bool _bookmarked = false;
  int _likeCount = 0;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.post['like_count'] ?? 0;
    _checkUserInteractions();
  }

  Future<void> _checkUserInteractions() async {
    try {
      final userId = currentUserId();
      final postId = widget.post['id'];
      final likes = await Supabase.instance.client
          .from('post_likes').select('user_id')
          .eq('user_id', userId).eq('post_id', postId);
      final bookmarks = await Supabase.instance.client
          .from('post_bookmarks').select('user_id')
          .eq('user_id', userId).eq('post_id', postId);
      if (mounted) {
        setState(() {
          _liked = (likes as List).isNotEmpty;
          _bookmarked = (bookmarks as List).isNotEmpty;
        });
      }
    } catch (_) {}
  }

  Future<void> _toggleLike() async {
    final userId = currentUserId();
    final postId = widget.post['id'];
    setState(() { _liked = !_liked; _likeCount += _liked ? 1 : -1; });
    try {
      if (_liked) {
        await Supabase.instance.client.from('post_likes').insert({'user_id': userId, 'post_id': postId});
      } else {
        await Supabase.instance.client.from('post_likes').delete().eq('user_id', userId).eq('post_id', postId);
      }
    } catch (_) {}
  }

  Future<void> _toggleBookmark() async {
    final userId = currentUserId();
    final postId = widget.post['id'];
    setState(() => _bookmarked = !_bookmarked);
    try {
      if (_bookmarked) {
        await Supabase.instance.client.from('post_bookmarks').insert({'user_id': userId, 'post_id': postId});
      } else {
        await Supabase.instance.client.from('post_bookmarks').delete().eq('user_id', userId).eq('post_id', postId);
      }
    } catch (_) {}
  }

  void _showInlineRecipe(BuildContext context, String recipeId, String caption) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: FutureBuilder(
                future: Supabase.instance.client
                    .from('recipes')
                    .select('*, recipe_ingredients(*, ingredients(display_name_en, default_unit))')
                    .eq('id', recipeId)
                    .maybeSingle(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: IFridgeTheme.primary));
                  }
                  if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                    return const Center(child: Text('Recipe not found', style: TextStyle(color: Colors.white54)));
                  }
                  
                  final recipe = snapshot.data as Map<String, dynamic>;
                  final ingredients = (recipe['recipe_ingredients'] as List?)?.cast<Map<String, dynamic>>() ?? [];
                  final rawSteps = recipe['instructions'];
                  final steps = rawSteps is List ? rawSteps.cast<String>() : 
                      (rawSteps is String ? rawSteps.split('. ') : []);

                  return Column(
                    children: [
                      // Handle bar
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        width: 40, height: 4,
                        decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                      ),
                      
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text(recipe['title'] ?? 'Recipe', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
                            IconButton(
                              icon: const Icon(Icons.open_in_new, color: IFridgeTheme.primary),
                              tooltip: 'Open Full Recipe',
                              onPressed: () {
                                Navigator.pop(ctx);
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (_) => RecipeDetailScreen(
                                    recipeId: recipeId,
                                    title: recipe['title'] ?? '',
                                    tierColor: IFridgeTheme.primary,
                                    ownedIngredientIds: const {},
                                  )
                                ));
                              },
                            )
                          ],
                        ),
                      ),
                      
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          padding: const EdgeInsets.all(20),
                          children: [
                            // Quick stats
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _InfoChip(icon: Icons.timer, label: '${recipe['prep_time_minutes'] ?? 0}m prep'),
                                _InfoChip(icon: Icons.local_fire_department, label: '${recipe['calories_per_serving'] ?? 0} cal'),
                              ],
                            ),
                            const SizedBox(height: 24),
                            
                            // Ingredients
                            const Text('Ingredients', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            ...ingredients.map((ing) {
                                final detail = ing['ingredients'] as Map?;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.circle, size: 8, color: IFridgeTheme.primary),
                                      const SizedBox(width: 12),
                                      Expanded(child: Text(detail?['display_name_en'] ?? 'Unknown', style: const TextStyle(color: Colors.white, fontSize: 15))),
                                      Text('${ing['quantity']} ${ing['unit'] ?? detail?['default_unit'] ?? ''}', style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
                                    ],
                                  ),
                                );
                            }),
                            
                            const SizedBox(height: 24),
                            // Steps
                            const Text('Steps', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            ...steps.asMap().entries.map((req) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 24, height: 24,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(color: IFridgeTheme.primary.withValues(alpha: 0.2), shape: BoxShape.circle),
                                      child: Text('${req.key + 1}', style: const TextStyle(color: IFridgeTheme.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(child: Text(req.value, style: TextStyle(color: Colors.white.withValues(alpha: 0.9), height: 1.5))),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final caption = widget.post['caption'] ?? '';
    final tags = List<String>.from(widget.post['tags'] ?? []);
    final videoUrl = widget.post['video_url'];
    final author = widget.post['users'] as Map<String, dynamic>?;
    final authorName = author?['display_name'] ?? 'Chef';
    final postType = widget.post['post_type'] ?? 'tip';
    final isReel = postType == 'reel' && videoUrl != null;
    final recipeId = widget.post['recipe_id'];

    // Color based on post type
    final gradColors = isReel
        ? [Colors.deepPurple.withValues(alpha: 0.5), Colors.black.withValues(alpha: 0.9)]
        : [IFridgeTheme.primary.withValues(alpha: 0.3), Colors.black.withValues(alpha: 0.9)];

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradColors,
        ),
      ),
      child: Stack(
        children: [
          // Center icon / type indicator
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(isReel ? Icons.play_circle_outline : Icons.lightbulb_outline,
                  size: 72, color: Colors.white.withValues(alpha: 0.1)),
                const SizedBox(height: 8),
                Text(isReel ? 'Video Reel' : 'Cooking Tip',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.1), fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ),

          // Right-side action column (TikTok-style)
          Positioned(
            right: 12,
            bottom: 120,
            child: Column(
              children: [
                // Author avatar
                GestureDetector(
                  onTap: () {
                    final authorId = widget.post['author_id'];
                    if (authorId != null) {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => CreatorPage(creatorId: authorId, creatorName: authorName)));
                    }
                  },
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: IFridgeTheme.primary.withValues(alpha: 0.3),
                    child: Text(authorName[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 20),
                // Like
                _VerticalAction(
                  icon: _liked ? Icons.favorite : Icons.favorite_border,
                  color: _liked ? Colors.red : Colors.white,
                  label: '$_likeCount',
                  onTap: _toggleLike),
                const SizedBox(height: 16),
                // Bookmark
                _VerticalAction(
                  icon: _bookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: _bookmarked ? IFridgeTheme.primary : Colors.white,
                  label: _bookmarked ? 'Saved' : 'Save',
                  onTap: _toggleBookmark),
                const SizedBox(height: 16),
                if (recipeId != null)
                  _VerticalAction(
                    icon: Icons.restaurant_menu,
                    color: Colors.orange,
                    label: 'Recipe',
                    onTap: () => _showInlineRecipe(context, recipeId, caption)),
                if (recipeId != null) const SizedBox(height: 16),
                // Play video
                if (isReel)
                  _VerticalAction(
                    icon: Icons.play_arrow,
                    color: Colors.red,
                    label: 'Play',
                    onTap: () async {
                      final uri = Uri.parse(videoUrl);
                      if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }),
              ],
            ),
          ),

          // Bottom overlay — caption, author, tags
          Positioned(
            left: 16,
            right: 60,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Author name
                GestureDetector(
                  onTap: () {
                    final authorId = widget.post['author_id'];
                    if (authorId != null) {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => CreatorPage(creatorId: authorId, creatorName: authorName)));
                    }
                  },
                  child: Text('@$authorName',
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 6),
                // Caption
                Text(caption,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4)),
                const SizedBox(height: 8),
                // Tags
                if (tags.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: tags.map((t) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8)),
                      child: Text('#$t',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11)),
                    )).toList(),
                  ),
                // Recipe badge
                if (recipeId != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orange.withValues(alpha: 0.3))),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.restaurant_menu, size: 14, color: Colors.orange),
                        SizedBox(width: 4),
                        Text('Has Recipe', style: TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
  const _VerticalAction({required this.icon, required this.color, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ── Community Recipe Feed ─────────────────────────────────────────

class _CommunityFeed extends StatefulWidget {
  const _CommunityFeed();
  @override
  State<_CommunityFeed> createState() => _CommunityFeedState();
}

class _CommunityFeedState extends State<_CommunityFeed> {
  List<Map<String, dynamic>> _posts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    try {
      final data = await SocialService.getCommunityFeed(limit: 30);
      if (mounted) setState(() { _posts = data; _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openCreatePost() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const EnhancedPostUploadForm()),
    );
    if (result == true) _loadPosts(); // Refresh after new post
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: IFridgeTheme.primary));
    }

    return Stack(
      children: [
        // Main content
        _posts.isEmpty
          ? Column(
              children: [
                // Story ring even when no posts
                const StoryRing(),
                const Divider(color: Colors.white12, height: 1),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('\u{1F37D}\u{FE0F}', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        Text('No community posts yet',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 16)),
                        const SizedBox(height: 8),
                        Text('Be the first to share!',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 13)),
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          onPressed: _openCreatePost,
                          icon: const Icon(Icons.add_a_photo, size: 18),
                          label: const Text('Create Post'),
                          style: FilledButton.styleFrom(
                            backgroundColor: IFridgeTheme.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : RefreshIndicator(
              color: IFridgeTheme.primary,
              onRefresh: _loadPosts,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                itemCount: _posts.length + 1, // +1 for story ring
                itemBuilder: (ctx, i) {
                  if (i == 0) {
                    return Column(
                      children: [
                        const StoryRing(),
                        Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),
                        const SizedBox(height: 8),
                      ],
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: CommunityPostCard(post: _posts[i - 1]),
                  );
                },
              ),
            ),

        // \u2500\u2500 FAB: Create new post \u2500\u2500
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            heroTag: 'community_fab',
            backgroundColor: IFridgeTheme.primary,
            onPressed: _openCreatePost,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

// ── Bookmarks Sheet ─────────────────────────────────────────────

class _BookmarksSheet extends StatefulWidget {
  const _BookmarksSheet();
  @override
  State<_BookmarksSheet> createState() => _BookmarksSheetState();
}

class _BookmarksSheetState extends State<_BookmarksSheet> {
  List<Map<String, dynamic>> _bookmarks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    try {
      final userId = currentUserId();
      final data = await Supabase.instance.client
          .from('post_bookmarks')
          .select('*, posts(caption, post_type, tags)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      setState(() { _bookmarks = List<Map<String, dynamic>>.from(data); _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bookmark, color: IFridgeTheme.primary, size: 22),
              SizedBox(width: 8),
              Text('Saved Posts',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 16),
          if (_loading)
            const Center(child: CircularProgressIndicator(color: IFridgeTheme.primary))
          else if (_bookmarks.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text('No saved posts yet',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.4))),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _bookmarks.length,
                itemBuilder: (ctx, i) {
                  final bm = _bookmarks[i];
                  final post = bm['posts'] as Map<String, dynamic>?;
                  final caption = post?['caption'] ?? 'Saved post';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(caption,
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white54),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
