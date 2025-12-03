import 'package:flutter/material.dart';

const Color primaryGreen = Color(0xFF53FC18);

ThemeData appTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.black,
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: primaryGreen,
      secondary: primaryGreen,
    ),
    // Removed cardTheme due to version mismatch causing type error.
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: primaryGreen,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
  );
}
