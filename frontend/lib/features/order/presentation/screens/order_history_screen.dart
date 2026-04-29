// I-Fridge — Order History Screen
// =================================
// Shows user's past and active orders with status tracking.
// Accessible from the Profile/Manage tab.

import 'package:flutter/material.dart';
import 'package:ifridge_app/core/theme/app_theme.dart';
import 'package:ifridge_app/core/services/order_service.dart';
import 'package:ifridge_app/core/services/auth_helper.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<UserOrder> _orders = [];
  bool _loading = true;
  String? _error;

  static const accent = Color(0xFFFF6D00);

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final userId = currentUserId();
      final orders = await OrderService.getUserOrders(userId);
      if (mounted) {
        setState(() {
          _orders = orders;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load orders';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? IFridgeTheme.bgDark : const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: const Text('My Orders',
            style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: accent))
          : _error != null
              ? _buildError(isDark)
              : _orders.isEmpty
                  ? _buildEmpty(isDark)
                  : _buildOrderList(isDark),
    );
  }

  Widget _buildError(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48,
              color: isDark ? Colors.white12 : Colors.black12),
          const SizedBox(height: 12),
          Text(_error!,
              style: TextStyle(
                  color: isDark ? Colors.white38 : Colors.black38,
                  fontSize: 16)),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _loadOrders,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Retry'),
            style: FilledButton.styleFrom(backgroundColor: accent),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined, size: 64,
              color: isDark ? Colors.white12 : Colors.black12),
          const SizedBox(height: 16),
          Text('No orders yet',
              style: TextStyle(
                  color: isDark ? Colors.white38 : Colors.black38,
                  fontSize: 18,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Your order history will appear here',
              style: TextStyle(
                  color: isDark ? Colors.white24 : Colors.black26,
                  fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildOrderList(bool isDark) {
    // Separate active and past orders
    final active = _orders.where((o) => o.isActive).toList();
    final past = _orders.where((o) => !o.isActive).toList();

    return RefreshIndicator(
      onRefresh: _loadOrders,
      color: accent,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Active Orders ─────────────────────────────
          if (active.isNotEmpty) ...[
            _sectionHeader('Active Orders', '${active.length}', isDark),
            const SizedBox(height: 8),
            ...active.map((o) => _OrderCard(
                  order: o,
                  isDark: isDark,
                  onCancel: () => _cancelOrder(o),
                  isActive: true,
                )),
            const SizedBox(height: 24),
          ],

          // ── Past Orders ───────────────────────────────
          if (past.isNotEmpty) ...[
            _sectionHeader('Past Orders', '${past.length}', isDark),
            const SizedBox(height: 8),
            ...past.map((o) => _OrderCard(
                  order: o,
                  isDark: isDark,
                  isActive: false,
                )),
          ],
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, String count, bool isDark) {
    return Row(
      children: [
        Text(title,
            style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                fontSize: 16,
                fontWeight: FontWeight.w700)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(count,
              style: const TextStyle(
                  color: accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }

  Future<void> _cancelOrder(UserOrder order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(ctx).brightness == Brightness.dark
            ? IFridgeTheme.bgCard
            : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel Order?'),
        content: Text(
            'Cancel your order from ${order.restaurantName ?? "this restaurant"}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep Order'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cancel Order'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await OrderService.cancelOrder(order.id);
      if (success && mounted) {
        _loadOrders();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Order cancelled'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }
}

// ═══════════════════════════════════════════════════════════════════
//  ORDER CARD
// ═══════════════════════════════════════════════════════════════════

class _OrderCard extends StatelessWidget {
  final UserOrder order;
  final bool isDark;
  final bool isActive;
  final VoidCallback? onCancel;

  const _OrderCard({
    required this.order,
    required this.isDark,
    required this.isActive,
    this.onCancel,
  });

  static const accent = Color(0xFFFF6D00);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? IFridgeTheme.bgCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? accent.withValues(alpha: 0.2)
              : isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.black.withValues(alpha: 0.05),
          width: isActive ? 1.5 : 1,
        ),
        boxShadow: isActive
            ? [BoxShadow(
                color: accent.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: Restaurant + Status ──────────────
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  order.type == 'delivery'
                      ? Icons.delivery_dining
                      : Icons.shopping_bag_outlined,
                  color: accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.restaurantName ?? 'Restaurant',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${order.itemCount} items · ${order.timeAgo}',
                      style: TextStyle(
                        color: isDark ? Colors.white38 : Colors.black38,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusChip(status: order.status, isDark: isDark),
            ],
          ),

          // ── Status Progress (for active orders) ─────
          if (isActive) ...[
            const SizedBox(height: 16),
            _StatusProgress(status: order.status, type: order.type),
          ],

          // ── Pickup Code (if pickup and active) ──────
          if (isActive &&
              order.type == 'pickup' &&
              order.pickupCode != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Pickup Code: ',
                      style: TextStyle(
                          color: isDark ? Colors.white54 : Colors.black54,
                          fontSize: 13)),
                  Text(order.pickupCode!,
                      style: const TextStyle(
                          color: accent,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 3)),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          // ── Footer: Total + Cancel ──────────────────
          Row(
            children: [
              Text('${order.total.round()} UZS',
                  style: TextStyle(
                      color: accent,
                      fontSize: 15,
                      fontWeight: FontWeight.w700)),
              const SizedBox(width: 8),
              Text(
                order.type == 'delivery' ? '· Delivery' : '· Pickup',
                style: TextStyle(
                    color: isDark ? Colors.white24 : Colors.black26,
                    fontSize: 12),
              ),
              const Spacer(),
              if (isActive && onCancel != null)
                GestureDetector(
                  onTap: onCancel,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Cancel',
                        style: TextStyle(
                            color: Colors.red.withValues(alpha: 0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  STATUS CHIP
// ═══════════════════════════════════════════════════════════════════

class _StatusChip extends StatelessWidget {
  final String status;
  final bool isDark;

  const _StatusChip({required this.status, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg) = switch (status) {
      'confirmed' => (const Color(0xFFFF6D00).withValues(alpha: 0.12), const Color(0xFFFF6D00)),
      'preparing' => (Colors.blue.withValues(alpha: 0.12), Colors.blue),
      'ready' => (Colors.green.withValues(alpha: 0.12), Colors.green),
      'picked_up' || 'delivering' => (Colors.purple.withValues(alpha: 0.12), Colors.purple),
      'completed' => (Colors.green.withValues(alpha: 0.08), Colors.green.withValues(alpha: 0.6)),
      'cancelled' => (Colors.red.withValues(alpha: 0.08), Colors.red.withValues(alpha: 0.6)),
      _ => (Colors.grey.withValues(alpha: 0.1), Colors.grey),
    };

    final label = switch (status) {
      'confirmed' => 'Confirmed',
      'preparing' => 'Preparing',
      'ready' => 'Ready',
      'picked_up' => 'Picked Up',
      'delivering' => 'On the Way',
      'completed' => 'Done',
      'cancelled' => 'Cancelled',
      _ => status,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: TextStyle(
              color: fg, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  STATUS PROGRESS BAR
// ═══════════════════════════════════════════════════════════════════

class _StatusProgress extends StatelessWidget {
  final String status;
  final String type;

  const _StatusProgress({required this.status, required this.type});

  static const accent = Color(0xFFFF6D00);

  @override
  Widget build(BuildContext context) {
    final steps = type == 'delivery'
        ? ['Confirmed', 'Preparing', 'Ready', 'Delivering', 'Done']
        : ['Confirmed', 'Preparing', 'Ready', 'Done'];

    final currentStep = switch (status) {
      'confirmed' => 0,
      'preparing' => 1,
      'ready' => 2,
      'picked_up' || 'delivering' => 3,
      'completed' => steps.length - 1,
      _ => 0,
    };

    return Row(
      children: List.generate(steps.length, (i) {
        final isCompleted = i <= currentStep;
        final isLast = i == steps.length - 1;

        return Expanded(
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? accent : accent.withValues(alpha: 0.15),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    height: 2,
                    color: isCompleted
                        ? accent
                        : accent.withValues(alpha: 0.15),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
