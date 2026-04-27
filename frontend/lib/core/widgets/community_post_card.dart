// I-Fridge — Community Post Card (Instagram-style)
// ===================================================
// Rich post card with:
// - Author header with avatar, name, timestamp
// - Photo carousel (swipeable)
// - Like, Comment, Share, Bookmark action bar
// - Caption with hashtags
// - Location tag for restaurant visits
// - Comment preview

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ifridge_app/core/theme/app_theme.dart';
import 'package:ifridge_app/core/services/social_service.dart';
import 'package:ifridge_app/core/services/auth_helper.dart';
import 'package:ifridge_app/core/widgets/comment_sheet.dart';
import 'package:ifridge_app/features/explore/presentation/screens/creator_page.dart';

class CommunityPostCard extends StatefulWidget {
  final Map<String, dynamic> post;

  const CommunityPostCard({super.key, required this.post});

  @override
  State<CommunityPostCard> createState() => _CommunityPostCardState();
}

class _CommunityPostCardState extends State<CommunityPostCard> {
  bool _liked = false;
  bool _bookmarked = false;
  int _likeCount = 0;
  int _commentCount = 0;
  int _currentImage = 0;

  @override
  void initState() {
    super.initState();
    _likeCount = (widget.post['like_count'] as int?) ?? 0;
    _commentCount = (widget.post['comment_count'] as int?) ?? 0;
    _checkInteractions();
  }

  void _checkInteractions() async {
    final postId = widget.post['id'] as String?;
    if (postId == null) return;
    final liked = await SocialService.hasLiked(postId);
    final bookmarked = await SocialService.isBookmarked(postId);
    if (mounted) setState(() { _liked = liked; _bookmarked = bookmarked; });
  }

  void _toggleLike() async {
    final postId = widget.post['id'] as String?;
    if (postId == null) return;

    setState(() {
      _liked = !_liked;
      _likeCount += _liked ? 1 : -1;
    });

    if (_liked) {
      await SocialService.likePost(postId);
    } else {
      await SocialService.unlikePost(postId);
    }
  }

  void _toggleBookmark() async {
    final postId = widget.post['id'] as String?;
    if (postId == null) return;

    setState(() => _bookmarked = !_bookmarked);

    if (_bookmarked) {
      await SocialService.bookmarkPost(postId);
    } else {
      await SocialService.unbookmarkPost(postId);
    }
  }

  void _openComments() {
    final postId = widget.post['id'] as String?;
    if (postId == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentSheet(
        postId: postId,
        initialCount: _commentCount,
        onCountChanged: (count) {
          if (mounted) setState(() => _commentCount = count);
        },
      ),
    );
  }

