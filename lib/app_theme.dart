import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryGreen = Color(0xFF53FC18);
  static const Color primaryBlack = Colors.black;

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryGreen,
    scaffoldBackgroundColor: primaryBlack,
    colorScheme: ColorScheme.fromSwatch(
      brightness: Brightness.dark,
      primarySwatch: MaterialColor(0xFF53FC18, <int, Color>{
        50: Color(0xFFE6FEE0),
        100: Color(0xFFCCFDC2),
        200: Color(0xFF99FA85),
        300: Color(0xFF66F548),
        400: primaryGreen,
        500: primaryGreen,
        600: primaryGreen,
        700: primaryGreen,
        800: primaryGreen,
        900: primaryGreen,
      }),
    ).copyWith(secondary: primaryGreen),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryBlack,
      elevation: 0,
    ),
    floatingActionButtonTheme:
        const FloatingActionButtonThemeData(backgroundColor: primaryGreen),
  );
}
