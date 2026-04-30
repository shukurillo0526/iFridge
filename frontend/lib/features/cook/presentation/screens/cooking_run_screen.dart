// I-Fridge — Active Cooking Screen (Enhanced)
// =============================================
// Distraction-free, step-by-step cooking tutorial.
// Features: persistent timer bar, auto-start timers, interactive countdown,
// attention flags, wakelock, swipeable step cards, and AI tips.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:ifridge_app/core/services/api_service.dart';
import 'package:ifridge_app/features/cook/presentation/screens/cooking_reward_screen.dart';

class CookingRunScreen extends StatefulWidget {
  final String recipeId;
  final String title;
  final List<Map<String, dynamic>> steps;
  final List<Map<String, dynamic>>? ingredients;
  final List<String>? prepNotes;
  final int matchedIngredientsCount;
  final double matchPct;

  const CookingRunScreen({
    super.key,
    required this.recipeId,
    required this.title,
    required this.steps,
    this.ingredients,
    this.prepNotes,
    required this.matchedIngredientsCount,
    required this.matchPct,
  });

  @override
  State<CookingRunScreen> createState() => _CookingRunScreenState();
}

class _CookingRunScreenState extends State<CookingRunScreen> {
  late PageController _pageController;
  int _currentIndex = 0;
  bool _showPrepNotes = true;

