# Section 3: The "Digital Twin" UI Architecture (Flutter)

> **Design Philosophy:** The UI should feel like looking into a *real* fridge shelf — skeuomorphic, tactile, and alive. Items glow, fade, and pulse based on their freshness state.

---

## 3.1 Widget Tree Overview

```
MaterialApp
└── ShellRoute (Bottom Nav)
    ├── LivingShelfScreen        ← The Digital Twin
    │   ├── ShelfZoneSelector    ← Fridge / Freezer / Pantry tabs
    │   └── ShelfGrid            ← The main inventory view
    │       └── InventoryItemCard (× N)
    │           ├── FreshnessOverlay (shader)
    │           ├── ExpiryBadge
    │           └── QuickActions (swipe)
    │
    ├── CookScreen               ← "What can I cook?"
    │   └── TierCarousel (× 5)
    │       └── RecipeCard (× N)
    │
    ├── ScanScreen               ← Camera / Barcode
    │   └── VisionResultSheet
    │
    └── ProfileScreen
        ├── FlavorProfileRadar
        ├── GamificationDashboard
        └── StreakCalendar
```

---

## 3.2 The Living Shelf — Infinite Scroll Implementation

The shelf does **not** use a traditional infinite scroll (loading pages from a remote API). Instead, it uses **Supabase Realtime** for a reactive, subscription-based model.

### Data Flow

```dart
// lib/features/shelf/data/shelf_repository.dart

class ShelfRepository {
  final SupabaseClient _supabase;
  
  /// Returns a real-time stream of inventory items.
  /// Supabase Realtime pushes INSERT/UPDATE/DELETE events.
  Stream<List<InventoryItem>> watchInventory(String userId, String zone) {
    return _supabase
        .from('inventory_items')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .eq('location', zone)          // 'fridge', 'freezer', 'pantry'
        .order('computed_expiry', ascending: true)  // expiring soonest first
        .map((rows) => rows.map(InventoryItem.fromJson).toList());
  }
}
```

### Virtual Scroll with `SliverGrid`

For users with 100+ items, we use a `CustomScrollView` with `SliverGrid` and a builder pattern to lazily build only visible items:

```dart
// lib/features/shelf/presentation/widgets/shelf_grid.dart

class ShelfGrid extends StatelessWidget {
  final List<InventoryItem> items;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // "Expiring Soon" header section
        SliverToBoxAdapter(
          child: _ExpiringSoonBanner(
            items: items.where((i) => i.daysUntilExpiry <= 2).toList(),
          ),
        ),
        
        // Main grid — lazy builder, only renders visible cells
        SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,         // 3 items per shelf row
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.75,    // taller cards for label space
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => InventoryItemCard(item: items[index]),
            childCount: items.length,
          ),
        ),
      ],
    );
  }
}
```

---

## 3.3 Freshness Visualization — Shader Overlays

Each `InventoryItemCard` has a **FreshnessOverlay** that modulates in real-time based on remaining shelf life.

### Freshness State Machine

| Freshness Ratio | State | Visual Effect |
|-----------------|-------|---------------|
| > 60% remaining | `FRESH` | Vibrant colors, subtle green glow border |
| 30–60% | `AGING` | Slightly desaturated, amber pulse animation |
| 10–30% | `URGENT` | Warm overlay, orange badge pulses |
| < 10% | `CRITICAL` | Darkened + red vignette, "Use Today!" badge |
| 0% (expired) | `EXPIRED` | Grayscale + strikethrough, moved to "Expired" section |

### Implementation

