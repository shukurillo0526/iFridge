/// I-Fridge — Design System & Theme
/// ==================================
/// Premium dual-mode theme with Terracotta Orange and Gold accents.
library;

import 'package:flutter/material.dart';

class AppTheme {
  // ── Dark Mode Colors ──
  static const Color darkBg = Color(0xFF0F1218);
  static const Color darkSurface = Color(0xFF1C212E);
  static const Color darkPrimary = Color(0xFFE07A00);
  static const Color darkSecondary = Color(0xFFF4B942); // Accent / Gold
  static const Color darkTertiary = Color(0xFF00C48C);  // Success
  static const Color darkTextPrimary = Color(0xFFF8F9FA);
  static const Color darkTextSecondary = Color(0xFFA1A8B8);

  // ── Light Mode Colors ──
  static const Color lightBg = Color(0xFFF8F6F2);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightPrimary = Color(0xFFD96B00);
  static const Color lightSecondary = Color(0xFFC89A2F); // Accent / Gold
  static const Color lightTertiary = Color(0xFF00A36C);  // Success
  static const Color lightTextPrimary = Color(0xFF1F252C);
  static const Color lightTextSecondary = Color(0xFF5B6370);

  // ── Shared Colors ──
  static const Color error = Color(0xFFFF1744); // Critical / Error
  
  // --- Freshness States ---
  static const Color freshGreen = Color(0xFF2EA043);
  static const Color agingAmber = Color(0xFFF0883E);
  static const Color urgentOrange = Color(0xFFDB6D28);
  static const Color criticalRed = Color(0xFFDA3633);
  static const Color expiredGrey = Color(0xFF484F58);

  // --- Tier Badge Colors ---
  static const Color tier1 = Color(0xFF2EA043);          // Full match comfort
  static const Color tier2 = Color(0xFF1F6FEB);          // Full match discovery
  static const Color tier3 = Color(0xFFF0883E);          // Minor shop comfort
  static const Color tier4 = Color(0xFFBC8CFF);          // Minor shop discovery
  static const Color tier5 = Color(0xFF8B949E);          // Global search

  // ── Theme Definitions ──

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      fontFamily: 'Inter',
      
      colorScheme: const ColorScheme.dark(
        primary: darkPrimary,
        secondary: darkSecondary,
        tertiary: darkTertiary,
        error: error,
        surface: darkSurface,
        onPrimary: Colors.white,
        onSecondary: darkTextPrimary,
        onSurface: darkTextPrimary,
        onError: Colors.white,
        surfaceContainerHighest: Color(0xFF21262D),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: darkBg,
        foregroundColor: darkTextPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: darkTextPrimary,
          letterSpacing: -0.5,
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: darkPrimary,
        unselectedItemColor: darkTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white24),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: darkPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),

      chipTheme: const ChipThemeData(
        backgroundColor: Color(0xFF21262D),
        labelStyle: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w500),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        hintStyle: TextStyle(color: darkTextSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white24),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkPrimary, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBg,
      fontFamily: 'Inter',
      
      colorScheme: const ColorScheme.light(
        primary: lightPrimary,
        secondary: lightSecondary,
        tertiary: lightTertiary,
        error: error,
        surface: lightSurface,
        onPrimary: Colors.white,
        onSecondary: lightTextPrimary,
        onSurface: lightTextPrimary,
        onError: Colors.white,
        surfaceContainerHighest: Color(0xFFE5E7EB),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: lightBg,
        foregroundColor: lightTextPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: lightTextPrimary,
          letterSpacing: -0.5,
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: lightSurface,
        selectedItemColor: lightPrimary,
        unselectedItemColor: lightTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.black12),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: lightPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),

      chipTheme: const ChipThemeData(
        backgroundColor: Color(0xFFE5E7EB),
        labelStyle: TextStyle(color: lightTextPrimary, fontWeight: FontWeight.w500),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurface,
        hintStyle: TextStyle(color: lightTextSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lightPrimary, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
