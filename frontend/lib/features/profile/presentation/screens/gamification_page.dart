// I-Fridge — Gamification Deep Page
// ====================================
// Full badge gallery, XP history, level milestones.

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ifridge_app/core/services/auth_helper.dart';
import 'package:ifridge_app/features/gamification/domain/badges.dart';

class GamificationPage extends StatefulWidget {
  const GamificationPage({super.key});
  @override
  State<GamificationPage> createState() => _GamificationPageState();
}

class _GamificationPageState extends State<GamificationPage> {
  Map<String, dynamic>? _stats;
  List<Map<String, dynamic>> _earnedBadges = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final uid = currentUserId();
      final stats = await Supabase.instance.client
          .from('gamification_stats').select().eq('user_id', uid).maybeSingle();
      final userBadges = await Supabase.instance.client
          .from('user_badges').select().eq('user_id', uid);
      setState(() {
        _stats = stats;
        _earnedBadges = List<Map<String, dynamic>>.from(userBadges ?? []);
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final xp = _stats?['total_xp'] ?? 0;
    final level = levelFromXp(xp);
    final nextLevelXp = (level + 1) * 100;
    final levelProgress = (xp % 100) / 100.0;
    final earnedIds = _earnedBadges.map((b) => b['badge_id']).toSet();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text('Badges & Achievements', style: TextStyle(fontWeight: FontWeight.w700))),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
          : ListView(
              padding: EdgeInsets.all(20),
              children: [
                // Level Card
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Theme.of(context).colorScheme.primary.withValues(alpha: 0.15), Theme.of(context).colorScheme.surface],
                      begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2))),
                  child: Column(
                    children: [
                      Text('⭐ Level $level',
                        style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 28, fontWeight: FontWeight.w800)),
                      SizedBox(height: 8),
                      Text('$xp XP total',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 14)),
                      SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: levelProgress, minHeight: 12,
                          backgroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
                          valueColor: AlwaysStoppedAnimation(Theme.of(context).colorScheme.primary)),
                      ),
                      SizedBox(height: 6),
                      Text('${xp % 100} / 100 XP to Level ${level + 1}',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 12)),
                    ],
                  ),
                ),
                SizedBox(height: 24),

                // Stats
                Row(
                  children: [
                    _StatCard(label: 'Meals Cooked', value: '${_stats?['meals_cooked'] ?? 0}', emoji: '🍳'),
                    SizedBox(width: 8),
                    _StatCard(label: 'Items Saved', value: '${_stats?['items_saved'] ?? 0}', emoji: '🥫'),
                    SizedBox(width: 8),
                    _StatCard(label: 'Day Streak', value: '${_stats?['streak_days'] ?? 0}', emoji: '🔥'),
                  ],
                ),
                SizedBox(height: 24),

                // All Badges
                Text('All Badges',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.w700)),
                SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.85),
                  itemCount: WasteBadge.values.length,
                  itemBuilder: (ctx, i) {
                    final badge = WasteBadge.values[i];
                    final earned = earnedIds.contains(badge.name);
                    return Container(
                      decoration: BoxDecoration(
                        color: earned ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.08) : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: earned ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3) : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06))),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          badge.icon.endsWith('.png') || badge.icon.endsWith('.jpg')
                              ? Image.asset(badge.icon, height: 32, width: 32, color: earned ? null : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2), colorBlendMode: earned ? null : BlendMode.saturation)
                              : Text(badge.icon,
                            style: TextStyle(fontSize: 32, color: earned ? null : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2))),
                          SizedBox(height: 6),
                          Text(badge.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: earned ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                              fontSize: 11, fontWeight: FontWeight.w600)),
                          if (!earned)
                            Text('🔒', style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2))),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value, emoji;
  const _StatCard({required this.label, required this.value, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06))),
        child: Column(
          children: [
            Text(emoji, style: TextStyle(fontSize: 22)),
            SizedBox(height: 6),
            Text(value, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.w800)),
            Text(label, textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