  void _sharePost() {
    final caption = widget.post['caption'] ?? '';
    SharePlus.instance.share(
      ShareParams(text: '🍽️ Check this out on iFridge!\n\n$caption'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final author = widget.post['users'] as Map<String, dynamic>?;
    final authorName = author?['display_name'] ?? 'Chef';
    final authorId = widget.post['author_id'] as String?;
    final caption = widget.post['caption'] ?? '';
    final tags = List<String>.from(widget.post['tags'] ?? []);
    final mediaUrls = List<String>.from(widget.post['media_urls'] ?? []);
    final locationName = widget.post['location_name'] as String?;
    final postType = widget.post['post_type'] ?? 'photo';
    final createdAt = widget.post['created_at'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ═══════════════════════════════════════════
          //  HEADER: Avatar, Name, Time, Menu
          // ═══════════════════════════════════════════
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (authorId != null) {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => CreatorPage(creatorId: authorId, creatorName: authorName),
                      ));
                    }
                  },
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: IFridgeTheme.primary.withValues(alpha: 0.2),
                    child: Text(
                      authorName.isNotEmpty ? authorName[0].toUpperCase() : '?',
                      style: const TextStyle(color: IFridgeTheme.primary, fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (authorId != null) {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (_) => CreatorPage(creatorId: authorId, creatorName: authorName),
                            ));
                          }
                        },
                        child: Text(authorName,
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                      ),
                      if (locationName != null) ...[
                        const SizedBox(height: 1),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 11, color: Colors.white.withValues(alpha: 0.4)),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(locationName,
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11),
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Text(_timeAgo(createdAt),
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 11)),
                const SizedBox(width: 4),
                _postTypeBadge(postType),
              ],
            ),
          ),

          // ═══════════════════════════════════════════
          //  MEDIA CAROUSEL
          // ═══════════════════════════════════════════
          if (mediaUrls.isNotEmpty) ...[
            GestureDetector(
              onDoubleTap: () {
                if (!_liked) _toggleLike();
              },
              child: AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  children: [
                    PageView.builder(
                      itemCount: mediaUrls.length,
                      onPageChanged: (i) => setState(() => _currentImage = i),
                      itemBuilder: (_, i) => CachedNetworkImage(
                        imageUrl: mediaUrls[i],
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: IFridgeTheme.bgElevated,
                          child: const Center(
                            child: CircularProgressIndicator(color: IFridgeTheme.primary, strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: IFridgeTheme.bgElevated,
                          child: const Center(
                            child: Icon(Icons.broken_image, color: Colors.white24, size: 40),
                          ),
                        ),
                      ),
                    ),
                    // Carousel dots
                    if (mediaUrls.length > 1)
                      Positioned(
                        bottom: 10,
                        left: 0, right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(mediaUrls.length, (i) => Container(
                            width: _currentImage == i ? 8 : 5,
                            height: _currentImage == i ? 8 : 5,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentImage == i
                                  ? IFridgeTheme.primary
                                  : Colors.white.withValues(alpha: 0.4),
                            ),
                          )),
                        ),
                      ),
                    // Image counter
                    if (mediaUrls.length > 1)
                      Positioned(
                        top: 10, right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('${_currentImage + 1}/${mediaUrls.length}',
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],

          // ═══════════════════════════════════════════
          //  ACTION BAR: Like, Comment, Share, Bookmark
          // ═══════════════════════════════════════════
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 2),
            child: Row(
              children: [
                // Like
                GestureDetector(
                  onTap: _toggleLike,
                  child: AnimatedScale(
                    scale: _liked ? 1.15 : 1.0,
                    duration: const Duration(milliseconds: 150),
                    child: Icon(
                      _liked ? Icons.favorite : Icons.favorite_border,
                      color: _liked ? Colors.red : Colors.white70,
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Comment
                GestureDetector(
                  onTap: _openComments,
                  child: const Icon(Icons.chat_bubble_outline, color: Colors.white70, size: 23),
                ),
                const SizedBox(width: 14),
                // Share
                GestureDetector(
                  onTap: _sharePost,
                  child: const Icon(Icons.send_outlined, color: Colors.white70, size: 22),
                ),
                const Spacer(),
                // Bookmark
                GestureDetector(
                  onTap: _toggleBookmark,
                  child: Icon(
                    _bookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: _bookmarked ? IFridgeTheme.primary : Colors.white70,
                    size: 25,
                  ),
                ),
              ],
            ),
          ),

          // ═══════════════════════════════════════════
          //  LIKE COUNT
          // ═══════════════════════════════════════════
          if (_likeCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                '$_likeCount ${_likeCount == 1 ? 'like' : 'likes'}',
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),

          // ═══════════════════════════════════════════
          //  CAPTION + TAGS
          // ═══════════════════════════════════════════
          if (caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 0),
              child: RichText(
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$authorName  ',
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    TextSpan(
                      text: caption,
                      style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),

          // Tags
          if (tags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 0),
              child: Wrap(
                spacing: 6,
                children: tags.take(5).map((t) => Text(
                  '#$t',
                  style: TextStyle(color: IFridgeTheme.primary.withValues(alpha: 0.8), fontSize: 12, fontWeight: FontWeight.w600),
                )).toList(),
              ),
            ),

          // ═══════════════════════════════════════════
          //  RESTAURANT VISIT CARD (if applicable)
          // ═══════════════════════════════════════════
          if (postType == 'restaurant_visit' && locationName != null)
            Container(
              margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6D00).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.restaurant, color: Color(0xFFFF6D00), size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(locationName,
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text('Tap to view on map',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 11)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.3), size: 18),
                ],
              ),
            ),

          // ═══════════════════════════════════════════
          //  COMMENT PREVIEW
          // ═══════════════════════════════════════════
          if (_commentCount > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
              child: GestureDetector(
                onTap: _openComments,
                child: Text(
                  'View ${_commentCount == 1 ? '1 comment' : 'all $_commentCount comments'}',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12),
                ),
              ),
            ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _postTypeBadge(String type) {
    final config = switch (type) {
      'restaurant_visit' => (Icons.restaurant, '🍽️', const Color(0xFFFF6D00)),
      'food_tip' => (Icons.lightbulb_outline, '💡', Colors.amber),
      'recipe' => (Icons.menu_book, '📖', IFridgeTheme.primary),
      _ => (Icons.camera_alt, '📸', IFridgeTheme.secondary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: config.$3.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(config.$2,
        style: const TextStyle(fontSize: 12)),
    );
  }

  String _timeAgo(String? iso) {
    if (iso == null) return '';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${diff.inDays ~/ 7}w';
  }
}
