import os
import re

path = r'd:\dev\projects\iFridge\frontend\lib\features\profile\presentation\screens\profile_screen.dart'
with open(path, 'r', encoding='utf-8') as f: content = f.read()

# 1. Update import
content = content.replace(
    "import 'package:ifridge_app/features/gamification/domain/badges.dart' show levelFromXp;",
    "import 'package:ifridge_app/features/gamification/domain/badges.dart' show levelFromXp, WasteBadge, computeEarnedBadges;"
)

# 2. Update state variables
content = content.replace(
    "List<Map<String, dynamic>> _badges = [];",
    "Set<WasteBadge> _earnedBadges = {};"
)

content = content.replace(
    "_badges = [];",
    "_earnedBadges = {};"
)

# 3. Update data loading
old_load = """      if (statsData != null) {
        _totalXp = statsData['xp_points'] as int? ?? 0;
        _level = levelFromXp(_totalXp);
        _mealsCooked = statsData['total_meals_cooked'] as int? ?? 0;
        _itemsSaved = statsData['items_saved'] as int? ?? 0;
        _currentStreak = statsData['current_streak'] as int? ?? 0;
        final rawBadges = statsData['badges'];
        if (rawBadges is List) {
          _badges = rawBadges.cast<Map<String, dynamic>>();
        }
      }"""

new_load = """      if (statsData != null) {
        _totalXp = statsData['xp_points'] as int? ?? 0;
        _level = levelFromXp(_totalXp);
        _mealsCooked = statsData['total_meals_cooked'] as int? ?? 0;
        _itemsSaved = statsData['items_saved'] as int? ?? 0;
        _currentStreak = statsData['current_streak'] as int? ?? 0;
        _earnedBadges = computeEarnedBadges(statsData);
      }"""
content = content.replace(old_load, new_load)

# 4. Update _buildBadgeList
old_build = """  List<Widget> _buildBadgeList() {
    final earnedIds = _badges.map((b) => b['id'] as String?).toSet();

    const allPossible = [
      {'id': 'first_scan', 'icon': '📸', 'name': 'First Scan'},
      {'id': 'first_meal', 'icon': '🧑‍🍳', 'name': 'First Cook'},
      {'id': 'waste_fighter', 'icon': '🛡️', 'name': 'Waste Fighter'},
      {'id': 'streak_7', 'icon': '🔥', 'name': '7-Day Streak'},
      {'id': 'streak_67', 'icon': 'assets/images/badges/streak_67.png', 'name': '6,7 Day Streak'},
      {'id': 'world_chef', 'icon': '🌍', 'name': 'World Chef'},
      {'id': 'master_chef', 'icon': '💎', 'name': 'Master Chef'},
    ];

    return allPossible
        .map((b) => _BadgeTile(
              icon: b['icon']!,
              name: b['name']!,
              earned: earnedIds.contains(b['id']),
            ))
        .toList();
  }"""

new_build = """  List<Widget> _buildBadgeList() {
    return WasteBadge.values.map((badge) {
      final earned = _earnedBadges.contains(badge);
      return _BadgeTile(
        icon: badge.icon,
        name: badge.title,
        earned: earned,
      );
    }).toList();
  }"""
content = content.replace(old_build, new_build)

# 5. Fix _BadgeTile image support
# Wait, _BadgeTile might not support image.asset! Let's check _BadgeTile in the script or modify it.
old_badge_tile = """class _BadgeTile extends StatelessWidget {
  final String icon;
  final String name;
  final bool earned;

  const _BadgeTile({required this.icon, required this.name, this.earned = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: earned ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1) : Theme.of(context).colorScheme.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: earned ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.5) : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              icon,
              style: TextStyle(
                fontSize: 28,
                color: earned ? null : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
              ),
            ),
          ),
        ),
        SizedBox(height: 6),
        Text(
          name,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10,
            fontWeight: earned ? FontWeight.bold : FontWeight.normal,
            color: earned ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }
}"""

new_badge_tile = """class _BadgeTile extends StatelessWidget {
  final String icon;
  final String name;
  final bool earned;

  const _BadgeTile({required this.icon, required this.name, this.earned = false});

  @override
  Widget build(BuildContext context) {
    Widget iconWidget;
    if (icon.endsWith('.png') || icon.endsWith('.jpg')) {
      iconWidget = Image.asset(
        icon, 
        width: 32, 
        height: 32,
        color: earned ? null : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
        colorBlendMode: earned ? null : BlendMode.saturation,
      );
    } else {
      iconWidget = Text(
        icon,
        style: TextStyle(
          fontSize: 28,
          color: earned ? null : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: earned ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1) : Theme.of(context).colorScheme.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: earned ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.5) : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
              width: 2,
            ),
          ),
          child: Center(child: iconWidget),
        ),
        SizedBox(height: 6),
        Text(
          name,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10,
            fontWeight: earned ? FontWeight.bold : FontWeight.normal,
            color: earned ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }
}"""

if old_badge_tile in content:
    content = content.replace(old_badge_tile, new_badge_tile)
else:
    print("WARNING: Could not find _BadgeTile in profile_screen.dart")

with open(path, 'w', encoding='utf-8') as f: f.write(content)
print("Patched profile_screen.dart successfully!")
