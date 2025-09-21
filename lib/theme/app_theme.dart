import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // Define the core colors
  static const Color _accentOrange = Color(0xFFF0714A);
  static const Color _lightBackground = Color(0xFFF9F5F2);
  static const Color _darkBackground = Color(0xFF1E1E1E);
  static const Color _lightTextColor = Color(0xFF242424);
  static const Color _darkTextColor = Color(0xFFFFFFFF);

  // --- LIGHT THEME ---
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    scaffoldBackgroundColor: _lightBackground,
    textTheme: GoogleFonts.jetBrainsMonoTextTheme(
      ThemeData(brightness: Brightness.light).textTheme,
    ),
    colorScheme: const ColorScheme.light(
      primary: _accentOrange,
      onPrimary: Colors.white,
      background: _lightBackground,
      onBackground: _lightTextColor,
      surface: Colors.white,
      onSurface: _lightTextColor,
    ),
  );

  // --- DARK THEME ---
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: _darkBackground,
    textTheme: GoogleFonts.jetBrainsMonoTextTheme(
      ThemeData(brightness: Brightness.dark).textTheme.apply(
            bodyColor: _darkTextColor,
            displayColor: _darkTextColor,
          ),
    ),
    colorScheme: const ColorScheme.dark(
      primary: _accentOrange,
      onPrimary: Colors.white,
      background: _darkBackground,
      onBackground: _darkTextColor,
      surface: Color(0xFF2C2C2E),
      onSurface: _darkTextColor,
    ),
  );
}