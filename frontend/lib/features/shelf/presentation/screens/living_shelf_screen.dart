// I-Fridge — Living Shelf Screen
// The Digital Twin of the user's kitchen — a reactive grid of inventory items
// organized by storage zone (fridge, freezer, pantry).
// Connected to Supabase with Realtime for live updates.

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ifridge_app/core/widgets/shimmer_loading.dart';
import 'package:ifridge_app/core/widgets/empty_state_illustration.dart';
import 'package:ifridge_app/core/widgets/slide_in_item.dart';
import 'package:ifridge_app/features/shelf/domain/inventory_item.dart';
import 'package:ifridge_app/features/shelf/presentation/widgets/inventory_item_card.dart';
import 'package:ifridge_app/features/cook/presentation/screens/cook_screen.dart';
import 'package:ifridge_app/features/scan/presentation/screens/scan_screen.dart';
import 'package:ifridge_app/features/shelf/presentation/widgets/inventory_detail_sheet.dart';
import 'package:ifridge_app/core/utils/category_images.dart';
import 'package:ifridge_app/core/services/auth_helper.dart';

class LivingShelfScreen extends StatefulWidget {
  const LivingShelfScreen({super.key});

  @override
  State<LivingShelfScreen> createState() => _LivingShelfScreenState();
}

