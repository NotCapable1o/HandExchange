import 'package:flutter/material.dart';

class AppThemes {
  static const Color primaryBlue = Color(0xFF22A3FF);
  static const Color accentIndigo = Color(0xFF6366F1);
  static const Color darkSlate = Color(0xFF0F172A);
  static const Color textBlack = Color(0xFF1E293B);

  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: const ColorScheme.light(
      primary: primaryBlue,
      secondary: accentIndigo,
      surface: Colors.white,
      onSurface: textBlack,
      onPrimary: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: textBlack,
      elevation: 0,
      centerTitle: true,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Color(0xFFF1F5F9),
      selectedColor: accentIndigo,
      labelStyle: const TextStyle(color: textBlack),
      secondaryLabelStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white70,
    ),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkSlate,
    colorScheme: const ColorScheme.dark(
      primary: primaryBlue,
      secondary: accentIndigo,
      surface: Color(0xFF1E293B),
      onSurface: Colors.white,
      onPrimary: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkSlate,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Color(0xFF334155),
      selectedColor: accentIndigo,
      labelStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.black26,
    ),
  );
}

class AppColors {
  static const darkGradient = [Color(0xFF12141D), Color(0xFF1C1F2E)];

  static const lightGradient = [Color(0xFFF8FAFF), Color(0xFFFFFFFF)];

  static const primaryBlue = Color(0xFF4A90E2);
  static const accentBlue = Color(0xFF00D2FF);
  static const glassDark = Color(0x1AFFFFFF);
}