```dart
// lib/features/shelf/presentation/widgets/freshness_overlay.dart

class FreshnessOverlay extends StatelessWidget {
  final double freshnessRatio; // 0.0 (expired) to 1.0 (perfectly fresh)

  const FreshnessOverlay({required this.freshnessRatio});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _overlayColor.withOpacity(0.0),    // transparent at top
            _overlayColor.withOpacity(_overlayOpacity), // tinted at bottom
          ],
        ),
        border: Border.all(
          color: _borderColor,
          width: freshnessRatio < 0.1 ? 2.5 : 1.0,
        ),
        boxShadow: freshnessRatio > 0.6
            ? [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 8)]
            : null,
      ),
    );
  }

  Color get _overlayColor {
    if (freshnessRatio > 0.6) return Colors.transparent;
    if (freshnessRatio > 0.3) return Colors.amber;
    if (freshnessRatio > 0.1) return Colors.orange;
    if (freshnessRatio > 0.0) return Colors.red;
    return Colors.grey; // expired
  }

  double get _overlayOpacity {
    if (freshnessRatio > 0.6) return 0.0;
    return (1.0 - freshnessRatio) * 0.4; // max 40% overlay
  }

  Color get _borderColor {
    if (freshnessRatio > 0.6) return Colors.green.shade300;
    if (freshnessRatio > 0.3) return Colors.amber.shade400;
    if (freshnessRatio > 0.1) return Colors.orange.shade500;
    return Colors.red.shade600;
  }
}
```

### Pulse Animation for Urgent Items

```dart
// lib/features/shelf/presentation/widgets/urgency_pulse.dart

class UrgencyPulse extends StatefulWidget {
  final Widget child;
  final bool isUrgent;

  @override
  State<UrgencyPulse> createState() => _UrgencyPulseState();
}

class _UrgencyPulseState extends State<UrgencyPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _scaleAnim = Tween(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.isUrgent) _controller.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _scaleAnim, child: widget.child);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

---

## 3.4 Gamification System — "Waste Warrior"

### Core Mechanic: XP + Streaks + Badges

Users earn XP for waste-reducing behaviors. The system is designed to be **intrinsically motivating** (reducing waste feels good) with **extrinsic reinforcement** (badges and streaks).

| Action | XP Reward | Description |
|--------|-----------|-------------|
| Cook a Tier 1 meal | **+50 XP** | Used only existing ingredients — zero waste! |
| Cook a Tier 2 meal | **+40 XP** | Tried something new with what you have |
| Cook a Tier 3/4 meal | **+20 XP** | Needed a minor shop, still efficient |
| Use an "Urgent" item | **+15 XP** | Saved an item about to expire |
| Maintain a 7-day streak | **+100 XP bonus** | Cooked at least once/day for a week |
| Remove an expired item | **-5 XP** | Gentle penalty for waste |

### Badge System

```dart
// lib/features/gamification/domain/badges.dart

enum WasteBadge {
  firstMeal('🍳', 'First Meal', 'Cook your first recipe'),
  wasteFighter('♻️', 'Waste Fighter', 'Cook 10 Tier 1 meals'),
  wasteWarrior('🛡️', 'Waste Warrior', 'Cook 50 Tier 1 meals'),
  weekStreak('🔥', 'Week Streak', '7-day cooking streak'),
  monthStreak('⭐', 'Iron Chef', '30-day cooking streak'),
  explorer('🌍', 'Flavor Explorer', 'Cook 5 different cuisines'),
  rescuer('🚨', 'Expiry Rescuer', 'Save 20 items from expiring'),
  zeroWasteWeek('💎', 'Zero Waste Week', 'No expired items for 7 days');

  final String emoji;
  final String title;
  final String description;

  const WasteBadge(this.emoji, this.title, this.description);
}
```

### UI: Floating XP Toast

When a user completes a Tier 1 meal, an animated toast floats up:

```dart
// Triggered after recipe marked as "Cooked"
void _showXpReward(BuildContext context, int xp, WasteBadge? newBadge) {
  final overlay = OverlayEntry(
    builder: (context) => Positioned(
      bottom: 100,
      left: 0,
      right: 0,
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 600),
          builder: (context, value, child) => Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 30 * (1 - value)),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade700, Colors.teal.shade500],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(blurRadius: 16, color: Colors.black26)],
                ),
                child: Text(
                  newBadge != null
                      ? '${newBadge.emoji} ${newBadge.title} +${xp}XP!'
                      : '+${xp}XP! 🌿 Waste Reduced!',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Overlay.of(context).insert(overlay);
  Future.delayed(const Duration(seconds: 3), overlay.remove);
}
```

---

*← [Section 2: Algorithm](./TDD_02_ALGORITHM.md) | [Section 4: Vision Pipeline →](./TDD_04_VISION_PIPELINE.md)*
