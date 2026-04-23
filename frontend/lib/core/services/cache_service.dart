import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

/// Offline-first caching service using Hive.
///
/// Strategy:
///   1. Show cached data instantly on screen load
///   2. Fetch fresh data from network in background
///   3. Update cache + UI when fresh data arrives
///   4. Queue writes when offline → flush on reconnect
///
/// Boxes:
///   - 'inventory' — user's inventory items
///   - 'recipes' — recipe list with match data
///   - 'user_profile' — user profile, flavor, gamification
///   - 'sync_queue' — pending writes to flush when online
class CacheService {
  static final CacheService _instance = CacheService._();
  factory CacheService() => _instance;
  CacheService._();

  bool _initialized = false;
  late Box _inventoryBox;
  late Box _recipesBox;
  late Box _profileBox;
  late Box _syncQueueBox;
  late Box _metaBox;

  final _connectivityController = StreamController<bool>.broadcast();
  Stream<bool> get onConnectivityChange => _connectivityController.stream;

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  /// Initialize Hive and open all cache boxes.
  /// Call this once in main() before runApp().
  Future<void> initialize() async {
    if (_initialized) return;

    await Hive.initFlutter();

    _inventoryBox = await Hive.openBox('inventory');
    _recipesBox = await Hive.openBox('recipes');
    _profileBox = await Hive.openBox('user_profile');
    _syncQueueBox = await Hive.openBox('sync_queue');
    _metaBox = await Hive.openBox('cache_meta');

    _initialized = true;
    debugPrint('[Cache] Initialized — ${_inventoryBox.length} inventory, ${_recipesBox.length} recipes cached');

    // Monitor connectivity
    Connectivity().onConnectivityChanged.listen((results) {
      final wasOffline = !_isOnline;
      _isOnline = results.any((r) => r != ConnectivityResult.none);
      _connectivityController.add(_isOnline);

      if (wasOffline && _isOnline) {
        debugPrint('[Cache] Back online — flushing sync queue');
        flushSyncQueue();
      }
    });

    // Check initial connectivity
    final result = await Connectivity().checkConnectivity();
    _isOnline = result.any((r) => r != ConnectivityResult.none);
  }

  // ── Inventory Cache ────────────────────────────────────────────

  /// Get cached inventory items for a user.
  List<Map<String, dynamic>>? getInventory(String userId) {
    final raw = _inventoryBox.get('inventory_$userId');
    if (raw == null) return null;
    return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  }

  /// Cache inventory items.
  Future<void> setInventory(String userId, List<dynamic> items) async {
    await _inventoryBox.put('inventory_$userId', jsonEncode(items));
    await _metaBox.put('inventory_${userId}_ts', DateTime.now().toIso8601String());
  }

  /// Check if inventory cache is stale (older than maxAge).
  bool isInventoryStale(String userId, {Duration maxAge = const Duration(minutes: 5)}) {
    final ts = _metaBox.get('inventory_${userId}_ts');
    if (ts == null) return true;
    final cached = DateTime.parse(ts);
    return DateTime.now().difference(cached) > maxAge;
  }

  // ── Recipes Cache ─────────────────────────────────────────────

  /// Get cached recipes.
  List<Map<String, dynamic>>? getRecipes(String userId) {
    final raw = _recipesBox.get('recipes_$userId');
    if (raw == null) return null;
    return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  }

  /// Cache recipes.
  Future<void> setRecipes(String userId, List<dynamic> recipes) async {
    await _recipesBox.put('recipes_$userId', jsonEncode(recipes));
    await _metaBox.put('recipes_${userId}_ts', DateTime.now().toIso8601String());
  }

  bool isRecipesStale(String userId, {Duration maxAge = const Duration(minutes: 15)}) {
    final ts = _metaBox.get('recipes_${userId}_ts');
    if (ts == null) return true;
    return DateTime.now().difference(DateTime.parse(ts)) > maxAge;
  }

  // ── User Profile Cache ────────────────────────────────────────

  /// Get cached user profile.
  Map<String, dynamic>? getProfile(String userId) {
    final raw = _profileBox.get('profile_$userId');
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  /// Cache user profile.
  Future<void> setProfile(String userId, Map<String, dynamic> profile) async {
    await _profileBox.put('profile_$userId', jsonEncode(profile));
  }

  // ── Offline Write Queue ───────────────────────────────────────

  /// Queue a write operation for later sync.
  /// Used when the user modifies data while offline.
  Future<void> queueWrite({
    required String endpoint,
    required String method,
    required Map<String, dynamic> body,
  }) async {
    final queue = _getQueue();
    queue.add({
      'endpoint': endpoint,
      'method': method,
      'body': body,
      'queued_at': DateTime.now().toIso8601String(),
    });
    await _syncQueueBox.put('queue', jsonEncode(queue));
    debugPrint('[Cache] Queued offline write: $method $endpoint');
  }

  /// Get the number of pending sync operations.
  int get pendingSyncCount => _getQueue().length;

  /// Flush all queued writes to the server.
  /// Called automatically when connectivity is restored.
  Future<void> flushSyncQueue() async {
    final queue = _getQueue();
    if (queue.isEmpty) return;

    debugPrint('[Cache] Flushing ${queue.length} queued writes...');
    final failed = <Map<String, dynamic>>[];

    for (final item in queue) {
      try {
        // The actual HTTP calls would be made here via ApiService
        // For now, we just log them — the caller should handle this
        debugPrint('[Cache] Syncing: ${item['method']} ${item['endpoint']}');
        // TODO: Wire to ApiService.syncOfflineWrite()
      } catch (e) {
        debugPrint('[Cache] Sync failed: $e');
        failed.add(item);
      }
    }

    await _syncQueueBox.put('queue', jsonEncode(failed));
    debugPrint('[Cache] Flush complete — ${failed.length} remaining');
  }

  List<Map<String, dynamic>> _getQueue() {
    final raw = _syncQueueBox.get('queue');
    if (raw == null) return [];
    return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  }

  // ── Cache Management ──────────────────────────────────────────

  /// Clear all cached data (e.g., on logout).
  Future<void> clearAll() async {
    await _inventoryBox.clear();
    await _recipesBox.clear();
    await _profileBox.clear();
    await _syncQueueBox.clear();
    await _metaBox.clear();
    debugPrint('[Cache] All caches cleared');
  }

  /// Get cache statistics for debugging.
  Map<String, dynamic> get stats => {
    'inventory_entries': _inventoryBox.length,
    'recipes_entries': _recipesBox.length,
    'profiles_entries': _profileBox.length,
    'pending_syncs': pendingSyncCount,
    'is_online': _isOnline,
  };
}