class _LivingShelfScreenState extends State<LivingShelfScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _zones = ['Fridge', 'Freezer', 'Pantry'];

  List<InventoryItem> _items = [];
  bool _loading = true;
  String? _error;
  RealtimeChannel? _channel;

  // ── Search, Filter & Sort state ─────────────────────────────
  String _searchQuery = '';
  String? _selectedCategory;
  _SortMode _sortMode = _SortMode.expiry;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _zones.length, vsync: this);
    _loadInventory();
    _subscribeRealtime();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _channel?.unsubscribe();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Data Loading ─────────────────────────────────────────────

  Future<void> _loadInventory() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final data = await Supabase.instance.client
          .from('inventory_items')
          .select('*, ingredients(display_name_en, category)')
          .eq('user_id', currentUserId())
          .order('computed_expiry', ascending: true);


      setState(() {
        _items = (data as List)
            .map((row) =>
                InventoryItem.fromSupabase(row as Map<String, dynamic>))
            .toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  // ── Realtime Subscription ────────────────────────────────────

  void _subscribeRealtime() {
    _channel = Supabase.instance.client
        .channel('inventory_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'inventory_items',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: currentUserId(),
          ),
          callback: (payload) {
            // Reload full inventory on any change
            _loadInventory();
          },
        )
        .subscribe();
  }

  List<InventoryItem> _itemsForZone(String zone) {
    var filtered = _items.where((i) => i.location == zone.toLowerCase());

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((i) => i.name.toLowerCase().contains(q));
    }

    // Category filter
    if (_selectedCategory != null) {
      filtered = filtered
          .where((i) => i.category.toLowerCase() == _selectedCategory);
    }

    final list = filtered.toList();

    // Sort
    switch (_sortMode) {
      case _SortMode.expiry:
        list.sort((a, b) => a.daysUntilExpiry.compareTo(b.daysUntilExpiry));
      case _SortMode.name:
        list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      case _SortMode.category:
        list.sort((a, b) => a.category.compareTo(b.category));
      case _SortMode.newest:
        list.sort((a, b) => (b.purchaseDate ?? DateTime(2000))
            .compareTo(a.purchaseDate ?? DateTime(2000)));
    }
    return list;
  }

  /// All unique categories currently in the inventory.
  List<String> get _categories {
    final cats = _items.map((i) => i.category.toLowerCase()).toSet().toList()
      ..sort();
    return cats;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🧊 My Fridge'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadInventory,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: Badge(
              isLabelVisible: _alertCount > 0,
              label: Text('$_alertCount',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700)),
              backgroundColor: Theme.of(context).colorScheme.error,
              child: Icon(Icons.notifications_outlined),
            ),
            onPressed: _showExpiryAlerts,
            tooltip: 'Expiry alerts',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.primary,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          tabs: _zones.map((z) => Tab(text: z)).toList(),
        ),
      ),
      body: _loading
          ? const ShelfSkeleton()
          : _error != null
              ? _buildErrorState()
              : TabBarView(
                  controller: _tabController,
                  children: _zones.map((zone) {
                    final items = _itemsForZone(zone);
                    return _buildShelfGrid(items, zone);
                  }).toList(),
                ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off,
                size: 64, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
            SizedBox(height: 16),
            Text(
              'Couldn\'t load inventory',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Check your connection and try again.',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 13),
            ),
            SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _loadInventory,
              icon: Icon(Icons.refresh),
              label: Text('Retry'),
              style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
            ),
          ],
        ),
      ),
    );
  }

  // ── Summary Stats Banner ──────────────────────────────────────

  Widget _buildSummaryBanner(List<InventoryItem> zoneItems) {
    final total = zoneItems.length;
    final expiring =
        zoneItems.where((i) => i.daysUntilExpiry >= 0 && i.daysUntilExpiry <= 3).length;
    final expired = zoneItems.where((i) => i.daysUntilExpiry < 0).length;
    final fresh = total - expiring - expired;

    return Container(
      margin: EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _statChip('$total', 'Total', Theme.of(context).colorScheme.primary),
          _statChip('$fresh', 'Fresh', Theme.of(context).colorScheme.tertiary),
          _statChip('$expiring', 'Expiring', Theme.of(context).colorScheme.primary),
          _statChip('$expired', 'Expired', Theme.of(context).colorScheme.error),
        ],
      ),
    );
  }

  Widget _statChip(String value, String label, Color color) {
    return Column(children: [
      Text(value,
          style: TextStyle(
              color: color, fontSize: 20, fontWeight: FontWeight.w800)),
      SizedBox(height: 2),
      Text(label,
          style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 11,
              fontWeight: FontWeight.w500)),
    ]);
  }

  // ── Search Bar ────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => setState(() => _searchQuery = v),
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search ingredients...',
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 14),
          prefixIcon:
              Icon(Icons.search, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close, size: 18,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)),
          ),
        ),
      ),
    );
  }

  // ── Category Chips ────────────────────────────────────────────

  Widget _buildCategoryChips() {
    if (_categories.isEmpty) return SizedBox.shrink();
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 12),
        children: [
          _filterChip(null, 'All'),
          ..._categories.map((c) => _filterChip(c, _cap(c))),
        ],
      ),
    );
  }

  Widget _filterChip(String? cat, String label) {
    final active = _selectedCategory == cat;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        selected: active,
        label: Text(
          cat != null ? '${categoryEmoji(cat)} $label' : label,
          style: TextStyle(
            color: active ? Theme.of(context).scaffoldBackgroundColor : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: 12,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        onSelected: (_) => setState(() => _selectedCategory = cat),
        selectedColor: Theme.of(context).colorScheme.primary,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        checkmarkColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: BorderSide(
          color: active
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
        ),
        padding: EdgeInsets.symmetric(horizontal: 4),
      ),
    );
  }

  // ── Sort Row ──────────────────────────────────────────────────

  Widget _buildSortRow(int count) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(children: [
        Text('$count items',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 13,
                fontWeight: FontWeight.w500)),
        Spacer(),
        SizedBox(
          height: 28,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<_SortMode>(
              value: _sortMode,
              isDense: true,
              icon: Icon(Icons.swap_vert,
                  size: 14, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
              dropdownColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 12),
              items: _SortMode.values
                  .map((m) => DropdownMenuItem(
                      value: m, child: Text(m.label)))
                  .toList(),
              onChanged: (m) {
                if (m != null) setState(() => _sortMode = m);
              },
            ),
          ),
        ),
      ]),
    );
  }

  // ── Shelf Grid (the main zone content) ────────────────────────

  Widget _buildShelfGrid(List<InventoryItem> items, String zone) {
    // Get ALL zone items before search/filter for the summary banner
    final allZoneItems = _items
        .where((i) => i.location == zone.toLowerCase())
        .toList();

    if (allZoneItems.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: 100),
        child: EmptyStateIllustration(
          icon: _zoneIcon(zone),
          title: 'Your $zone is Empty',
          description:
              'Ready to fill up your digital kitchen.\nAdd items manually or tap scan.',
          actionLabel: 'Add Ingredient',
          onAction: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ScanScreen()),
            );
          },
        ),
      );
    }

    // Separate urgent items for the banner
    final urgentItems =
        allZoneItems.where((i) => i.daysUntilExpiry <= 2 && i.daysUntilExpiry >= 0).toList();

    return RefreshIndicator(
      onRefresh: _loadInventory,
      color: Theme.of(context).colorScheme.primary,
      child: CustomScrollView(
        slivers: [
          // --- Summary Banner ---
          SliverToBoxAdapter(child: _buildSummaryBanner(allZoneItems)),

          // --- Search Bar ---
          SliverToBoxAdapter(child: _buildSearchBar()),

          // --- Category Chips ---
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: 4, bottom: 4),
              child: _buildCategoryChips(),
            ),
          ),

          // --- Expiring Soon Banner ---
          if (urgentItems.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.fromLTRB(16, 4, 16, 4),
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Theme.of(context).colorScheme.error.withValues(alpha: 0.15),
                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  ]),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color:
                          Theme.of(context).colorScheme.error.withValues(alpha: 0.3)),
                ),
                child: Row(children: [
                  Text('⚠️', style: TextStyle(fontSize: 22)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Expiring Soon',
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13)),
                          Text(
                              '${urgentItems.length} item(s) need attention',
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                  fontSize: 11)),
                        ]),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const CookScreen())),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      padding: EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                    ),
                    child: Text('Cook Now',
                        style:
                            TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface)),
                  ),
                ]),
              ),
            ),

          // --- Sort Row ---
          SliverToBoxAdapter(child: _buildSortRow(items.length)),

          // --- Empty search result ---
          if (items.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 60),
                child: Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.search_off,
                        size: 48,
                        color:
                            Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                    SizedBox(height: 12),
                    Text('No items match your filters',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                            fontSize: 14)),
                    SizedBox(height: 8),
                    TextButton(
                      onPressed: () => setState(() {
                        _searchQuery = '';
                        _searchCtrl.clear();
                        _selectedCategory = null;
                      }),
                      child: Text('Clear filters'),
                    ),
                  ]),
                ),
              ),
            ),

          // --- Main Grid ---
          if (items.isNotEmpty)
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _gridColumns(context),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.72,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => SlideInItem(
                    delay: index * 60,
                    child: InventoryItemCard(
                      item: items[index],
                      onTap: () =>
                          InventoryDetailSheet.show(context, items[index]),
                    ),
                  ),
                  childCount: items.length,
                ),
              ),
            ),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  IconData _zoneIcon(String zone) {
    if (zone == 'Fridge') return Icons.kitchen;
    if (zone == 'Freezer') return Icons.ac_unit;
    if (zone == 'Pantry') return Icons.inventory_2;
    return Icons.shelves;
  }

  int get _alertCount =>
      _items.where((i) => i.daysUntilExpiry <= 3).length;

  int _gridColumns(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w > 1200) return 6;
    if (w > 900) return 5;
    if (w > 600) return 4;
    if (w > 400) return 3;
    return 2;
  }

  void _showExpiryAlerts() {
    final expiring = _items
        .where((i) => i.daysUntilExpiry >= 0 && i.daysUntilExpiry <= 3)
        .toList();
    final expired = _items.where((i) => i.daysUntilExpiry < 0).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            SizedBox(height: 16),
            Text('🔔 Expiry Alerts',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface)),
            SizedBox(height: 16),
            if (expired.isEmpty && expiring.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('All items are fresh! 🎉',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 15)),
                ),
              ),
            if (expired.isNotEmpty) ...[
              Text('❌ Expired (${expired.length})',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w600,
                      fontSize: 14)),
              SizedBox(height: 8),
              ...expired.take(5).map((item) => _alertTile(item, true)),
              SizedBox(height: 16),
            ],
            if (expiring.isNotEmpty) ...[
              Text('⚠️ Expiring Soon (${expiring.length})',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14)),
              SizedBox(height: 8),
              ...expiring.take(5).map((item) => _alertTile(item, false)),
            ],
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _alertTile(InventoryItem item, bool isExpired) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: [
          Text(categoryEmoji(item.category),
              style: TextStyle(fontSize: 20)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 13)),
                  Text(
                    isExpired
                        ? 'Expired ${-item.daysUntilExpiry} day(s) ago'
                        : item.daysUntilExpiry == 0
                            ? 'Expires today'
                            : 'Expires in ${item.daysUntilExpiry} day(s)',
                    style: TextStyle(
                        color: isExpired
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).colorScheme.primary,
                        fontSize: 11),
                  ),
                ]),
          ),
        ]),
      ),
    );
  }

  String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ── Sort Mode Enum ──────────────────────────────────────────────

enum _SortMode {
  expiry('Expiry ↑'),
  name('Name A-Z'),
  category('Category'),
  newest('Newest first');

  final String label;
  const _SortMode(this.label);
}
