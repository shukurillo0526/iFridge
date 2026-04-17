// I-Fridge — Restaurant Detail Page
// ====================================
// Full restaurant page with service-aware sections:
// - Menu (with optional highlighted item from feed)
// - Reserve a Seat (if has_reservation)
// - Location & Navigate (if has_dine_in)
// - Reviews section
//
// Navigation: from feeds (with menuItemId) or from order screen.

import 'package:flutter/material.dart';
import 'package:ifridge_app/core/theme/app_theme.dart';
import 'package:ifridge_app/core/services/restaurant_service.dart';

/// Which section to auto-scroll to when opening
enum RestaurantSection { menu, reserve, location, reviews }

class RestaurantDetailPage extends StatefulWidget {
  final Restaurant restaurant;
  final RestaurantSection initialSection;
  final String? highlightMenuItemId; // from feed video

  const RestaurantDetailPage({
    super.key,
    required this.restaurant,
    this.initialSection = RestaurantSection.menu,
    this.highlightMenuItemId,
  });

  @override
  State<RestaurantDetailPage> createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<MenuItem> _menuItems = [];
  bool _loadingMenu = true;

  // Reviews (mock for now)
  final List<_Review> _reviews = [
    _Review('Sardor M.', 5, 'Best plov in town! Always fresh and generous portions.', '2 days ago'),
    _Review('Dilnoza K.', 4, 'Good food, quick service. Delivery was on time.', '1 week ago'),
    _Review('Bekzod T.', 5, 'My go-to place for lagman. Highly recommend!', '2 weeks ago'),
    _Review('Nilufar A.', 4, 'Nice atmosphere, friendly staff. Prices are fair.', '3 weeks ago'),
    _Review('Jasur R.', 3, 'Food is okay but waiting time could be better.', '1 month ago'),
  ];

