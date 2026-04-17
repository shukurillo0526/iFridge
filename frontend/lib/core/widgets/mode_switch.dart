// I-Fridge — Mode Switch Widget
// ==============================
// A premium pill-shaped toggle for switching between Order and Cook modes.
// Features glassmorphic styling, sliding animation, and mode icons.

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ifridge_app/core/theme/app_theme.dart';
import 'package:ifridge_app/core/services/app_settings.dart';

class ModeSwitch extends StatelessWidget {
  final AppMode currentMode;
  final ValueChanged<AppMode> onModeChanged;

  const ModeSwitch({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isOrder = currentMode == AppMode.order;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.06),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.08),
        ),
      ),
      child: Stack(
        children: [
          // Sliding indicator
          AnimatedAlign(
            alignment: isOrder ? Alignment.centerLeft : Alignment.centerRight,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            child: Container(
              width: 80,
              height: 36,
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  colors: isOrder
                      ? [const Color(0xFFFF6D00), const Color(0xFFFF9100)]
                      : [IFridgeTheme.primary, IFridgeTheme.secondary],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isOrder
                            ? const Color(0xFFFF6D00)
                            : IFridgeTheme.primary)
                        .withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          // Labels
          Row(
            children: [
              _ModeTab(
                label: 'ORDER',
                icon: Icons.delivery_dining,
                isActive: isOrder,
                onTap: () => onModeChanged(AppMode.order),
              ),
              _ModeTab(
                label: 'COOK',
                icon: Icons.restaurant,
                isActive: !isOrder,
                onTap: () => onModeChanged(AppMode.cook),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _ModeTab({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
              color: isActive
                  ? Colors.white
                  : Theme.of(context).brightness == Brightness.dark
                      ? Colors.white54
                      : Colors.black45,
              letterSpacing: 1.2,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedScale(
                  scale: isActive ? 1.0 : 0.85,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    icon,
                    size: 15,
                    color: isActive
                        ? Colors.white
                        : Theme.of(context).brightness == Brightness.dark
                            ? Colors.white54
                            : Colors.black45,
                  ),
                ),
                const SizedBox(width: 4),
                Text(label),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
