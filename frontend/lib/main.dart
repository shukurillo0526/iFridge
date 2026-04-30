// I-Fridge — Application Entry Point
// "Zero-Waste, Maximum Taste."
//
// Dual-mode app: ORDER (eat out) and COOK (cook at home).
// The bottom navigation changes dynamically based on the active mode.

import 'package:ifridge_app/core/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:ifridge_app/core/theme/app_theme.dart';
import 'package:ifridge_app/core/services/app_settings.dart';
import 'package:ifridge_app/core/widgets/mode_switch.dart';
import 'package:ifridge_app/core/widgets/dual_mode_nav_bar.dart';

// ── Screens ──────────────────────────────────────────────
// Cook mode screens (existing)
import 'package:ifridge_app/features/shelf/presentation/screens/living_shelf_screen.dart';
import 'package:ifridge_app/features/cook/presentation/screens/cook_screen.dart';
import 'package:ifridge_app/features/scan/presentation/screens/scan_screen.dart';
import 'package:ifridge_app/features/explore/presentation/screens/explore_screen.dart';
import 'package:ifridge_app/features/profile/presentation/screens/profile_screen.dart';

// Order mode screens (new)
import 'package:ifridge_app/features/order/presentation/screens/order_screen.dart';
import 'package:ifridge_app/features/order/presentation/screens/order_feeds_screen.dart';

// Auth
import 'package:ifridge_app/features/auth/presentation/screens/auth_screen.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ifridge_app/l10n/app_localizations.dart';
import 'package:ifridge_app/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:ifridge_app/core/services/cache_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Global Error Handling ──
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('[Error] ${details.exceptionAsString()}');
  };

  // ── Supabase Configuration ──
  // Pass via: --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
  const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://tquyodwsyppwbpvkaunn.supabase.co',
  );
  const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRxdXlvZHdzeXBwd2JwdmthdW5uIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE1NzEzOTAsImV4cCI6MjA4NzE0NzM5MH0.1o6RYfeL_7YlIeUkl4jFsCm2JCQ2mB2F9o5wLv30xWU',
  );

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  await AppSettings().init();
  await LocationService().init();
  // Initialize offline cache (Hive)
  try {
    final cacheService = CacheService();
    await cacheService.initialize();
  } catch (e) {
    debugPrint('[Main] Cache init skipped: $e');
  }
  runApp(const ProviderScope(child: IFridgeApp()));
}

class IFridgeApp extends StatefulWidget {
  const IFridgeApp({super.key});

  @override
  State<IFridgeApp> createState() => _IFridgeAppState();
}

class _IFridgeAppState extends State<IFridgeApp> {
  final AppSettings _settings = AppSettings();

  @override
  void initState() {
    super.initState();
    _settings.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    _settings.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iFridge',
      debugShowCheckedModeBanner: false,
      theme: IFridgeTheme.lightTheme,
      darkTheme: IFridgeTheme.darkTheme,
      themeMode: _settings.themeMode,
      locale: _settings.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ko'),
        Locale('uz'),
        Locale('ru'),
      ],
      builder: (context, child) {
        // Override ugly red error screen
        ErrorWidget.builder = (details) => Center(
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: IFridgeTheme.bgElevated,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: IFridgeTheme.error.withValues(alpha: 0.3)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.warning_amber_rounded, color: IFridgeTheme.error.withValues(alpha: 0.7), size: 40),
                const SizedBox(height: 12),
                const Text('Something went wrong',
                    style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(details.exceptionAsString().split('\n').first,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 12),
                    textAlign: TextAlign.center, maxLines: 3, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        );
        return child ?? const SizedBox.shrink();
      },
      home: const _AuthGate(),
    );
  }
}