  // Reservation state
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 19, minute: 0);
  int _guestCount = 2;

  @override
  void initState() {
    super.initState();
    _setupTabs();
    _loadMenu();
  }

  void _setupTabs() {
    final tabCount = _buildTabList().length;
    final initialIndex = _getInitialTabIndex();
    _tabController = TabController(
      length: tabCount,
      vsync: this,
      initialIndex: initialIndex,
    );
  }

  int _getInitialTabIndex() {
    final tabs = _buildTabList();
    switch (widget.initialSection) {
      case RestaurantSection.menu:
        return 0;
      case RestaurantSection.reserve:
        return tabs.indexWhere((t) => t.key == 'reserve').clamp(0, tabs.length - 1);
      case RestaurantSection.location:
        return tabs.indexWhere((t) => t.key == 'location').clamp(0, tabs.length - 1);
      case RestaurantSection.reviews:
        return tabs.indexWhere((t) => t.key == 'reviews').clamp(0, tabs.length - 1);
    }
  }

  List<_TabInfo> _buildTabList() {
    final r = widget.restaurant;
    final tabs = <_TabInfo>[];
    if (r.hasDelivery || r.hasDineIn) {
      tabs.add(_TabInfo('menu', Icons.restaurant_menu, 'Menu'));
    }
    if (r.hasReservation) {
      tabs.add(_TabInfo('reserve', Icons.event_seat_outlined, 'Reserve'));
    }
    if (r.hasDineIn || (r.latitude != 0 && r.longitude != 0)) {
      tabs.add(_TabInfo('location', Icons.map_outlined, 'Location'));
    }
    tabs.add(_TabInfo('reviews', Icons.star_outline, 'Reviews'));
    return tabs;
  }

  Future<void> _loadMenu() async {
    final items = await RestaurantService.getMenu(widget.restaurant.id);
    if (mounted) {
      setState(() {
        _menuItems = items;
        _loadingMenu = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const accent = Color(0xFFFF6D00);
    final r = widget.restaurant;
    final tabs = _buildTabList();

    return Scaffold(
      backgroundColor: isDark ? IFridgeTheme.bgDark : const Color(0xFFF6F8FA),
      body: NestedScrollView(
        headerSliverBuilder: (ctx, innerBoxScrolled) => [
          // ── App Bar ────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: isDark ? IFridgeTheme.bgDark : Colors.white,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      accent.withValues(alpha: 0.6),
                      isDark ? IFridgeTheme.bgDark : const Color(0xFFF6F8FA),
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 40),
                      Text(_getEmoji(r), style: const TextStyle(fontSize: 56)),
                      const SizedBox(height: 8),
                      Text(r.name,
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
                      ),
                      Text(r.cuisineLabel,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Info Header ────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service badges
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (r.hasDelivery) _badge('🛵 Delivery', Colors.green, isDark),
                      if (r.hasReservation) _badge('🪑 Reservation', Colors.blue, isDark),
                      if (r.hasDineIn) _badge('📍 Dine-in', Colors.teal, isDark),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Stats row
                  Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.amber.shade600),
                      const SizedBox(width: 4),
                      Text('${r.rating}', style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 15, fontWeight: FontWeight.w700,
                      )),
                      Text(' (${r.reviewCount})', style: TextStyle(
                        color: isDark ? Colors.white38 : Colors.black26, fontSize: 13,
                      )),
                      const SizedBox(width: 16),
                      if (r.hasDelivery) ...[
                        Icon(Icons.schedule, size: 14, color: isDark ? Colors.white38 : Colors.black26),
                        const SizedBox(width: 4),
                        Text('${r.estimatedDeliveryMinutes} min', style: TextStyle(
                          color: isDark ? Colors.white54 : Colors.black45, fontSize: 13,
                        )),
                        const SizedBox(width: 16),
                      ],
                      if (r.distMeters > 0) ...[
                        Icon(Icons.near_me, size: 14, color: isDark ? Colors.white38 : Colors.black26),
                        const SizedBox(width: 4),
                        Text(r.distanceLabel, style: TextStyle(
                          color: isDark ? Colors.white54 : Colors.black45, fontSize: 13,
                        )),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (r.address != null)
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 14, color: isDark ? Colors.white24 : Colors.black26),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(r.address!, style: TextStyle(
                            color: isDark ? Colors.white38 : Colors.black38, fontSize: 12,
                          )),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          // ── Tab Bar ────────────────────────────────
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              TabBar(
                controller: _tabController,
                isScrollable: tabs.length > 3,
                labelColor: accent,
                unselectedLabelColor: isDark ? Colors.white38 : Colors.black38,
                indicatorColor: accent,
                indicatorWeight: 3,
                labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                tabs: tabs.map((t) => Tab(
                  icon: Icon(t.icon, size: 18),
                  text: t.label,
                )).toList(),
              ),
              isDark ? IFridgeTheme.bgDark : const Color(0xFFF6F8FA),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: tabs.map((t) {
            switch (t.key) {
              case 'menu':
                return _MenuTab(
                  menuItems: _menuItems,
                  loading: _loadingMenu,
                  restaurant: r,
                  highlightItemId: widget.highlightMenuItemId,
                  isDark: isDark,
                );
              case 'reserve':
                return _ReserveTab(
                  restaurant: r,
                  date: _selectedDate,
                  time: _selectedTime,
                  guests: _guestCount,
                  onDateChanged: (d) => setState(() => _selectedDate = d),
                  onTimeChanged: (t) => setState(() => _selectedTime = t),
                  onGuestsChanged: (g) => setState(() => _guestCount = g),
                  isDark: isDark,
                );
              case 'location':
                return _LocationTab(restaurant: r, isDark: isDark);
              case 'reviews':
                return _ReviewsTab(reviews: _reviews, restaurant: r, isDark: isDark);
              default:
                return const SizedBox.shrink();
            }
          }).toList(),
        ),
      ),
    );
  }

  Widget _badge(String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  String _getEmoji(Restaurant r) {
    final c = r.cuisineType;
    if (c.contains('Korean')) return '🥘';
    if (c.contains('Japanese') || c.contains('Sushi')) return '🍱';
    if (c.contains('Italian') || c.contains('Pizza')) return '🍕';
    if (c.contains('Fast Food') || c.contains('American')) return '🍔';
    if (c.contains('BBQ')) return '🥩';
    if (c.contains('Noodles')) return '🍜';
    return '🍛';
  }
}

// ═══════════════════════════════════════════════════════════════════
//  TAB BAR DELEGATE
// ═══════════════════════════════════════════════════════════════════

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color bgColor;
  _TabBarDelegate(this.tabBar, this.bgColor);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: bgColor, child: tabBar);
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}

