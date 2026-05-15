// Plately — Tutorial Service
// ==============================
// Manages in-app tutorial state persistence using SharedPreferences.
// Tracks which tutorial flows have been completed so each is shown only once.

import 'package:shared_preferences/shared_preferences.dart';

class TutorialService {
  static final TutorialService _instance = TutorialService._();
  factory TutorialService() => _instance;
  TutorialService._();

  static const _prefix = 'tutorial_';

  /// Check if a specific tutorial has been completed.
  Future<bool> isCompleted(String tutorialId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_prefix$tutorialId') ?? false;
  }

  /// Mark a tutorial as completed.
  Future<void> markCompleted(String tutorialId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_prefix$tutorialId', true);
  }

  /// Reset a specific tutorial (for debugging or re-showing).
  Future<void> reset(String tutorialId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefix$tutorialId');
  }

  /// Reset all tutorials.
  Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_prefix));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  // ── Tutorial IDs ──────────────────────────────────────────
  static const String homeWalkthrough = 'home_walkthrough';
  static const String firstRecipeView = 'first_recipe_view';
  static const String firstScan = 'first_scan';
}
