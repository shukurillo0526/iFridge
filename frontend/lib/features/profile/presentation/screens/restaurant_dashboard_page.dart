// I-Fridge — Restaurant Dashboard
// =================================
// Management dashboard for restaurant/business owners.
// Shows analytics, allows content creation, and business profile editing.
// Accessible from Manage → "Restaurant Dashboard" (only visible if business account).

import 'package:flutter/material.dart';
import 'package:ifridge_app/core/theme/app_theme.dart';
import 'package:ifridge_app/core/services/business_service.dart';
import 'package:ifridge_app/core/services/social_service.dart';
import 'package:ifridge_app/features/profile/presentation/screens/post_upload_form.dart';
import 'package:ifridge_app/features/order/presentation/screens/incoming_orders_page.dart';

class RestaurantDashboardPage extends StatefulWidget {
  const RestaurantDashboardPage({super.key});

  @override
  State<RestaurantDashboardPage> createState() => _RestaurantDashboardPageState();
}

class _RestaurantDashboardPageState extends State<RestaurantDashboardPage> {
  BusinessAccount? _account;
  Map<String, int> _stats = {};
  bool _loading = true;
  int _followers = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final account = await BusinessService.getMyBusiness();
    if (account != null) {
      final stats = await BusinessService.getBusinessStats(account.userId);
      final followers = await SocialService.getFollowerCount(account.userId);
      if (mounted) {
        setState(() {
          _account = account;
          _stats = stats;
          _followers = followers;
          _loading = false;
        });
      }
    } else {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Restaurant Dashboard', style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF6D00)))
          : _account == null
              ? _buildRegisterPrompt()
              : _buildDashboard(),
    );
  }

  Widget _buildRegisterPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6D00).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.storefront, color: Color(0xFFFF6D00), size: 48),
            ),
            const SizedBox(height: 24),
            const Text('Own a restaurant?',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('Register your business to promote your restaurant\nin the Order feed and reach local foodies.',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14, height: 1.5),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _showRegisterDialog,
              icon: const Icon(Icons.add_business, size: 20),
              label: const Text('Register Business', style: TextStyle(fontWeight: FontWeight.w700)),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFF6D00),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRegisterDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final locCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: IFridgeTheme.bgElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Register Your Restaurant',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DialogField(controller: nameCtrl, label: 'Restaurant Name', icon: Icons.storefront),
              const SizedBox(height: 12),
              _DialogField(controller: descCtrl, label: 'Description', icon: Icons.description, maxLines: 3),
              const SizedBox(height: 12),
              _DialogField(controller: locCtrl, label: 'Location', icon: Icons.location_on),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              setState(() => _loading = true);
              await BusinessService.registerBusiness(
                businessName: nameCtrl.text.trim(),
                description: descCtrl.text.trim().isNotEmpty ? descCtrl.text.trim() : null,
                locationName: locCtrl.text.trim().isNotEmpty ? locCtrl.text.trim() : null,
              );
              _load();
            },
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF6D00)),
            child: const Text('Register'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    final account = _account!;
    const accent = Color(0xFFFF6D00);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Business Header ──
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [accent.withValues(alpha: 0.2), accent.withValues(alpha: 0.05)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accent.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFFF6D00), Color(0xFFFF9100)]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(account.businessName[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(account.businessName,
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                          if (account.isVerified) ...[
                            const SizedBox(width: 6),
                            Icon(Icons.verified, color: Colors.blue.shade300, size: 18),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        account.isVerified ? 'Verified Restaurant' : 'Pending Verification',
                        style: TextStyle(
                          color: account.isVerified ? accent : Colors.amber,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (account.locationName != null) ...[
                        const SizedBox(height: 2),
                        Text('📍 ${account.locationName}',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Stats Grid ──
          Row(
            children: [
              Expanded(child: _StatTile(icon: Icons.article, label: 'Posts', value: '${_stats['posts'] ?? 0}', color: accent)),
              const SizedBox(width: 10),
              Expanded(child: _StatTile(icon: Icons.visibility, label: 'Views', value: '${_stats['views'] ?? 0}', color: Colors.blueAccent)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _StatTile(icon: Icons.favorite, label: 'Likes', value: '${_stats['likes'] ?? 0}', color: Colors.redAccent)),
              const SizedBox(width: 10),
              Expanded(child: _StatTile(icon: Icons.people, label: 'Followers', value: '$_followers', color: IFridgeTheme.primary)),
            ],
          ),

          const SizedBox(height: 24),

          // ── Verification Status ──
          if (!account.isVerified)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.hourglass_top, color: Colors.amber, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Verification Pending',
                            style: TextStyle(color: Colors.amber, fontSize: 14, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text('Your content will appear in Order feeds once verified.',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 20),

          // ── Incoming Orders ──
          const Text('Incoming Orders',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),

          _ActionCard(
            icon: Icons.receipt_long,
            title: 'Manage Orders',
            subtitle: 'View and update incoming customer orders',
            color: Colors.green,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => IncomingOrdersPage(restaurantId: account.userId),
              ));
            },
          ),

          const SizedBox(height: 20),

          // ── Quick Actions ──
          const Text('Quick Actions',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),

          _ActionCard(
            icon: Icons.video_call,
            title: 'Create Promo Video',
            subtitle: 'Upload a short video to promote your dishes',
            color: accent,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => const EnhancedPostUploadForm(),
              ));
            },
          ),
          const SizedBox(height: 10),
          _ActionCard(
            icon: Icons.restaurant_menu,
            title: 'Update Menu',
            subtitle: 'Add or edit menu items for your restaurant',
            color: IFridgeTheme.primary,
            onTap: () => _showMenuEditor(),
          ),
          const SizedBox(height: 10),
          _ActionCard(
            icon: Icons.analytics,
            title: 'View Analytics',
            subtitle: 'Track engagement and reach insights',
            color: Colors.blueAccent,
            onTap: () => _showAnalytics(),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  void _showMenuEditor() {
    showModalBottomSheet(
      context: context,
      backgroundColor: IFridgeTheme.bgElevated,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Text('Menu Editor', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Add items your customers can browse. Menu items will appear on your restaurant page.',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: Column(
                children: [
                  Icon(Icons.restaurant_menu, size: 40, color: IFridgeTheme.primary.withValues(alpha: 0.3)),
                  const SizedBox(height: 12),
                  Text('Menu items are managed through the Supabase dashboard for now.\nFull in-app editor is being built.',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12, height: 1.5),
                      textAlign: TextAlign.center),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showAnalytics() {
    showModalBottomSheet(
      context: context,
      backgroundColor: IFridgeTheme.bgElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final posts = _stats['posts'] ?? 0;
        final views = _stats['views'] ?? 0;
        final likes = _stats['likes'] ?? 0;
        final engRate = views > 0 ? ((likes / views) * 100).toStringAsFixed(1) : '0.0';

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              const Text('📊 Analytics Overview', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _AnalyticTile(label: 'Total Posts', value: '$posts', icon: Icons.article)),
                  const SizedBox(width: 10),
                  Expanded(child: _AnalyticTile(label: 'Total Views', value: '$views', icon: Icons.visibility)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _AnalyticTile(label: 'Total Likes', value: '$likes', icon: Icons.favorite)),
                  const SizedBox(width: 10),
                  Expanded(child: _AnalyticTile(label: 'Engagement', value: '$engRate%', icon: Icons.trending_up)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _AnalyticTile(label: 'Followers', value: '$_followers', icon: Icons.people)),
                  const SizedBox(width: 10),
                  Expanded(child: _AnalyticTile(label: 'Avg Likes', value: posts > 0 ? '${(likes / posts).toStringAsFixed(1)}' : '0', icon: Icons.thumb_up)),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

// ── Supporting Widgets ──

class _DialogField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;

  const _DialogField({required this.controller, required this.label, required this.icon, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
        prefixIcon: Icon(icon, color: const Color(0xFFFF6D00).withValues(alpha: 0.6), size: 20),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatTile({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: IFridgeTheme.bgElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.3), size: 20),
          ],
        ),
      ),
    );
  }
}

class _AnalyticTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _AnalyticTile({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white38, size: 18),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11)),
        ],
      ),
    );
  }
}
