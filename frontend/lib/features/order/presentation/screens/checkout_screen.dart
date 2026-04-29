// I-Fridge — Checkout Screen
// ============================
// Order review, order type selection (pickup/delivery),
// and confirmation with pickup code generation.

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ifridge_app/core/theme/app_theme.dart';
import 'package:ifridge_app/core/services/cart_service.dart';
import 'package:ifridge_app/core/services/order_service.dart';
import 'package:ifridge_app/core/services/auth_helper.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final CartService _cart = CartService();
  bool _placing = false;
  String? _error;

  static const accent = Color(0xFFFF6D00);

  Future<void> _placeOrder() async {
    setState(() {
      _placing = true;
      _error = null;
    });

    try {
      final userId = currentUserId();
      final orderData = await OrderService.placeOrder(
        userId: userId,
        restaurantId: _cart.restaurant!.id,
        type: _cart.orderType == OrderType.pickup ? 'pickup' : 'delivery',
        items: _cart.items.map((ci) => {
          'menu_item_id': ci.menuItem.id,
          'name': ci.menuItem.name,
          'price': ci.menuItem.price,
          'quantity': ci.quantity,
          'special_instructions': ci.specialInstructions,
          'subtotal': ci.subtotal,
        }).toList(),
      );

      final pickupCode = orderData['pickup_code'] as String? ?? _generatePickupCode();

      if (!mounted) return;

      // Navigate to confirmation
      final restaurantName = _cart.restaurant?.name ?? 'Restaurant';
      final estMinutes = _cart.estimatedMinutes;
      final orderType = _cart.orderType;

      _cart.clear();

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => _OrderConfirmationScreen(
            pickupCode: pickupCode,
            restaurantName: restaurantName,
            estimatedMinutes: estMinutes,
            orderType: orderType,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _error = 'Failed to place order. Please try again.';
        _placing = false;
      });
    }
  }

  String _generatePickupCode() {
    final rand = Random();
    final letters = String.fromCharCodes(
      List.generate(2, (_) => rand.nextInt(26) + 65),
    );
    final numbers = rand.nextInt(900) + 100;
    return '$letters$numbers';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? IFridgeTheme.bgDark : const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListenableBuilder(
        listenable: _cart,
        builder: (context, _) {
          if (_cart.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 64,
                      color: isDark ? Colors.white12 : Colors.black12),
                  const SizedBox(height: 16),
                  Text('Your cart is empty',
                      style: TextStyle(
                          color: isDark ? Colors.white38 : Colors.black38,
                          fontSize: 18)),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Restaurant Info ────────────────────
                      _buildRestaurantHeader(isDark),
                      const SizedBox(height: 16),

                      // ── Order Type Toggle ──────────────────
                      _buildOrderTypeToggle(isDark),
                      const SizedBox(height: 16),

                      // ── Cart Items ─────────────────────────
                      _buildItemsList(isDark),
                      const SizedBox(height: 16),

                      // ── Price Summary ──────────────────────
                      _buildPriceSummary(isDark),

                      // ── Error ──────────────────────────────
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(_error!,
                                    style: TextStyle(
                                        color: Colors.red.withValues(alpha: 0.8),
                                        fontSize: 13)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // ── Place Order Button ─────────────────────
              _buildPlaceOrderButton(isDark),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRestaurantHeader(bool isDark) {
    final r = _cart.restaurant;
    if (r == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? IFridgeTheme.bgCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.04)
                : Colors.black.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.storefront, color: accent, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.name,
                    style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text('~${_cart.estimatedMinutes} min · ${r.distanceLabel}',
                    style: TextStyle(
                        color: isDark ? Colors.white38 : Colors.black38,
                        fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTypeToggle(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? IFridgeTheme.bgCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.04)
                : Colors.black.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          _orderTypeButton(
            icon: Icons.shopping_bag_outlined,
            label: 'Pickup',
            isSelected: _cart.orderType == OrderType.pickup,
            onTap: () => _cart.setOrderType(OrderType.pickup),
            isDark: isDark,
          ),
          if (_cart.restaurant?.hasDelivery ?? false)
            _orderTypeButton(
              icon: Icons.delivery_dining,
              label: 'Delivery',
              isSelected: _cart.orderType == OrderType.delivery,
              onTap: () => _cart.setOrderType(OrderType.delivery),
              isDark: isDark,
            ),
        ],
      ),
    );
  }

  Widget _orderTypeButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? accent : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 18,
                  color: isSelected
                      ? Colors.white
                      : isDark
                          ? Colors.white38
                          : Colors.black38),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : isDark
                              ? Colors.white54
                              : Colors.black54,
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemsList(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? IFridgeTheme.bgCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.04)
                : Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text('Your Order',
                style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontSize: 14,
                    fontWeight: FontWeight.w700)),
          ),
          ..._cart.items.map((ci) => _buildCartItemRow(ci, isDark)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildCartItemRow(CartItem ci, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ci.menuItem.name,
                    style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
                if (ci.specialInstructions != null &&
                    ci.specialInstructions!.isNotEmpty)
                  Text(ci.specialInstructions!,
                      style: TextStyle(
                          color: isDark ? Colors.white24 : Colors.black26,
                          fontSize: 11,
                          fontStyle: FontStyle.italic)),
              ],
            ),
          ),
          // Quantity controls
          Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _qtyButton(Icons.remove, () => _cart.decrementItem(ci.menuItem.id), isDark),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text('${ci.quantity}',
                      style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                ),
                _qtyButton(Icons.add, () => _cart.addItem(ci.menuItem, _cart.restaurant!), isDark),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 70,
            child: Text('${ci.subtotal.round()} UZS',
                textAlign: TextAlign.end,
                style: TextStyle(
                    color: accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon,
            size: 16,
            color: isDark ? Colors.white54 : Colors.black45),
      ),
    );
  }

  Widget _buildPriceSummary(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? IFridgeTheme.bgCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.04)
                : Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          _priceRow('Subtotal', '${_cart.subtotal.round()} UZS', isDark),
          if (_cart.orderType == OrderType.delivery) ...[
            const SizedBox(height: 8),
            _priceRow(
                'Delivery',
                _cart.deliveryFee > 0
                    ? '${_cart.deliveryFee.round()} UZS'
                    : 'Free',
                isDark),
          ],
          const SizedBox(height: 8),
          Divider(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06)),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('Total',
                  style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 17,
                      fontWeight: FontWeight.w800)),
              const Spacer(),
              Text('${_cart.total.round()} UZS',
                  style: const TextStyle(
                      color: accent,
                      fontSize: 17,
                      fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.schedule, size: 14,
                  color: isDark ? Colors.white24 : Colors.black26),
              const SizedBox(width: 4),
              Text(
                  'Estimated: ~${_cart.estimatedMinutes} min',
                  style: TextStyle(
                      color: isDark ? Colors.white38 : Colors.black38,
                      fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value, bool isDark) {
    return Row(
      children: [
        Text(label,
            style: TextStyle(
                color: isDark ? Colors.white54 : Colors.black45,
                fontSize: 14)),
        const Spacer(),
        Text(value,
            style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                fontSize: 14,
                fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildPlaceOrderButton(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: isDark ? IFridgeTheme.bgCard : Colors.white,
        border: Border(
          top: BorderSide(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.black.withValues(alpha: 0.05)),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton(
            onPressed: _placing ? null : _placeOrder,
            style: FilledButton.styleFrom(
              backgroundColor: accent,
              disabledBackgroundColor: accent.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: _placing
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                          'Place ${_cart.orderType == OrderType.pickup ? 'Pickup' : 'Delivery'} Order · ${_cart.total.round()} UZS',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  ORDER CONFIRMATION SCREEN
// ═══════════════════════════════════════════════════════════════════

class _OrderConfirmationScreen extends StatelessWidget {
  final String pickupCode;
  final String restaurantName;
  final int estimatedMinutes;
  final OrderType orderType;

  const _OrderConfirmationScreen({
    required this.pickupCode,
    required this.restaurantName,
    required this.estimatedMinutes,
    required this.orderType,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const accent = Color(0xFFFF6D00);

    return Scaffold(
      backgroundColor: isDark ? IFridgeTheme.bgDark : const Color(0xFFF6F8FA),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        accent.withValues(alpha: 0.2),
                        accent.withValues(alpha: 0.05),
                      ],
                    ),
                  ),
                  child: const Icon(Icons.check_circle, color: accent, size: 56),
                ),
                const SizedBox(height: 24),

                Text('Order Confirmed!',
                    style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 26,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(restaurantName,
                    style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black45,
                        fontSize: 16)),
                const SizedBox(height: 32),

                // Pickup Code
                if (orderType == OrderType.pickup) ...[
                  Text('Your Pickup Code',
                      style: TextStyle(
                          color: isDark ? Colors.white38 : Colors.black38,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: accent.withValues(alpha: 0.3)),
                    ),
                    child: Text(pickupCode,
                        style: const TextStyle(
                            color: accent,
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 6)),
                  ),
                  const SizedBox(height: 12),
                  Text('Show this code at the counter',
                      style: TextStyle(
                          color: isDark ? Colors.white38 : Colors.black38,
                          fontSize: 13)),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.delivery_dining,
                            color: accent, size: 32),
                        const SizedBox(height: 8),
                        Text('Delivery on the way',
                            style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text('A driver will be assigned shortly',
                            style: TextStyle(
                                color: isDark ? Colors.white38 : Colors.black38,
                                fontSize: 13)),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Estimated time
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.schedule, color: accent, size: 18),
                    const SizedBox(width: 6),
                    Text('Ready in ~$estimatedMinutes minutes',
                        style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.black54,
                            fontSize: 15,
                            fontWeight: FontWeight.w500)),
                  ],
                ),

                const SizedBox(height: 48),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: accent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Back to Home',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
