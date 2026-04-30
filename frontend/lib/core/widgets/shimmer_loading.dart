// I-Fridge — Shimmer / Skeleton Loading Widget
// Used across all screens as a premium loading placeholder.

import 'package:flutter/material.dart';

/// A pulsing shimmer box used for skeleton loading states.
class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 12,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, _) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.04 + _animation.value * 0.06),
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08 + _animation.value * 0.04),
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.04 + _animation.value * 0.06),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
      ),
    );
  }
}

/// Skeleton layout for inventory grid items.
class ShelfSkeleton extends StatelessWidget {
  const ShelfSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.72,
        ),
        itemCount: 6,
        itemBuilder: (_, _) => const ShimmerBox(height: 120, borderRadius: 14),
      ),
    );
  }
}

/// Skeleton layout for recipe list items.
class RecipeListSkeleton extends StatelessWidget {
  const RecipeListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (_, _) => Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: ShimmerBox(height: 140, borderRadius: 16),
      ),
    );
  }
}

/// Skeleton layout for profile sections.
class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          // Avatar
          Center(child: ShimmerBox(width: 80, height: 80, borderRadius: 40)),
          SizedBox(height: 16),
          Center(child: ShimmerBox(width: 120, height: 20)),
          SizedBox(height: 24),
          // XP bar
          const ShimmerBox(height: 60),
          SizedBox(height: 20),
          // Stats row
          Row(
            children: List.generate(3, (_) => Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: ShimmerBox(height: 80),
              ),
            )),
          ),
          SizedBox(height: 20),
          const ShimmerBox(height: 120),
          SizedBox(height: 20),
          const ShimmerBox(height: 180),
        ],
      ),
    );
  }
}