class _TabInfo {
  final String key;
  final IconData icon;
  final String label;
  const _TabInfo(this.key, this.icon, this.label);
}

// ═══════════════════════════════════════════════════════════════════
//  MENU TAB
// ═══════════════════════════════════════════════════════════════════

class _MenuTab extends StatelessWidget {
  final List<MenuItem> menuItems;
  final bool loading;
  final Restaurant restaurant;
  final String? highlightItemId;
  final bool isDark;

  const _MenuTab({
    required this.menuItems,
    required this.loading,
    required this.restaurant,
    this.highlightItemId,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFFF6D00);

    if (loading) {
      return const Center(child: CircularProgressIndicator(color: accent));
    }

    if (menuItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.restaurant_menu, size: 48, color: isDark ? Colors.white12 : Colors.black12),
            const SizedBox(height: 12),
            Text('Menu coming soon',
              style: TextStyle(color: isDark ? Colors.white38 : Colors.black26, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text('This restaurant hasn\'t added their menu yet.',
              style: TextStyle(color: isDark ? Colors.white24 : Colors.black12, fontSize: 12),
            ),
          ],
        ),
      );
    }

    // Group by category
    final categories = <String, List<MenuItem>>{};
    for (final item in menuItems) {
      final cat = item.category ?? 'Other';
      categories.putIfAbsent(cat, () => []).add(item);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      children: [
        // Delivery fee info
        if (restaurant.hasDelivery)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accent.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Icon(Icons.delivery_dining, size: 16, color: accent),
                const SizedBox(width: 8),
                Text(
                  restaurant.deliveryFee > 0
                      ? 'Delivery: ${restaurant.deliveryFee.round()} UZS · ~${restaurant.estimatedDeliveryMinutes} min'
                      : 'Free delivery · ~${restaurant.estimatedDeliveryMinutes} min',
                  style: TextStyle(color: accent, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

        // Menu items by category
        ...categories.entries.expand((entry) => [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 0, 8),
            child: Text(entry.key,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                fontSize: 16, fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ...entry.value.map((item) {
            final isHighlighted = item.id == highlightItemId;
            return _MenuItemCard(
              item: item,
              isDark: isDark,
              isHighlighted: isHighlighted,
              hasDelivery: restaurant.hasDelivery,
            );
          }),
        ]),
      ],
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  final MenuItem item;
  final bool isDark;
  final bool isHighlighted;
  final bool hasDelivery;

  const _MenuItemCard({
    required this.item,
    required this.isDark,
    this.isHighlighted = false,
    required this.hasDelivery,
  });

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFFF6D00);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isHighlighted
            ? accent.withValues(alpha: 0.08)
            : isDark ? IFridgeTheme.bgCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighlighted
              ? accent
              : isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.05),
          width: isHighlighted ? 1.5 : 1,
        ),
        boxShadow: isHighlighted ? [
          BoxShadow(color: accent.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2)),
        ] : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(item.name,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 15, fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (isHighlighted)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('From video', style: TextStyle(color: accent, fontSize: 9, fontWeight: FontWeight.w700)),
                      ),
                    if (item.tags.contains('bestseller') && !isHighlighted)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('🔥 Best', style: TextStyle(color: accent, fontSize: 9, fontWeight: FontWeight.w700)),
                      ),
                  ],
                ),
                if (item.description != null) ...[
                  const SizedBox(height: 3),
                  Text(item.description!,
                    style: TextStyle(color: isDark ? Colors.white30 : Colors.black26, fontSize: 12),
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text('${item.price.round()} UZS',
                      style: TextStyle(color: accent, fontSize: 14, fontWeight: FontWeight.w700)),
                    if (item.calories != null) ...[
                      const SizedBox(width: 10),
                      Text('${item.calories} cal',
                        style: TextStyle(color: isDark ? Colors.white24 : Colors.black26, fontSize: 11)),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (hasDelivery) ...[
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('➕ Added ${item.name} to cart'),
                  backgroundColor: accent,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  duration: const Duration(seconds: 1),
                ));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.add, color: accent, size: 18),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  RESERVE TAB
// ═══════════════════════════════════════════════════════════════════

class _ReserveTab extends StatelessWidget {
  final Restaurant restaurant;
  final DateTime date;
  final TimeOfDay time;
  final int guests;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<TimeOfDay> onTimeChanged;
  final ValueChanged<int> onGuestsChanged;
  final bool isDark;

  const _ReserveTab({
    required this.restaurant,
    required this.date,
    required this.time,
    required this.guests,
    required this.onDateChanged,
    required this.onTimeChanged,
    required this.onGuestsChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF2962FF);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
      children: [
        // Header
        Text('Book a Table',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 22, fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text('Reserve your spot at ${restaurant.name}',
          style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 13),
        ),
        const SizedBox(height: 24),

        // ── Date ─────────────────────────────────
        _reserveSection(
          icon: Icons.calendar_today,
          title: 'Date',
          isDark: isDark,
          child: GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: date,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 90)),
              );
              if (picked != null) onDateChanged(picked);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: _fieldDecor(isDark),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: accent),
                  const SizedBox(width: 10),
                  Text(
                    '${date.day}/${date.month}/${date.year}',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 15, fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_right, size: 18, color: isDark ? Colors.white24 : Colors.black26),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // ── Time ─────────────────────────────────
        _reserveSection(
          icon: Icons.schedule,
          title: 'Time',
          isDark: isDark,
          child: GestureDetector(
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: time,
              );
              if (picked != null) onTimeChanged(picked);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: _fieldDecor(isDark),
              child: Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: accent),
                  const SizedBox(width: 10),
                  Text(
                    time.format(context),
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 15, fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_right, size: 18, color: isDark ? Colors.white24 : Colors.black26),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // ── Guests ───────────────────────────────
        _reserveSection(
          icon: Icons.people_outline,
          title: 'Number of Guests',
          isDark: isDark,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: _fieldDecor(isDark),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _guestBtn(Icons.remove, () {
                  if (guests > 1) onGuestsChanged(guests - 1);
                }, isDark),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text('$guests',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 24, fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                _guestBtn(Icons.add, () {
                  if (guests < 20) onGuestsChanged(guests + 1);
                }, isDark),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),

        // ── Confirm Button ───────────────────────
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('🪑 Table reserved at ${restaurant.name}\n${date.day}/${date.month} at ${time.format(context)} for $guests guests'),
              backgroundColor: accent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 3),
            ));
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF2962FF), Color(0xFF448AFF)]),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_seat, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Confirm Reservation', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _reserveSection({required IconData icon, required String title, required bool isDark, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: isDark ? Colors.white38 : Colors.black38),
            const SizedBox(width: 6),
            Text(title, style: TextStyle(
              color: isDark ? Colors.white54 : Colors.black45,
              fontSize: 12, fontWeight: FontWeight.w600,
            )),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  BoxDecoration _fieldDecor(bool isDark) {
    return BoxDecoration(
      color: isDark ? IFridgeTheme.bgCard : Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.06)),
    );
  }

  Widget _guestBtn(IconData icon, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: isDark ? Colors.white54 : Colors.black38),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  LOCATION TAB
