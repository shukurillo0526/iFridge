// I-Fridge — Creator Page
// ========================
// Profile page for a recipe/reel creator.
// Shows bio, follower count, posts grid, and follow/unfollow.

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ifridge_app/core/services/auth_helper.dart';

class CreatorPage extends StatefulWidget {
  final String creatorId;
  final String creatorName;
  const CreatorPage({super.key, required this.creatorId, required this.creatorName});
  @override
  State<CreatorPage> createState() => _CreatorPageState();
}

class _CreatorPageState extends State<CreatorPage> {
  Map<String, dynamic>? _profile;
  List<Map<String, dynamic>> _posts = [];
  bool _loading = true;
  bool _isFollowing = false;
  int _followerCount = 0;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      // Load creator profile
      final profile = await Supabase.instance.client
          .from('users').select().eq('id', widget.creatorId).single();

      // Load creator's posts
      final posts = await Supabase.instance.client
          .from('posts').select()
          .eq('author_id', widget.creatorId)
          .order('created_at', ascending: false);

      // Check if current user follows this creator
      final uid = currentUserId();
      final followCheck = await Supabase.instance.client
          .from('follows').select()
          .eq('follower_id', uid).eq('following_id', widget.creatorId);

      // Count followers
      final followers = await Supabase.instance.client
          .from('follows').select()
          .eq('following_id', widget.creatorId);

      setState(() {
        _profile = profile;
        _posts = List<Map<String, dynamic>>.from(posts);
        _isFollowing = (followCheck as List).isNotEmpty;
        _followerCount = (followers as List).length;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _toggleFollow() async {
    final uid = currentUserId();
    setState(() { _isFollowing = !_isFollowing; _followerCount += _isFollowing ? 1 : -1; });
    try {
      if (_isFollowing) {
        await Supabase.instance.client.from('follows')
            .insert({'follower_id': uid, 'following_id': widget.creatorId});
      } else {
        await Supabase.instance.client.from('follows')
            .delete().eq('follower_id', uid).eq('following_id', widget.creatorId);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.creatorName, style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
          : ListView(
              padding: EdgeInsets.all(20),
              children: [
                // Profile header
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                        backgroundImage: _profile?['avatar_url'] != null
                            ? NetworkImage(_profile!['avatar_url']) : null,
                        child: _profile?['avatar_url'] == null
                            ? Text(widget.creatorName[0].toUpperCase(),
                                style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 32, fontWeight: FontWeight.w700))
                            : null,
                      ),
                      SizedBox(height: 12),
                      Text(_profile?['display_name'] ?? widget.creatorName,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 22, fontWeight: FontWeight.w800)),
                      if (_profile?['bio'] != null) ...[
                        SizedBox(height: 6),
                        Text(_profile!['bio'],
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 14)),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // Stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatCol(value: '${_posts.length}', label: 'Posts'),
                    _StatCol(value: '$_followerCount', label: 'Followers'),
                    _StatCol(
                      value: '${_posts.fold<int>(0, (sum, p) => sum + ((p['like_count'] ?? 0) as int))}',
                      label: 'Likes',
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Follow button
                if (widget.creatorId != currentUserId())
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: _isFollowing
                        ? OutlinedButton(
                            onPressed: _toggleFollow,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Theme.of(context).colorScheme.primary),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                            child: Text('Following', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700)),
                          )
                        : FilledButton(
                            onPressed: _toggleFollow,
                            style: FilledButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                            child: Text('Follow', style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                  ),
                SizedBox(height: 24),

                // Posts grid
                Text('Posts', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.w700)),
                SizedBox(height: 12),
                if (_posts.isEmpty)
                  Center(child: Text('No posts yet',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4))))
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.75),
                    itemCount: _posts.length,
                    itemBuilder: (ctx, i) {
                      final post = _posts[i];
                      final type = post['post_type'] ?? 'tip';
                      final caption = post['caption'] ?? '';
                      final isReel = type == 'reel';
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft, end: Alignment.bottomRight,
                            colors: [
                              isReel ? Colors.deepPurple.withValues(alpha: 0.15) : Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                              Theme.of(context).colorScheme.surface,
                            ]),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06))),
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(isReel ? Icons.play_circle_fill : Icons.lightbulb,
                                    color: isReel ? Colors.red : Theme.of(context).colorScheme.primary, size: 18),
                                  SizedBox(width: 6),
                                  Text(isReel ? 'Reel' : type == 'recipe' ? 'Recipe' : 'Tip',
                                    style: TextStyle(
                                      color: isReel ? Colors.red : Theme.of(context).colorScheme.primary,
                                      fontSize: 11, fontWeight: FontWeight.w700)),
                                ],
                              ),
                              Spacer(),
                              Text(caption, maxLines: 3, overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 13, fontWeight: FontWeight.w600)),
                              Spacer(),
                              Row(
                                children: [
                                  Icon(Icons.favorite, size: 14, color: Colors.red.withValues(alpha: 0.6)),
                                  SizedBox(width: 4),
                                  Text('${post['like_count'] ?? 0}',
                                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 11)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
    );
  }
}

class _StatCol extends StatelessWidget {
  final String value, label;
  const _StatCol({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.w800)),
        Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 12)),
      ],
    );
  }
}
