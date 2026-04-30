// I-Fridge — Freshness Overlay Widget
// Renders a color overlay that modulates based on an item's freshness state.
// Items glow green when fresh, darken when aging, and pulse red when critical.

import 'package:flutter/material.dart';

class FreshnessOverlay extends StatelessWidget {
  final double freshnessRatio;

  const FreshnessOverlay({super.key, required this.freshnessRatio});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _overlayColor(context).withOpacity(0.0),
            _overlayColor(context).withOpacity(_overlayOpacity),
          ],
        ),
        border: Border.all(
          color: _borderColor(context),
          width: freshnessRatio < 0.1 ? 2.5 : 1.0,
        ),
        boxShadow: freshnessRatio > 0.6
            ? [
                BoxShadow(
                  color: Theme.of(context).colorScheme.tertiary.withOpacity(0.25),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
    );
  }

  Color _overlayColor(BuildContext context) {
    if (freshnessRatio > 0.6) return Colors.transparent;
    if (freshnessRatio > 0.3) return Theme.of(context).colorScheme.secondary;
    if (freshnessRatio > 0.1) return Theme.of(context).colorScheme.primary;
    if (freshnessRatio > 0.0) return Theme.of(context).colorScheme.error;
    return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7);
  }

  double get _overlayOpacity {
    if (freshnessRatio > 0.6) return 0.0;
    return (1.0 - freshnessRatio) * 0.4;
  }

  Color _borderColor(BuildContext context) {
    if (freshnessRatio > 0.6) return Theme.of(context).colorScheme.tertiary.withOpacity(0.5);
    if (freshnessRatio > 0.3) return Theme.of(context).colorScheme.secondary;
    if (freshnessRatio > 0.1) return Theme.of(context).colorScheme.primary;
    return Theme.of(context).colorScheme.error;
  }
}

/// Wraps a child widget with a subtle scale pulse when urgent.
class UrgencyPulse extends StatefulWidget {
  final Widget child;
  final bool isUrgent;

  const UrgencyPulse({
    super.key,
    required this.child,
    required this.isUrgent,
  });

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
  void didUpdateWidget(UrgencyPulse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isUrgent && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isUrgent && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0.0;
    }
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