// ═══════════════════════════════════════════════════════════════════

class _LocationTab extends StatelessWidget {
  final Restaurant restaurant;
  final bool isDark;

  const _LocationTab({required this.restaurant, required this.isDark});

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF00897B);
    final r = restaurant;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
      children: [
        // Header
        Text('Location & Directions',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 22, fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 16),

        // Address card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? IFridgeTheme.bgCard : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.location_on, color: accent, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.name, style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 16, fontWeight: FontWeight.w700,
                        )),
                        if (r.address != null)
                          Text(r.address!, style: TextStyle(
                            color: isDark ? Colors.white38 : Colors.black38, fontSize: 13,
                          )),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (r.distMeters > 0) ...[
                    Icon(Icons.near_me, size: 14, color: isDark ? Colors.white38 : Colors.black26),
                    const SizedBox(width: 4),
                    Text(r.distanceLabel, style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black45, fontSize: 13,
                    )),
                    const SizedBox(width: 16),
                  ],
                  Text(
                    '${r.latitude.toStringAsFixed(4)}°N, ${r.longitude.toStringAsFixed(4)}°E',
                    style: TextStyle(
                      color: isDark ? Colors.white24 : Colors.black26,
                      fontSize: 11, fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Map placeholder with gradient
        Container(
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [accent.withValues(alpha: 0.15), accent.withValues(alpha: 0.05)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accent.withValues(alpha: 0.15)),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.map, size: 48, color: accent.withValues(alpha: 0.4)),
                const SizedBox(height: 8),
                Text('Map View', style: TextStyle(
                  color: accent.withValues(alpha: 0.6), fontSize: 14, fontWeight: FontWeight.w600,
                )),
                Text('${r.latitude.toStringAsFixed(4)}, ${r.longitude.toStringAsFixed(4)}',
                  style: TextStyle(color: accent.withValues(alpha: 0.4), fontSize: 11, fontFamily: 'monospace'),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Navigate button
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('🧭 Opening Google Maps for ${r.name}...\n${r.mapsUrl}'),
              backgroundColor: accent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 3),
            ));
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF00897B), Color(0xFF26A69A)]),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.navigation, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Open in Google Maps', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  REVIEWS TAB
// ═══════════════════════════════════════════════════════════════════