/// Auth gate — routes to AuthScreen, OnboardingScreen, or AppShell.
class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  bool? _onboardingComplete;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _onboardingComplete = prefs.getBool('onboarding_complete') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = Supabase.instance.client.auth.currentSession;
        if (session == null) {
          return const AuthScreen();
        }
        // Show onboarding for first-time users
        if (_onboardingComplete == false) {
          return OnboardingScreen(
            onComplete: () => setState(() => _onboardingComplete = true),
          );
        }
        return const AppShell();
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  APP SHELL — Dual-Mode Navigation
// ═══════════════════════════════════════════════════════════════════

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with TickerProviderStateMixin {
  final AppSettings _settings = AppSettings();
  int _currentIndex = 0;

  // ── Cook mode screens ──────────────────────────────
  static const List<Widget> _cookScreens = [
    LivingShelfScreen(),   // Inventory
    CookScreen(),          // Recipe
    ScanScreen(),          // Scan (center)
    ProfileScreen(),       // Management
  ];

  // ── Order mode screens ─────────────────────────────
  static const List<Widget> _orderScreens = [
    OrderScreen(),         // Order
    OrderFeedsScreen(),    // Feeds (center)
    ProfileScreen(),       // Management
  ];

  // ── Cook mode nav items ────────────────────────────
  List<NavItem> _cookNavItems(AppLocalizations? l10n) => [
    NavItem(
      icon: Icons.kitchen_outlined,
      activeIcon: Icons.kitchen,
      label: l10n?.tabShelf ?? 'Inventory',
    ),
    NavItem(
      icon: Icons.restaurant_menu_outlined,
      activeIcon: Icons.restaurant_menu,
      label: l10n?.tabCook ?? 'Recipe',
    ),
    NavItem(
      icon: Icons.center_focus_strong_outlined,
      activeIcon: Icons.center_focus_strong,
      label: l10n?.tabScan ?? 'Scan',
      isCenter: true,
    ),
    NavItem(
      icon: Icons.grid_view_outlined,
      activeIcon: Icons.grid_view,
      label: 'Manage',
    ),
  ];

  // ── Order mode nav items ───────────────────────────
  List<NavItem> _orderNavItems(AppLocalizations? l10n) => [
    NavItem(
      icon: Icons.storefront_outlined,
      activeIcon: Icons.storefront,
      label: 'Order',
    ),
    NavItem(
      icon: Icons.play_circle_outline,
      activeIcon: Icons.play_circle_filled,
      label: 'Feeds',
      isCenter: true,
    ),
    NavItem(
      icon: Icons.grid_view_outlined,
      activeIcon: Icons.grid_view,
      label: 'Manage',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _settings.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    _settings.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    // Reset tab index if mode changed and index is out of bounds
    final maxIndex = _settings.appMode == AppMode.cook
        ? _cookScreens.length - 1
        : _orderScreens.length - 1;
    if (_currentIndex > maxIndex) {
      _currentIndex = 0;
    }
    setState(() {});
  }

  void _switchMode(AppMode mode) {
    if (_settings.appMode == mode) return;
    _currentIndex = 0; // Reset to first tab on mode switch
    _settings.setAppMode(mode);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const isCook = true; // MVP: Always force Cook mode
    final screens = _cookScreens;
    final navItems = _cookNavItems(l10n);

    return Scaffold(
      body: Column(
        children: [
          // ── Mode Switch Bar ─────────────────────────
          _ModeSwitchBar(
            currentMode: _settings.appMode,
            onModeChanged: _switchMode,
          ),

          // ── Screen Content ──────────────────────────
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: child,
              ),
              child: KeyedSubtree(
                key: ValueKey('${AppMode.cook}_$_currentIndex'),
                child: screens[_currentIndex],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: DualModeNavBar(
        currentIndex: _currentIndex,
        items: navItems,
        mode: AppMode.cook,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

// ── Mode Switch Bar (sits below status bar) ─────────────────────────

class _ModeSwitchBar extends StatelessWidget {
  final AppMode currentMode;
  final ValueChanged<AppMode> onModeChanged;

  const _ModeSwitchBar({
    required this.currentMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(16, topPadding + 8, 16, 8),
      decoration: BoxDecoration(
        color: isDark ? IFridgeTheme.bgDark : const Color(0xFFF6F8FA),
      ),
      child: Row(
        children: [
          // App name
          Text(
            'iFridge',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          // Mode toggle hidden for MVP
        ],
      ),
    );
  }
}
