// I-Fridge — Explore Screen
// ===========================
// Social discovery hub with two tabs:
// 1. Reels — vertical video/tip feed
// 2. Community — recipe cards from the community
// Features: likes, bookmarks, external video links, tags.

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ifridge_app/core/theme/app_theme.dart';
import 'package:ifridge_app/core/services/auth_helper.dart';
import 'package:ifridge_app/features/explore/presentation/screens/creator_page.dart';
import 'package:ifridge_app/features/cook/presentation/screens/recipe_detail_screen.dart';

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

// ── Reels / Tips Feed ─────────────────────────────────────────────

class _ReelsFeed extends StatefulWidget {
  const _ReelsFeed();
  @override
  State<_ReelsFeed> createState() => _ReelsFeedState();
}

class _ReelsFeedState extends State<_ReelsFeed> {
  List<Map<String, dynamic>> _posts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    try {
      final data = await Supabase.instance.client
          .from('posts')
          .select('*, users!posts_author_id_fkey(display_name, avatar_url)')
          .inFilter('post_type', ['reel', 'tip'])
          .order('created_at', ascending: false)
          .limit(30);
      setState(() { _posts = List<Map<String, dynamic>>.from(data); _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: IFridgeTheme.primary));
    }
    if (_posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎬', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text('No reels yet',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 16)),
            const SizedBox(height: 8),
            Text('Cooking videos and tips will appear here',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 13)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      color: IFridgeTheme.primary,
      onRefresh: _loadPosts,
      child: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: _posts.length,
        itemBuilder: (ctx, i) => _ReelCard(post: _posts[i]),
      ),
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
                // Recipe link
                if (recipeId != null)
                  _VerticalAction(
                    icon: Icons.restaurant_menu,
                    color: Colors.orange,
                    label: 'Recipe',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => RecipeDetailScreen(
                          recipeId: recipeId,
                          title: caption.length > 30 ? '${caption.substring(0, 30)}...' : caption,
                          tierColor: IFridgeTheme.primary,
                          ownedIngredientIds: const {},
                        )));
                    }),
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
      final data = await Supabase.instance.client
          .from('posts')
          .select('*, users!posts_author_id_fkey(display_name, avatar_url)')
          .eq('post_type', 'recipe')
          .order('created_at', ascending: false)
          .limit(30);
      setState(() { _posts = List<Map<String, dynamic>>.from(data); _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: IFridgeTheme.primary));
    }
    if (_posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🍽️', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text('No community recipes yet',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 16)),
            const SizedBox(height: 8),
            Text('Share your recipes and discover new ones!',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 13)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      color: IFridgeTheme.primary,
      onRefresh: _loadPosts,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _posts.length,
        itemBuilder: (ctx, i) => _CommunityRecipeCard(post: _posts[i]),
      ),
    );
  }
}

class _CommunityRecipeCard extends StatelessWidget {
  final Map<String, dynamic> post;
  const _CommunityRecipeCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final caption = post['caption'] ?? '';
    final tags = List<String>.from(post['tags'] ?? []);
    final author = post['users'] as Map<String, dynamic>?;
    final authorName = author?['display_name'] ?? 'Chef';
    final likes = post['like_count'] ?? 0;
    final views = post['view_count'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author row
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: IFridgeTheme.primary.withValues(alpha: 0.2),
                child: Text(authorName[0].toUpperCase(),
                  style: const TextStyle(color: IFridgeTheme.primary, fontWeight: FontWeight.w700, fontSize: 13)),
              ),
              const SizedBox(width: 8),
              Text(authorName,
                style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
              const Spacer(),
              Icon(Icons.favorite, size: 14, color: Colors.red.withValues(alpha: 0.6)),
              const SizedBox(width: 4),
              Text('$likes',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          Text(caption,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, height: 1.4)),
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: tags.map((t) => Text('#$t',
                style: TextStyle(color: IFridgeTheme.primary.withValues(alpha: 0.7), fontSize: 12))).toList(),
            ),
          ],
        ],
      ),
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