class _Review {
  final String author;
  final int stars;
  final String text;
  final String timeAgo;
  const _Review(this.author, this.stars, this.text, this.timeAgo);
}

class _ReviewsTab extends StatelessWidget {
  final List<_Review> reviews;
  final Restaurant restaurant;
  final bool isDark;

  const _ReviewsTab({required this.reviews, required this.restaurant, required this.isDark});

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFFF6D00);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
      children: [
        // Rating summary
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? IFridgeTheme.bgCard : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
              Column(
                children: [
                  Text('${restaurant.rating}',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 40, fontWeight: FontWeight.w800,
                    ),
                  ),
                  Row(
                    children: List.generate(5, (i) => Icon(
                      i < restaurant.rating.round() ? Icons.star : Icons.star_border,
                      size: 16, color: Colors.amber.shade600,
                    )),
                  ),
                  const SizedBox(height: 4),
                  Text('${restaurant.reviewCount} reviews',
                    style: TextStyle(color: isDark ? Colors.white38 : Colors.black26, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: [5, 4, 3, 2, 1].map((star) {
                    // Mock distribution
                    final pct = star == 5 ? 0.55 : star == 4 ? 0.25 : star == 3 ? 0.12 : star == 2 ? 0.05 : 0.03;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Text('$star', style: TextStyle(color: isDark ? Colors.white38 : Colors.black26, fontSize: 11)),
                          const SizedBox(width: 6),
                          Icon(Icons.star, size: 10, color: Colors.amber.shade600),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.04),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: pct,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade600,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Write review button
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('✍️ Write a review for ${restaurant.name}'),
              backgroundColor: accent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ));
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: accent.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.edit, size: 16, color: accent),
                const SizedBox(width: 8),
                Text('Write a Review', style: TextStyle(color: accent, fontSize: 14, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Reviews list
        ...reviews.map((review) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? IFridgeTheme.bgCard : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accent.withValues(alpha: 0.1),
                    ),
                    child: Center(
                      child: Text(review.author[0],
                        style: TextStyle(color: accent, fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(review.author, style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 14, fontWeight: FontWeight.w600,
                        )),
                        Row(
                          children: [
                            ...List.generate(review.stars, (_) =>
                              Icon(Icons.star, size: 12, color: Colors.amber.shade600)),
                            const SizedBox(width: 6),
                            Text(review.timeAgo, style: TextStyle(
                              color: isDark ? Colors.white24 : Colors.black26, fontSize: 11,
                            )),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(review.text, style: TextStyle(
                color: isDark ? Colors.white54 : Colors.black54,
                fontSize: 13, height: 1.4,
              )),
            ],
          ),
        )),
      ],
    );
  }
}
