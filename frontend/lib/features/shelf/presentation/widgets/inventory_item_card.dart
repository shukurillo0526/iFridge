// I-Fridge — Inventory Item Card Widget
// A single item on the Living Shelf, with freshness overlay,
// expiry badge, and swipe-to-action gestures.

import 'package:flutter/material.dart';
import 'package:ifridge_app/core/utils/ingredient_icons.dart';
import 'package:ifridge_app/features/shelf/domain/inventory_item.dart';
import 'package:ifridge_app/features/shelf/presentation/widgets/freshness_overlay.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class InventoryItemCard extends StatelessWidget {
  final InventoryItem item;
  final VoidCallback? onTap;
  final VoidCallback? onMarkOpened;
  final VoidCallback? onRemove;

  const InventoryItemCard({
    super.key,
    required this.item,
    this.onTap,
    this.onMarkOpened,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isExpired = item.freshnessState == FreshnessState.expired;
    final isUrgent = item.freshnessState == FreshnessState.critical ||
        item.freshnessState == FreshnessState.urgent;

    return UrgencyPulse(
      isUrgent: isUrgent,
      child: GestureDetector(
        onTap: onTap,
        child: Dismissible(
          key: Key(item.id),
          background: Container(
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 20),
            child: Icon(Icons.fastfood, color: Theme.of(context).colorScheme.onSurface, size: 30),
          ),
          secondaryBackground: Container(
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20),
            child: Icon(Icons.delete, color: Theme.of(context).colorScheme.onSurface, size: 30),
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              // Quick Use 1 Unit via RPC
              try {
                await Supabase.instance.client.rpc('consume_inventory_item', params: {
                  'p_inventory_id': item.id,
                  'p_qty_to_consume': 1.0,
                });
                return false; // Snap back, UI updates from realtime stream
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error consuming item: $e')),
                  );
                }
                return false;
              }
            } else {
              // Delete Item
              try {
                await Supabase.instance.client
                    .from('inventory_items')
                    .delete()
                    .eq('id', item.id);
                return true;
              } catch (_) {
                return false;
              }
            }
          },
          child: Stack(
            children: [
              // --- Card Body ---
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // --- Icon / Image Area ---
                    Expanded(
                      flex: 3,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(14),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            IngredientIcons.getEmoji(
                              item.name,
                              category: item.category,
                            ),
                            style: TextStyle(
                              fontSize: 44,
                              color: isExpired
                                  ? Colors.grey
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // --- Info Area ---
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item.name,
                              style: TextStyle(
                                color: isExpired
                                    ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)
                                    : Theme.of(context).colorScheme.onSurface,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                decoration: isExpired
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 3),
                            Text(
                              _expiryLabel,
                              style: TextStyle(
                                color: _expiryLabelColor(context),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // --- Freshness Overlay ---
              Positioned.fill(
                child: FreshnessOverlay(freshnessRatio: item.freshnessRatio),
              ),

              // --- Quantity Badge ---
              if (item.quantity > 0) // Changed to show even if 1 to indicate it is interactable
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${item.quantity.toStringAsFixed(item.quantity == item.quantity.roundToDouble() ? 0 : 1)} ${item.unit}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

              // --- State Badge (opened / frozen) ---
              if (item.itemState != 'sealed')
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: _stateBadgeColor(context).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _stateBadgeLabel,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String get _expiryLabel {
    final days = item.daysUntilExpiry;
    if (days < 0) return 'Expired';
    if (days == 0) return 'Use today!';
    if (days == 1) return 'Tomorrow';
    if (days <= 7) return '$days days';
    return '${(days / 7).floor()}w left';
  }

  Color _expiryLabelColor(BuildContext context) {
    switch (item.freshnessState) {
      case FreshnessState.fresh:
        return Theme.of(context).colorScheme.tertiary;
      case FreshnessState.aging:
        return Theme.of(context).colorScheme.secondary;
      case FreshnessState.urgent:
        return Theme.of(context).colorScheme.primary;
      case FreshnessState.critical:
        return Theme.of(context).colorScheme.error;
      case FreshnessState.expired:
        return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7);
    }
  }

  String get _stateBadgeLabel {
    switch (item.itemState) {
      case 'opened':
        return 'OPENED';
      case 'partially_used':
        return 'PARTIAL';
      case 'frozen':
        return 'FROZEN';
      case 'thawed':
        return 'THAWED';
      default:
        return '';
    }
  }

  Color _stateBadgeColor(BuildContext context) {
    switch (item.itemState) {
      case 'opened':
        return Theme.of(context).colorScheme.secondary;
      case 'frozen':
        return Theme.of(context).colorScheme.secondary;
      case 'thawed':
        return Theme.of(context).colorScheme.primary;
      default:
        return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4);
    }
  }


}
