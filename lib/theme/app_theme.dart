import 'package:flutter/material.dart';

class AppTheme {
  // --- Color Palette ---
  static const Color _darkBackground = Color(0xFF1A1A2E); 
  static const Color _primaryBlue = Color(0xFF00BFFF); 
  static const Color _accentGreen = Color(0xFF39FF14); 
  static const Color _lightGrey = Color(0xFFCCCCCC);
  static const Color _darkGrey = Color(0xFF33334A); 

  // --- Dark Theme Data ---
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _darkBackground,
      primaryColor: _primaryBlue,
      hintColor: _accentGreen, 
      colorScheme: const ColorScheme.dark(
        primary: _primaryBlue,
        secondary: _accentGreen,
        surface: _darkGrey, // Replaced 'background'
        onPrimary: Colors.black, 
        onSecondary: Colors.black, 
        onSurface: _lightGrey, // Replaced 'onBackground'
        error: Colors.redAccent,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent, // Replaced 'color'
        elevation: 0, 
        titleTextStyle: TextStyle(
          color: _lightGrey,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: _primaryBlue),
      ),
      cardTheme: CardThemeData( // Replaced 'CardTheme'
        color: _darkGrey,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: _primaryBlue, width: 0.5), 
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: _lightGrey),
        bodyMedium: TextStyle(color: _lightGrey),
        headlineLarge: TextStyle(color: _primaryBlue),
        headlineMedium: TextStyle(color: _lightGrey),
        titleLarge: TextStyle(color: _lightGrey),
        titleMedium: TextStyle(color: _lightGrey),
        labelLarge: TextStyle(color: _darkBackground), 
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: _primaryBlue,
        textTheme: ButtonTextTheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryBlue, 
          foregroundColor: _darkBackground, 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _accentGreen,
        foregroundColor: _darkBackground,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkGrey,
        labelStyle: const TextStyle(color: _lightGrey),
        hintStyle: const TextStyle(color: _lightGrey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _primaryBlue),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _primaryBlue, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _primaryBlue, width: 1.5),
        ),
      ),
    );
  }
}