// iFridge — Inventory Detail Bottom Sheet
// =========================================
// Premium sheet for viewing & editing a single inventory item.
// Supports quantity adjustment, location/state changes, and deletion.

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ifridge_app/core/theme/app_theme.dart';
import 'package:ifridge_app/core/utils/category_images.dart';
import 'package:ifridge_app/features/shelf/domain/inventory_item.dart';

class InventoryDetailSheet extends StatefulWidget {
  final InventoryItem item;

  const InventoryDetailSheet({super.key, required this.item});

  /// Convenience launcher.
  static Future<void> show(BuildContext context, InventoryItem item) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => InventoryDetailSheet(item: item),
    );
  }

  @override
  State<InventoryDetailSheet> createState() => _InventoryDetailSheetState();
}

class _InventoryDetailSheetState extends State<InventoryDetailSheet> {
  late double _quantity;
  late String _itemState;
  late String _location;
  bool _updating = false;

  InventoryItem get item => widget.item;

  @override
  void initState() {
    super.initState();
    _quantity = item.quantity;
    _itemState = item.itemState;
    _location = item.location;
  }

  // ── Supabase Mutations ────────────────────────────────────────

  Future<void> _updateField(String field, dynamic value) async {
    setState(() => _updating = true);
    try {
      await Supabase.instance.client
          .from('inventory_items')
          .update({field: value}).eq('id', item.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Update failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  Future<void> _consumeOne() async {
    setState(() => _updating = true);
    try {
      await Supabase.instance.client.rpc('consume_inventory_item', params: {
        'p_inventory_id': item.id,
        'p_qty_to_consume': 1.0,
      });
      setState(() => _quantity = (_quantity - 1).clamp(0, double.infinity));
      if (_quantity <= 0 && mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  Future<void> _deleteItem() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: IFridgeTheme.bgCard,
        title: const Text('Delete item?'),
        content: Text('Remove "${item.name}" from your inventory?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(
                  foregroundColor: IFridgeTheme.criticalRed),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await Supabase.instance.client
          .from('inventory_items')
          .delete()
          .eq('id', item.id);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Delete failed: $e')));
      }
    }
  }

  // ── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85),
      decoration: const BoxDecoration(
        color: IFridgeTheme.bgCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _dragHandle(),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: bottomPad + 32),
              child: Column(children: [
                _heroImage(),
                const SizedBox(height: 16),
                _nameSection(),
                const SizedBox(height: 20),
                _freshnessBar(),
                const SizedBox(height: 24),
                _infoGrid(),
                const SizedBox(height: 24),
                _quantityControls(),
                const SizedBox(height: 20),
                _locationSelector(),
                const SizedBox(height: 16),
                _stateSelector(),
                const SizedBox(height: 24),
                _actionButtons(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── Sub-widgets ───────────────────────────────────────────────

  Widget _dragHandle() => Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 4),
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
              color: IFridgeTheme.textMuted,
              borderRadius: BorderRadius.circular(2)),
        ),
      );

  Widget _heroImage() {
    return Container(
      height: 160,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: NetworkImage(
              item.imageUrl ?? categoryImageUrl(item.category)),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              IFridgeTheme.bgDark.withValues(alpha: 0.7),
            ],
          ),
        ),
        alignment: Alignment.bottomLeft,
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _freshnessColor.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(_freshnessLabel,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
          ),
          const Spacer(),
          Text(categoryEmoji(item.category),
              style: const TextStyle(fontSize: 28)),
        ]),
      ),
    );
  }

  Widget _nameSection() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(children: [
          Text(item.name,
              style: const TextStyle(
                  color: IFridgeTheme.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5),
              textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(
              '${_cap(item.category)} · ${_cap(_location)} · ${_cap(_itemState)}',
              style: const TextStyle(
                  color: IFridgeTheme.textSecondary, fontSize: 13),
              textAlign: TextAlign.center),
        ]),
      );

  Widget _freshnessBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('Freshness',
              style: TextStyle(
                  color: IFridgeTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(_expiryDetail,
              style: TextStyle(
                  color: _freshnessColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: item.freshnessRatio,
            minHeight: 8,
            backgroundColor: IFridgeTheme.bgElevated,
            valueColor: AlwaysStoppedAnimation(_freshnessColor),
          ),
        ),
      ]),
    );
  }

  Widget _infoGrid() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          decoration: BoxDecoration(
            color: IFridgeTheme.bgElevated,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Column(children: [
            Row(children: [
              _infoCell('📦', 'Quantity',
                  '${_fmtQty(_quantity)} ${item.unit}'),
              _vDiv(),
              _infoCell('📅', 'Purchased', _fmtDate(item.purchaseDate)),
            ]),
            Divider(height: 1, color: Colors.white.withValues(alpha: 0.06)),
            Row(children: [
              _infoCell('⏰', 'Expires', _fmtDate(item.computedExpiry)),
              _vDiv(),
              _infoCell('🎯', 'Source', _cap(item.source)),
            ]),
          ]),
        ),
      );

  Widget _infoCell(String emoji, String label, String value) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('$emoji $label',
                style: const TextStyle(
                    color: IFridgeTheme.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    color: IFridgeTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
          ]),
        ),
      );

  Widget _vDiv() =>
      Container(width: 1, height: 50, color: Colors.white.withValues(alpha: 0.06));

  Widget _quantityControls() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          decoration: BoxDecoration(
            color: IFridgeTheme.bgElevated,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _circleBtn(Icons.remove, () {
              if (_quantity > 1) {
                setState(() => _quantity -= 1);
                _updateField('quantity', _quantity);
              }
            }),
            const SizedBox(width: 24),
            Column(children: [
              Text(_fmtQty(_quantity),
                  style: const TextStyle(
                      color: IFridgeTheme.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.w700)),
              Text(item.unit,
                  style: const TextStyle(
                      color: IFridgeTheme.textSecondary, fontSize: 13)),
            ]),
            const SizedBox(width: 24),
            _circleBtn(Icons.add, () {
              setState(() => _quantity += 1);
              _updateField('quantity', _quantity);
            }),
          ]),
        ),
      );

  Widget _circleBtn(IconData icon, VoidCallback onTap) => Material(
        color: IFridgeTheme.bgCard,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: _updating ? null : onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: IFridgeTheme.primary.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: IFridgeTheme.primary, size: 22),
          ),
        ),
      );

  Widget _locationSelector() => _chipRow(
        label: 'Storage Location',
        options: const ['fridge', 'freezer', 'pantry'],
        icons: const [Icons.kitchen, Icons.ac_unit, Icons.inventory_2],
        selected: _location,
        color: IFridgeTheme.primary,
        onSelect: (v) {
          setState(() => _location = v);
          _updateField('location', v);
        },
      );

  Widget _stateSelector() => _chipRow(
        label: 'Item State',
        options: const ['sealed', 'opened', 'frozen'],
        icons: const [Icons.verified_outlined, Icons.lock_open, Icons.ac_unit],
        selected: _itemState,
        color: IFridgeTheme.secondary,
        onSelect: (v) {
          setState(() => _itemState = v);
          _updateField('item_state', v);
        },
      );

  Widget _chipRow({
    required String label,
    required List<String> options,
    required List<IconData> icons,
    required String selected,
    required Color color,
    required ValueChanged<String> onSelect,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(
                color: IFridgeTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(
          children: List.generate(options.length, (i) {
            final active = selected == options[i];
            return Expanded(
              child: GestureDetector(
                onTap: () => onSelect(options[i]),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(right: i < options.length - 1 ? 8 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: active
                        ? color.withValues(alpha: 0.15)
                        : IFridgeTheme.bgElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: active
                            ? color.withValues(alpha: 0.5)
                            : Colors.white.withValues(alpha: 0.06)),
                  ),
                  child: Column(children: [
                    Icon(icons[i],
                        color: active ? color : IFridgeTheme.textMuted,
                        size: 20),
                    const SizedBox(height: 4),
                    Text(_cap(options[i]),
                        style: TextStyle(
                            color: active ? color : IFridgeTheme.textSecondary,
                            fontSize: 12,
                            fontWeight:
                                active ? FontWeight.w600 : FontWeight.w400)),
                  ]),
                ),
              ),
            );
          }),
        ),
      ]),
    );
  }

  Widget _actionButtons() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _updating ? null : _consumeOne,
              icon: const Icon(Icons.restaurant, size: 18),
              label: const Text('Use 1 Unit'),
              style: FilledButton.styleFrom(
                backgroundColor: IFridgeTheme.primary,
                foregroundColor: IFridgeTheme.bgDark,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _updating ? null : _deleteItem,
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Remove from Inventory'),
              style: OutlinedButton.styleFrom(
                foregroundColor: IFridgeTheme.criticalRed,
                side: BorderSide(
                    color: IFridgeTheme.criticalRed.withValues(alpha: 0.3)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ]),
      );

  // ── Helpers ───────────────────────────────────────────────────

  Color get _freshnessColor {
    switch (item.freshnessState) {
      case FreshnessState.fresh:    return IFridgeTheme.freshGreen;
      case FreshnessState.aging:    return IFridgeTheme.agingAmber;
      case FreshnessState.urgent:   return IFridgeTheme.urgentOrange;
      case FreshnessState.critical: return IFridgeTheme.criticalRed;
      case FreshnessState.expired:  return IFridgeTheme.expiredGrey;
    }
  }

  String get _freshnessLabel {
    switch (item.freshnessState) {
      case FreshnessState.fresh:    return '🟢 Fresh';
      case FreshnessState.aging:    return '🟡 Aging';
      case FreshnessState.urgent:   return '🟠 Urgent';
      case FreshnessState.critical: return '🔴 Critical';
      case FreshnessState.expired:  return '⚫ Expired';
    }
  }

  String get _expiryDetail {
    final d = item.daysUntilExpiry;
    if (d < 0) return 'Expired ${-d} day(s) ago';
    if (d == 0) return 'Expires today!';
    if (d == 1) return 'Expires tomorrow';
    return '$d days remaining';
  }

  String _fmtQty(double q) =>
      q.toStringAsFixed(q == q.roundToDouble() ? 0 : 1);

  String _fmtDate(DateTime? d) =>
      d == null ? '—' : '${d.month}/${d.day}/${d.year}';

  String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
