// I-Fridge — Cook Feeds Screen (YouTube-backed)
// =================================================
// TikTok-style vertical cooking video feed backed by real YouTube videos.
// Each video has AI-extracted recipe data.
// Tap video → opens YouTube. "Cook" button → recipe overlay with "Cook This" action.

import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:ifridge_app/core/services/video_feed_service.dart';

class CookFeedsScreen extends StatefulWidget {
  const CookFeedsScreen({super.key});

  @override
  State<CookFeedsScreen> createState() => _CookFeedsScreenState();
}

class _CookFeedsScreenState extends State<CookFeedsScreen> {
  final PageController _pageController = PageController();
  List<VideoFeed> _videos = [];
  int _currentPage = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadFeed() async {
    setState(() => _loading = true);
    final videos = await VideoFeedService.getCookFeeds();
    if (mounted) {
      setState(() {
        _videos = videos;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: const BackButton(color: Colors.white),
        ),
        body: const Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50))),
      );
    }

    if (_videos.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: const BackButton(color: Colors.white),
          title: const Text('Cook Feed', style: TextStyle(color: Colors.white)),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.play_circle_outline, size: 56, color: Colors.white.withValues(alpha: 0.15)),
              const SizedBox(height: 16),
              Text('No cooking videos yet', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 16)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: _videos.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (ctx, i) => _CookVideoCard(video: _videos[i]),
          ),

          // ── Top bar with back button ───────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(8, MediaQuery.of(context).padding.top + 4, 20, 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
                ),
              ),
              child: Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('👨‍🍳', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Cook Feed', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                      Text('${_videos.length} recipes', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11)),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('${_currentPage + 1} / ${_videos.length}',
                      style: const TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  COOK VIDEO CARD
// ═══════════════════════════════════════════════════════════════════

class _CookVideoCard extends StatefulWidget {
  final VideoFeed video;
  const _CookVideoCard({required this.video});

  @override
  State<_CookVideoCard> createState() => _CookVideoCardState();
}

class _CookVideoCardState extends State<_CookVideoCard> {
  bool _liked = false;
  bool _saved = false;
  bool _showRecipe = false;

  @override
  Widget build(BuildContext context) {
    final v = widget.video;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final likes = v.likes + (_liked ? 1 : 0);
    const green = Color(0xFF4CAF50);

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background: Thumbnail with play overlay ──
          GestureDetector(
            onTap: () => html.window.open(v.watchUrl, '_blank'),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(v.thumbnailUrl, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade900,
                    child: const Center(child: Icon(Icons.broken_image, color: Colors.white24, size: 48)))),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black.withValues(alpha: 0.1), Colors.black.withValues(alpha: 0.75)],
                    ),
                  ),
                ),
                // Play button
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(color: green.withValues(alpha: 0.25), shape: BoxShape.circle),
                    child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 44),
                  ),
                ),
                // "Tap to watch" hint
                Positioned(
                  bottom: 200 + bottomPad,
                  left: 0, right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.open_in_new, size: 12, color: Colors.white.withValues(alpha: 0.6)),
                          const SizedBox(width: 4),
                          Text('Tap to watch on YouTube', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Recipe overlay ──────────────────────────
          if (_showRecipe && v.hasRecipe)
            _RecipeOverlay(video: v, onClose: () => setState(() => _showRecipe = false)),

          // ── Right sidebar ──────────────────────────
          if (!_showRecipe)
            Positioned(
              right: 12,
              bottom: 100 + bottomPad,
              child: Column(
                children: [
                  _SideBtn(icon: _liked ? Icons.favorite : Icons.favorite_border,
                    label: _fmt(likes), color: _liked ? Colors.red : Colors.white,
                    onTap: () => setState(() => _liked = !_liked)),
                  const SizedBox(height: 18),
                  _SideBtn(icon: Icons.restaurant_menu, label: 'Cook', color: green,
                    highlighted: true, onTap: () => setState(() => _showRecipe = true)),
                  const SizedBox(height: 18),
                  _SideBtn(icon: Icons.reply_outlined, label: 'Share', color: Colors.white, onTap: () {}),
                  const SizedBox(height: 18),
                  _SideBtn(icon: _saved ? Icons.bookmark : Icons.bookmark_border,
                    label: _saved ? 'Saved' : 'Save', color: _saved ? green : Colors.white,
                    onTap: () => setState(() => _saved = !_saved)),
                  const SizedBox(height: 18),
                  _ChannelAvatar(name: v.authorName, color: green),
                ],
              ),
            ),

          // ── Bottom info ────────────────────────────
          if (!_showRecipe)
            Positioned(
              left: 16, right: 70, bottom: 16 + bottomPad,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('@${v.authorName.replaceAll(' ', '_').toLowerCase()}',
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(v.title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700, height: 1.2),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  if (v.hasRecipe)
                    Row(children: [
                      if (v.recipePrepTime.isNotEmpty) _pill('⏱ ${v.recipePrepTime}', green),
                      if (v.recipeCookTime.isNotEmpty) ...[const SizedBox(width: 6), _pill('🔥 ${v.recipeCookTime}', Colors.orange)],
                      if (v.recipeDifficulty.isNotEmpty) ...[const SizedBox(width: 6), _pill('📊 ${v.recipeDifficulty}', Colors.blue)],
                    ]),
                  const SizedBox(height: 6),
                  if (v.hasRecipe && v.recipeIngredients.isNotEmpty)
                    Text('🥘 ${v.recipeIngredients.take(3).join(', ')}...',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Wrap(spacing: 6, runSpacing: 4, children: v.tags.take(4).map((t) =>
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text('#$t', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 10, fontWeight: FontWeight.w600)))).toList()),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _pill(String text, Color c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: c.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
    child: Text(text, style: TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.w700)));

  String _fmt(int n) => n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';
}

