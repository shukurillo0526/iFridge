// I-Fridge — Region Picker Sheet (Karrot-style, Redesigned)
// ============================================================
// Clean, modern bottom sheet for choosing your area:
// - Shows your detected GPS location at the top
// - Lists regions as selectable cards sorted by distance
// - "Nearest" badge on closest region
// - Selected region highlighted with orange accent
// - Smooth animations and premium feel

import 'package:flutter/material.dart';
import 'package:ifridge_app/core/theme/app_theme.dart';
import 'package:ifridge_app/core/services/location_service.dart';

class RegionPickerSheet extends StatefulWidget {
  final LocationService location;
  final VoidCallback? onRegionChanged;

  const RegionPickerSheet({
    super.key,
    required this.location,
    this.onRegionChanged,
  });

  @override
  State<RegionPickerSheet> createState() => _RegionPickerSheetState();
}

class _RegionPickerSheetState extends State<RegionPickerSheet> {
  @override
  void initState() {
    super.initState();
    if (widget.location.nearbyRegions.isEmpty) {
      widget.location.fetchNearbyRegions().then((_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const accent = Color(0xFFFF6D00);
    final loc = widget.location;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? IFridgeTheme.bgDark : const Color(0xFFF6F8FA),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // ── Handle ─────────────────────────────
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // ── Header ─────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF6D00), Color(0xFFFF9100)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.explore, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Choose Your Area',
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontSize: 20, fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text('Content will be filtered to this neighborhood',
                                style: TextStyle(
                                  color: isDark ? Colors.white38 : Colors.black38,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ── GPS Location Card ────────────────
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.withValues(alpha: 0.08),
                            Colors.blue.withValues(alpha: 0.03),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue.withValues(alpha: 0.12)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.gps_fixed, size: 16, color: Colors.blue.shade400),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Your Location',
                                  style: TextStyle(
                                    color: Colors.blue.shade400,
                                    fontSize: 11, fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  loc.hasLocation
                                      ? '${loc.gpsLatitude.toStringAsFixed(4)}°N, ${loc.gpsLongitude.toStringAsFixed(4)}°E'
                                      : 'Detecting...',
                                  style: TextStyle(
                                    color: isDark ? Colors.white54 : Colors.black45,
                                    fontSize: 13, fontWeight: FontWeight.w500,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (loc.hasSelectedRegion)
                            GestureDetector(
                              onTap: () async {
                                await loc.clearRegionSelection();
                                widget.onRegionChanged?.call();
                                if (mounted) setState(() {});
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.gps_fixed, size: 12, color: Colors.blue.shade400),
                                    const SizedBox(width: 4),
                                    Text('Use GPS', style: TextStyle(
                                      color: Colors.blue.shade400, fontSize: 11, fontWeight: FontWeight.w600,
                                    )),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Section Label ──────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Text('📍 Nearby Areas',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontSize: 14, fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('${loc.nearbyRegions.length}',
                        style: TextStyle(color: accent, fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const Spacer(),
                    Text('sorted by distance',
                      style: TextStyle(
                        color: isDark ? Colors.white24 : Colors.black26,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ── Region List ────────────────────────
              Expanded(
                child: loc.nearbyRegions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_searching, size: 40,
                                color: isDark ? Colors.white12 : Colors.black12),
                            const SizedBox(height: 12),
                            Text('No regions found',
                              style: TextStyle(color: isDark ? Colors.white30 : Colors.black26, fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text('Run the SQL migration to add regions',
                              style: TextStyle(color: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black12, fontSize: 12),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                        itemCount: loc.nearbyRegions.length,
                        itemBuilder: (ctx, i) {
                          final region = loc.nearbyRegions[i];
                          final isSelected = loc.selectedRegion?.id == region.id;
                          final isNearest = i == 0;

                          return GestureDetector(
                            onTap: () => _selectRegion(region),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? accent.withValues(alpha: 0.08)
                                    : isDark ? IFridgeTheme.bgCard : Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isSelected
                                      ? accent
                                      : isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.05),
                                  width: isSelected ? 1.5 : 1,
                                ),
                                boxShadow: isSelected ? [
                                  BoxShadow(color: accent.withValues(alpha: 0.1), blurRadius: 12, offset: const Offset(0, 4)),
                                ] : null,
                              ),
                              child: Row(
                                children: [
                                  // ── Icon ────────────
                                  Container(
                                    width: 46, height: 46,
                                    decoration: BoxDecoration(
                                      gradient: isSelected
                                          ? const LinearGradient(colors: [Color(0xFFFF6D00), Color(0xFFFF9100)])
                                          : null,
                                      color: isSelected ? null :
                                          isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        isSelected ? Icons.location_on : Icons.location_on_outlined,
                                        color: isSelected ? Colors.white :
                                            isDark ? Colors.white30 : Colors.black26,
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  // ── Info ─────────────
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(region.name,
                                                style: TextStyle(
                                                  color: isSelected ? accent :
                                                      isDark ? Colors.white : Colors.black87,
                                                  fontSize: 16, fontWeight: FontWeight.w700,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (isNearest) ...[
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.green.withValues(alpha: 0.12),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text('📍 Nearest',
                                                  style: TextStyle(color: Colors.green.shade600, fontSize: 9, fontWeight: FontWeight.w700),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Row(
                                          children: [
                                            Text(region.city,
                                              style: TextStyle(color: isDark ? Colors.white30 : Colors.black26, fontSize: 12),
                                            ),
                                            Container(
                                              margin: const EdgeInsets.symmetric(horizontal: 6),
                                              width: 3, height: 3,
                                              decoration: BoxDecoration(
                                                color: isDark ? Colors.white12 : Colors.black12,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            Icon(Icons.near_me, size: 11,
                                                color: isDark ? Colors.white24 : Colors.black26),
                                            const SizedBox(width: 3),
                                            Text(loc.formatDistance(region.distMeters),
                                              style: TextStyle(
                                                color: isDark ? Colors.white38 : Colors.black38,
                                                fontSize: 12, fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            if (region.nameLocal != null && region.nameLocal!.isNotEmpty) ...[
                                              Container(
                                                margin: const EdgeInsets.symmetric(horizontal: 6),
                                                width: 3, height: 3,
                                                decoration: BoxDecoration(
                                                  color: isDark ? Colors.white12 : Colors.black12,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              Flexible(
                                                child: Text(region.nameLocal!,
                                                  style: TextStyle(
                                                    color: isDark ? Colors.white24 : Colors.black26,
                                                    fontSize: 11,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // ── Check ───────────
                                  if (isSelected)
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: accent,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.check, color: Colors.white, size: 14),
                                    )
                                  else
                                    Icon(Icons.circle_outlined, size: 22,
                                        color: isDark ? Colors.white12 : Colors.black12),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _selectRegion(Region region) async {
    await widget.location.selectRegion(region);
    widget.onRegionChanged?.call();
    if (mounted) Navigator.pop(context);
  }
}
