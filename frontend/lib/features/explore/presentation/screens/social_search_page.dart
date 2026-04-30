// I-Fridge — Social Search Page
// ===============================
// Search users, hashtags, and posts.
// Shown when tapping search icon in Explore header.

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ifridge_app/core/services/auth_helper.dart';
import 'package:ifridge_app/features/explore/presentation/screens/creator_page.dart';

class SocialSearchPage extends StatefulWidget {
  const SocialSearchPage({super.key});

  @override
  State<SocialSearchPage> createState() => _SocialSearchPageState();
}

class _SocialSearchPageState extends State<SocialSearchPage> with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  late TabController _tabController;

  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _posts = [];
  List<_TagResult> _tags = [];
  bool _searching = false;
  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTrending();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTrending() async {
    // Load trending hashtags from recent posts
    try {
      final data = await Supabase.instance.client
          .from('posts')
          .select('tags')
          .order('created_at', ascending: false)
          .limit(100);

      final tagCounts = <String, int>{};
      for (final post in (data as List)) {
        final tags = List<String>.from(post['tags'] ?? []);
        for (final t in tags) {
          tagCounts[t] = (tagCounts[t] ?? 0) + 1;
        }
      }

      final sorted = tagCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      if (mounted) {
        setState(() {
          _tags = sorted.take(20).map((e) => _TagResult(tag: e.key, count: e.value)).toList();
        });
      }
    } catch (e) {
      debugPrint('[Search] loadTrending error: $e');
    }
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() { _users = []; _posts = []; _lastQuery = ''; });
      return;
    }

    setState(() { _searching = true; _lastQuery = query; });

    try {
      // Search users and posts in parallel
      final usersFuture = Supabase.instance.client
          .from('users')
          .select('id, display_name, avatar_url, email')
          .ilike('display_name', '%${query.trim()}%')
          .limit(20);

      final postsFuture = Supabase.instance.client
          .from('posts')
          .select('*, users!posts_author_id_fkey(display_name, avatar_url)')
          .ilike('caption', '%${query.trim()}%')
          .order('created_at', ascending: false)
          .limit(20);

      // Also search tags
      final tagPostsFuture = Supabase.instance.client
          .from('posts')
          .select('tags')
          .order('created_at', ascending: false)
          .limit(200);

      final results = await Future.wait([usersFuture, postsFuture, tagPostsFuture]);

      final users = List<Map<String, dynamic>>.from(results[0] as List);
      final posts = List<Map<String, dynamic>>.from(results[1] as List);

      // Count matching tags
      final tagCounts = <String, int>{};
      for (final post in (results[2] as List)) {
        final tags = List<String>.from(post['tags'] ?? []);
        for (final t in tags) {
          if (t.toLowerCase().contains(query.toLowerCase())) {
            tagCounts[t] = (tagCounts[t] ?? 0) + 1;
          }
        }
      }
      final matchedTags = tagCounts.entries
          .map((e) => _TagResult(tag: e.key, count: e.value))
          .toList()
        ..sort((a, b) => b.count.compareTo(a.count));

      if (mounted) {
        setState(() {
          _users = users;
          _posts = posts;
          _tags = matchedTags;
          _searching = false;
        });
      }
    } catch (e) {
      debugPrint('[Search] error: $e');
      if (mounted) setState(() => _searching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        title: Container(
          margin: EdgeInsets.only(right: 16),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 15),
            onChanged: (v) => _search(v),
            decoration: InputDecoration(
              hintText: 'Search users, posts, #hashtags...',
              hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.primary, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38), size: 18),
                      onPressed: () {
                        _searchController.clear();
                        _search('');
                        _loadTrending();
                      },
                    )
                  : null,
              isDense: true,
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.primary,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54),
          labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: [
            Tab(text: 'Users${_users.isNotEmpty ? ' (${_users.length})' : ''}'),
            Tab(text: 'Posts${_posts.isNotEmpty ? ' (${_posts.length})' : ''}'),
            Tab(text: 'Tags${_tags.isNotEmpty ? ' (${_tags.length})' : ''}'),
          ],
        ),
      ),
      body: _searching
          ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildUsersTab(),
                _buildPostsTab(),
                _buildTagsTab(),
              ],
            ),
    );
  }

  // ── Users Tab ──
  Widget _buildUsersTab() {
    if (_lastQuery.isEmpty) {
      return _emptyHint('Search for people', Icons.person_search);
    }
    if (_users.isEmpty) {
      return _emptyHint('No users found', Icons.person_off);
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 8),
      itemCount: _users.length,
      itemBuilder: (_, i) {
        final user = _users[i];
        final name = user['display_name'] ?? 'User';
        final email = user['email'] as String?;
        final userId = user['id'] as String;
        final isMe = userId == currentUserId();

        return ListTile(
          leading: CircleAvatar(
            radius: 22,
            backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w800)),
          ),
          title: Text(name, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600)),
          subtitle: email != null
              ? Text(email, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3), fontSize: 12))
              : null,
          trailing: isMe
              ? Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('You', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 11, fontWeight: FontWeight.w600)),
                )
              : null,
          onTap: () {
            Navigator.push(context, MaterialPageRoute(
              builder: (_) => CreatorPage(creatorId: userId, creatorName: name),
            ));
          },
        );
      },
    );
  }

  // ── Posts Tab ──
  Widget _buildPostsTab() {
    if (_lastQuery.isEmpty) {
      return _emptyHint('Search for posts', Icons.article_outlined);
    }
    if (_posts.isEmpty) {
      return _emptyHint('No posts found', Icons.search_off);
    }

    return ListView.builder(
      padding: EdgeInsets.all(12),
      itemCount: _posts.length,
      itemBuilder: (_, i) {
        final post = _posts[i];
        final author = post['users'] as Map<String, dynamic>?;
        final authorName = author?['display_name'] ?? 'User';
        final caption = post['caption'] ?? '';
        final postType = post['post_type'] ?? 'photo';
        final likes = post['like_count'] ?? 0;
        final mediaUrls = List<String>.from(post['media_urls'] ?? []);

        return Container(
          margin: EdgeInsets.only(bottom: 10),
          padding: EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              if (mediaUrls.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(mediaUrls.first, width: 56, height: 56, fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(width: 56, height: 56, color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          child: Icon(Icons.image, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24)))),
                )
              else
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    postType == 'restaurant_visit' ? Icons.restaurant : Icons.article,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24),
                  ),
                ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(authorName, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 12, fontWeight: FontWeight.w600)),
                    SizedBox(height: 3),
                    Text(caption, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 13, height: 1.3),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.favorite, size: 12, color: Colors.red.withValues(alpha: 0.5)),
                        SizedBox(width: 3),
                        Text('$likes', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 11)),
                        SizedBox(width: 10),
                        _typeBadge(postType),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Tags Tab ──
  Widget _buildTagsTab() {
    if (_tags.isEmpty && _lastQuery.isNotEmpty) {
      return _emptyHint('No matching tags', Icons.tag);
    }

    final title = _lastQuery.isEmpty ? 'Trending Tags' : 'Matching Tags';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text('🔥 $title',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w700)),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: _tags.length,
            itemBuilder: (_, i) {
              final tag = _tags[i];
              return Container(
                margin: EdgeInsets.only(bottom: 6),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  tileColor: Theme.of(context).colorScheme.surface,
                  leading: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.tag, color: Theme.of(context).colorScheme.primary, size: 20),
                  ),
                  title: Text('#${tag.tag}',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600)),
                  trailing: Text('${tag.count} posts',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 12)),
                  onTap: () {
                    _searchController.text = tag.tag;
                    _search(tag.tag);
                    _tabController.animateTo(1); // Switch to Posts tab
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _emptyHint(String text, IconData icon) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
          SizedBox(height: 12),
          Text(text, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3), fontSize: 14)),
        ],
      ),
    );
  }

  Widget _typeBadge(String type) {
    final config = switch (type) {
      'restaurant_visit' => ('🍽️', Theme.of(context).colorScheme.primary),
      'food_tip' => ('💡', Colors.amber),
      'recipe' => ('📖', Theme.of(context).colorScheme.primary),
      _ => ('📸', Theme.of(context).colorScheme.secondary),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: config.$2.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(config.$1, style: TextStyle(fontSize: 10)),
    );
  }
}

class _TagResult {
  final String tag;
  final int count;
  _TagResult({required this.tag, required this.count});
}
