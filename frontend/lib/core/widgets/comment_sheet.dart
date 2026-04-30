// I-Fridge — Comment Bottom Sheet
// ==================================
// Slides up from bottom when tapping 💬 on a post.
// Shows threaded comments with real-time feel.

import 'package:flutter/material.dart';
import 'package:ifridge_app/core/services/social_service.dart';
import 'package:ifridge_app/core/services/auth_helper.dart';

class CommentSheet extends StatefulWidget {
  final String postId;
  final int initialCount;
  final ValueChanged<int>? onCountChanged;

  const CommentSheet({
    super.key,
    required this.postId,
    this.initialCount = 0,
    this.onCountChanged,
  });

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  List<Map<String, dynamic>> _comments = [];
  bool _loading = true;
  bool _sending = false;
  String? _replyTo; // comment ID being replied to
  String? _replyToName;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    final data = await SocialService.getComments(widget.postId);
    if (mounted) setState(() { _comments = data; _loading = false; });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);
    final result = await SocialService.addComment(
      widget.postId, text,
      parentCommentId: _replyTo,
    );
    _controller.clear();
    setState(() {
      _sending = false;
      _replyTo = null;
      _replyToName = null;
      if (result != null) {
        _comments.add(result);
        widget.onCountChanged?.call(_comments.length);
      }
    });

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _startReply(String commentId, String authorName) {
    setState(() {
      _replyTo = commentId;
      _replyToName = authorName;
    });
    _controller.clear();
    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // ── Handle bar ──
          Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // ── Header ──
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: [
                Icon(Icons.chat_bubble_outline, color: Theme.of(context).colorScheme.primary, size: 20),
                SizedBox(width: 8),
                Text(
                  'Comments${_comments.isNotEmpty ? ' (${_comments.length})' : ''}',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w700),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54), size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12), height: 1),

          // ── Comment list ──
          Expanded(
            child: _loading
                ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
                : _comments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.chat_bubble_outline, size: 48,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15)),
                            SizedBox(height: 12),
                            Text('No comments yet',
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 14)),
                            SizedBox(height: 4),
                            Text('Be the first to comment!',
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.25), fontSize: 12)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: _comments.length,
                        itemBuilder: (ctx, i) => _CommentTile(
                          comment: _comments[i],
                          onReply: (id, name) => _startReply(id, name),
                          onDelete: (id) async {
                            await SocialService.deleteComment(id, widget.postId);
                            setState(() => _comments.removeAt(i));
                            widget.onCountChanged?.call(_comments.length);
                          },
                        ),
                      ),
          ),

          // ── Reply indicator ──
          if (_replyTo != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              child: Row(
                children: [
                  Text('Replying to @$_replyToName',
                      style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                  Spacer(),
                  GestureDetector(
                    onTap: () => setState(() { _replyTo = null; _replyToName = null; }),
                    child: Icon(Icons.close, size: 16, color: Theme.of(context).colorScheme.primary),
                  ),
                ],
              ),
            ),

          // ── Input bar ──
          Container(
            padding: EdgeInsets.fromLTRB(16, 8, 8, 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: Border(top: BorderSide(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: _replyTo != null ? 'Reply...' : 'Add a comment...',
                      hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      isDense: true,
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                  ),
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: _send,
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: _sending
                          ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12)
                          : Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: _sending
                        ? SizedBox(width: 18, height: 18,
                            child: CircularProgressIndicator(color: Theme.of(context).colorScheme.onSurface, strokeWidth: 2))
                        : Icon(Icons.send, color: Theme.of(context).colorScheme.onSurface, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Single Comment Tile ─────────────────────────────────────────

class _CommentTile extends StatelessWidget {
  final Map<String, dynamic> comment;
  final void Function(String id, String name) onReply;
  final void Function(String id) onDelete;

  const _CommentTile({
    required this.comment,
    required this.onReply,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final author = comment['users'] as Map<String, dynamic>?;
    final name = author?['display_name'] ?? 'User';
    final body = comment['body'] ?? '';
    final createdAt = comment['created_at'] as String?;
    final isReply = comment['parent_comment_id'] != null;
    final isOwn = comment['author_id'] == currentUserId();

    return Container(
      margin: EdgeInsets.only(
        bottom: 8,
        left: isReply ? 32 : 0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 14,
            backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(name,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 12, fontWeight: FontWeight.w700)),
                    SizedBox(width: 8),
                    Text(_timeAgo(createdAt),
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3), fontSize: 10)),
                  ],
                ),
                SizedBox(height: 3),
                Text(body,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 13, height: 1.4)),
                SizedBox(height: 4),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => onReply(comment['id'], name),
                      child: Text('Reply',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                    if (isOwn) ...[
                      SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => onDelete(comment['id']),
                        child: Text('Delete',
                            style: TextStyle(color: Colors.red.withValues(alpha: 0.5), fontSize: 11)),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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