  // Global timer tracking: step_index → remaining seconds
  final Map<int, int> _activeTimers = {};
  final Map<int, Timer> _timerObjects = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WakelockPlus.enable();
    // Hide prep notes if none exist
    if (widget.prepNotes == null || widget.prepNotes!.isEmpty) {
      _showPrepNotes = false;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final t in _timerObjects.values) {
      t.cancel();
    }
    WakelockPlus.disable();
    super.dispose();
  }

  void _startTimerForStep(int stepIndex, int seconds) {
    if (_activeTimers.containsKey(stepIndex)) return; // already running
    _activeTimers[stepIndex] = seconds;
    _timerObjects[stepIndex] = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { timer.cancel(); return; }
      setState(() {
        final remaining = (_activeTimers[stepIndex] ?? 1) - 1;
        if (remaining <= 0) {
          _activeTimers.remove(stepIndex);
          timer.cancel();
          _timerObjects.remove(stepIndex);
          // Vibrate on completion
          HapticFeedback.heavyImpact();
          _showTimerDoneAlert(stepIndex);
        } else {
          _activeTimers[stepIndex] = remaining;
        }
      });
    });
  }

  void _showTimerDoneAlert(int stepIndex) {
    final stepNum = stepIndex + 1;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('⏱ Timer done! Step $stepNum complete'),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _nextStep() {
    if (_currentIndex < widget.steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _prevStep() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _finishCooking() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CookingRewardScreen(
          recipeId: widget.recipeId,
          title: widget.title,
          matchedIngredientsCount: widget.matchedIngredientsCount,
          matchPct: widget.matchPct,
        ),
      ),
    );
  }

  String _formatTimer(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.steps.isEmpty) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: Center(
          child: Text('No steps available for this recipe.',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        ),
      );
    }

    // Prep notes overlay
    if (_showPrepNotes) {
      return _buildPrepNotesScreen();
    }

    final totalSteps = widget.steps.length;
    final progress = (_currentIndex + 1) / totalSteps;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Persistent Timer Bar ──────────────────────────
            if (_activeTimers.isNotEmpty)
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.timer, color: Theme.of(context).colorScheme.primary, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _activeTimers.entries.map((e) {
                            return Padding(
                              padding: EdgeInsets.only(right: 14),
                              child: GestureDetector(
                                onTap: () {
                                  // Jump to that step
                                  _pageController.animateToPage(e.key,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOut);
                                },
                                child: Text(
                                  'Step ${e.key + 1}: ${_formatTimer(e.value)}',
                                  style: TextStyle(
                                    color: e.value < 30
                                        ? Colors.orange
                                        : Theme.of(context).colorScheme.primary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    fontFeatures: const [FontFeature.tabularFigures()],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // ── Progress Bar ──────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
                  duration: const Duration(milliseconds: 300),
                  builder: (context, value, _) => LinearProgressIndicator(
                    value: value,
                    minHeight: 6,
                    backgroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text('Step ${_currentIndex + 1} of $totalSteps',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 13)),
              ),
            ),

            // ── Step Carousel ─────────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (idx) => setState(() => _currentIndex = idx),
                itemCount: totalSteps,
                itemBuilder: (context, index) {
                  return _CookingStepCard(
                    step: widget.steps[index],
                    stepIndex: index,
                    timerRemaining: _activeTimers[index],
                    onStartTimer: (seconds) => _startTimerForStep(index, seconds),
                  );
                },
              ),
            ),

            // ── Navigation Controls ───────────────────────────
            Padding(
              padding: EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _currentIndex > 0
                      ? TextButton.icon(
                          onPressed: _prevStep,
                          icon: Icon(Icons.arrow_back_ios, size: 16, color: Theme.of(context).colorScheme.onSurface),
                          label: Text('Back', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                        )
                      : SizedBox(width: 80),
                  _currentIndex < totalSteps - 1
                      ? FilledButton.icon(
                          onPressed: _nextStep,
                          icon: Icon(Icons.arrow_forward_ios, size: 16),
                          label: Text('Next Step', style: TextStyle(fontSize: 16)),
                          style: FilledButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                        )
                      : FilledButton.icon(
                          onPressed: _finishCooking,
                          icon: Icon(Icons.check_circle, size: 20),
                          label: Text('Finish Cooking',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          style: FilledButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.tertiary,
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrepNotesScreen() {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        title: Text(widget.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Text('🔪', style: TextStyle(fontSize: 28)),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Prep Before You Start',
                            style: TextStyle(color: Colors.orange, fontSize: 20, fontWeight: FontWeight.w700)),
                          SizedBox(height: 4),
                          Text('Mise en place — prepare everything first!',
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54), fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Ingredients overview
              if (widget.ingredients != null && widget.ingredients!.isNotEmpty) ...[
                Text('📋 Ingredients needed:',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 14, fontWeight: FontWeight.w600)),
                SizedBox(height: 8),
                ...widget.ingredients!.take(8).map((ing) {
                  final name = ing['display_name_en'] ?? ing['ingredient_name'] ?? '';
                  final qty = ing['quantity']?.toString() ?? '';
                  final unit = ing['unit'] ?? '';
                  return Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Text('  • $qty $unit $name',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 13)),
                  );
                }),
                if (widget.ingredients!.length > 8)
                  Text('  ... and ${widget.ingredients!.length - 8} more',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 13)),
                SizedBox(height: 16),
              ],

              // Prep notes
              if (widget.prepNotes != null)
                ...widget.prepNotes!.map((note) => Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('✓ ', style: TextStyle(color: Colors.orange, fontSize: 16)),
                      Expanded(
                        child: Text(note,
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85), fontSize: 15, height: 1.5)),
                      ),
                    ],
                  ),
                )),

              Spacer(),

              // Start button
              FilledButton.icon(
                onPressed: () => setState(() => _showPrepNotes = false),
                icon: Icon(Icons.restaurant, size: 20),
                label: Text('Start Cooking →', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding: EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Step Detail Card (Human-First Tutorial) ─────────────────────────

class _CookingStepCard extends StatefulWidget {
  final Map<String, dynamic> step;
  final int stepIndex;
  final int? timerRemaining;
  final void Function(int seconds) onStartTimer;

  const _CookingStepCard({
    required this.step,
    required this.stepIndex,
    this.timerRemaining,
    required this.onStartTimer,
  });

  @override
  State<_CookingStepCard> createState() => _CookingStepCardState();
}

class _CookingStepCardState extends State<_CookingStepCard> {
  final ApiService _api = ApiService();
  String? _aiTip;
  bool _aiLoading = false;
  bool _autoStartTriggered = false;

  int? get _timerSeconds {
    // Prefer new timer_seconds field, fall back to estimated_seconds or robot_action
    final ts = widget.step['timer_seconds'];
    if (ts != null && ts is int && ts > 0) return ts;
    final est = widget.step['estimated_seconds'];
    if (est != null && est is int && est > 0) return est;
    // Try robot_action minutes
    final robot = widget.step['robot_action'];
    if (robot is Map && robot['minutes'] != null) {
      return ((robot['minutes'] as num) * 60).toInt();
    }
    return null;
  }

  bool get _isAutoStart {
    return widget.step['timer_auto_start'] == true;
  }

  @override
  void initState() {
    super.initState();
    // Auto-start timer if flagged
    if (_isAutoStart && _timerSeconds != null && !_autoStartTriggered) {
      _autoStartTriggered = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onStartTimer(_timerSeconds!);
      });
    }
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m > 0) return '${m}m ${s.toString().padLeft(2, '0')}s';
    return '${s}s';
  }

  IconData _pickIcon(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('heat') || lower.contains('boil') || lower.contains('simmer')) {
      return Icons.local_fire_department;
    }
    if (lower.contains('cut') || lower.contains('chop') || lower.contains('dice') || lower.contains('slice')) {
      return Icons.content_cut;
    }
    if (lower.contains('mix') || lower.contains('stir') || lower.contains('whisk') || lower.contains('knead')) {
      return Icons.blender;
    }
    if (lower.contains('bake') || lower.contains('oven') || lower.contains('preheat')) {
      return Icons.microwave;
    }
    if (lower.contains('fry') || lower.contains('saute') || lower.contains('sear') || lower.contains('pan')) {
      return Icons.lunch_dining;
    }
    if (lower.contains('serve') || lower.contains('plate') || lower.contains('garnish')) {
      return Icons.room_service;
    }
    if (lower.contains('wash') || lower.contains('rinse') || lower.contains('soak') || lower.contains('drain')) {
      return Icons.water_drop;
    }
    if (lower.contains('season') || lower.contains('salt') || lower.contains('spice')) {
      return Icons.spa;
    }
    if (lower.contains('cool') || lower.contains('chill') || lower.contains('rest') || lower.contains('proof')) {
      return Icons.ac_unit;
    }
    if (lower.contains('shape') || lower.contains('roll') || lower.contains('fold') || lower.contains('press')) {
      return Icons.pan_tool;
    }
    if (lower.contains('steam')) return Icons.cloud;
    if (lower.contains('pour') || lower.contains('add water')) return Icons.local_drink;
    return Icons.restaurant;
  }

  Future<void> _askAi() async {
    if (_aiLoading || _aiTip != null) return;
    setState(() => _aiLoading = true);
    try {
      final result = await _api.getCookingTip(
        stepText: widget.step['human_text'] ?? '',
      );
      final tip = result['data']?['tip'] ?? '';
      if (mounted) {
        setState(() {
          _aiTip = tip.isEmpty ? 'No tip available for this step.' : tip;
          _aiLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _aiTip = 'Could not reach AI. Is Ollama running?';
          _aiLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final humanText = widget.step['human_text'] ?? '';
    final requiresAttention = widget.step['requires_attention'] == true;
    final icon = _pickIcon(humanText);
    final tempC = widget.step['temperature_c'];
    final timerSec = _timerSeconds;
    final isTimerRunning = widget.timerRemaining != null;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cooking Illustration Area
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05)),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 72,
                      color: (requiresAttention ? Colors.orange : Theme.of(context).colorScheme.primary)
                          .withValues(alpha: 0.3)),
                    if (requiresAttention) ...[
                      SizedBox(height: 12),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('👀 Needs Your Attention',
                          style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
                    ],
                    if (tempC != null && tempC is int) ...[
                      SizedBox(height: 12),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('🌡️ $tempC°C',
                          style: TextStyle(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 20),

          // Core Instruction
          Text(humanText,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.w700, height: 1.5)),
          SizedBox(height: 16),

          // Interactive Timer Button
          if (timerSec != null && timerSec > 0)
            GestureDetector(
              onTap: isTimerRunning ? null : () => widget.onStartTimer(timerSec),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: isTimerRunning
                      ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
                      : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isTimerRunning
                        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.4)
                        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isTimerRunning ? Icons.timer : Icons.play_circle_fill,
                      color: isTimerRunning ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      size: 24),
                    SizedBox(width: 12),
                    Text(
                      isTimerRunning
                          ? _formatTime(widget.timerRemaining!)
                          : '${_isAutoStart ? '⚡ Auto' : 'Start'} Timer • ${_formatTime(timerSec)}',
                      style: TextStyle(
                        color: isTimerRunning ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        fontSize: 18, fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()]),
                    ),
                    if (widget.timerRemaining != null && widget.timerRemaining! <= 0) ...[
                      SizedBox(width: 12),
                      Icon(Icons.check_circle, color: Theme.of(context).colorScheme.tertiary, size: 22),
                    ],
                  ],
                ),
              ),
            ),

          // AI Tip Section
          SizedBox(height: 12),
          if (_aiTip != null)
            Container(
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.auto_awesome, color: Theme.of(context).colorScheme.primary, size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(_aiTip!,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85), fontSize: 14, height: 1.5)),
                  ),
                ],
              ),
            )
          else
            GestureDetector(
              onTap: _askAi,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: _aiLoading
                      ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                      : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _aiLoading
                        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
                        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_aiLoading) ...[
                      SizedBox(width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.primary)),
                      SizedBox(width: 10),
                      Text('Thinking...',
                        style: TextStyle(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8), fontSize: 14, fontWeight: FontWeight.w600)),
                    ] else ...[
                      Icon(Icons.auto_awesome, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), size: 18),
                      SizedBox(width: 8),
                      Text('💡 Ask AI for a tip',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 14, fontWeight: FontWeight.w600)),
                    ],
                  ],
                ),
              ),
            ),

          Spacer(),
        ],
      ),
    );
  }
}