// ── Recipe Overlay with "Cook This" action ──────────────────────

class _RecipeOverlay extends StatelessWidget {
  final VideoFeed video;
  final VoidCallback onClose;
  const _RecipeOverlay({required this.video, required this.onClose});

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF4CAF50);

    return Container(
      color: Colors.black.withValues(alpha: 0.92),
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 50, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: Text(video.recipeTitle,
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800))),
            GestureDetector(onTap: onClose,
              child: Container(padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.close, color: Colors.white, size: 18))),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            if (video.recipePrepTime.isNotEmpty) _stat('Prep', video.recipePrepTime, Icons.schedule),
            if (video.recipeCookTime.isNotEmpty) _stat('Cook', video.recipeCookTime, Icons.local_fire_department),
            _stat('Serves', '${video.recipeServings}', Icons.people),
            if (video.recipeDifficulty.isNotEmpty) _stat('Level', video.recipeDifficulty, Icons.signal_cellular_alt),
          ]),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(children: [
              const Text('Ingredients', style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              ...video.recipeIngredients.map((ing) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(children: [
                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: green, shape: BoxShape.circle)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(ing, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14))),
                ]))),
              const SizedBox(height: 20),
              const Text('Steps', style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              ...video.recipeSteps.asMap().entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(width: 24, height: 24,
                    decoration: BoxDecoration(color: green.withValues(alpha: 0.2), shape: BoxShape.circle),
                    child: Center(child: Text('${entry.key + 1}', style: TextStyle(color: green, fontSize: 12, fontWeight: FontWeight.w700)))),
                  const SizedBox(width: 10),
                  Expanded(child: Text(entry.value, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14, height: 1.4))),
                ]))),
              const SizedBox(height: 24),
            ]),
          ),

          // ── "Cook This Recipe" action button ───────
          GestureDetector(
            onTap: () {
              // Copy recipe to clipboard-style snackbar confirmation
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('✅ "${video.recipeTitle}" saved to your recipes!'),
                backgroundColor: green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                duration: const Duration(seconds: 2),
              ));
              onClose();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF81C784)]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: green.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.restaurant_menu, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Cook This Recipe', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
              ]),
            ),
          ),
          const SizedBox(height: 8),

          // ── Watch the video button ─────────────────
          GestureDetector(
            onTap: () => html.window.open(video.watchUrl, '_blank'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.play_circle_outline, color: Colors.white70, size: 18),
                SizedBox(width: 8),
                Text('Watch Video on YouTube', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, IconData icon) => Expanded(
    child: Column(children: [
      Icon(icon, size: 16, color: Colors.white38),
      const SizedBox(height: 2),
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
      Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 10)),
    ]));
}

// ── Shared Widgets ──────────────────────────────────────────────

class _SideBtn extends StatelessWidget {
  final IconData icon; final String label; final Color color;
  final bool highlighted; final VoidCallback onTap;
  const _SideBtn({required this.icon, required this.label, required this.color, this.highlighted = false, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap, behavior: HitTestBehavior.opaque,
    child: Column(children: [
      Container(width: 44, height: 44,
        decoration: BoxDecoration(shape: BoxShape.circle,
          color: highlighted ? color.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.08),
          border: highlighted ? Border.all(color: color.withValues(alpha: 0.5), width: 1.5) : null),
        child: Icon(icon, size: 22, color: color)),
      const SizedBox(height: 3),
      Text(label, style: TextStyle(color: color.withValues(alpha: 0.9), fontSize: 10, fontWeight: FontWeight.w600)),
    ]));
}

class _ChannelAvatar extends StatelessWidget {
  final String name; final Color color;
  const _ChannelAvatar({required this.name, required this.color});
  @override
  Widget build(BuildContext context) => Column(children: [
    Container(width: 44, height: 44,
      decoration: BoxDecoration(shape: BoxShape.circle,
        gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.6)]),
        border: Border.all(color: Colors.white, width: 2)),
      child: Center(child: Text(name.isNotEmpty ? name[0] : '?',
        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)))),
    const SizedBox(height: 3),
    SizedBox(width: 50, child: Text(name,
      style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 9, fontWeight: FontWeight.w600),
      textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis)),
  ]);
}
