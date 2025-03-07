import 'package:flutter/material.dart';

ThemeData neoBrutalistTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: const Color(0xFFF8F1E9), // Eggshell
  colorScheme: const ColorScheme.light(
    surface: Color(0xFFF8F1E9), // Eggshell
    primary: Color(0xFFFF6B6B), // Coral
    secondary: Color(0xFF4ECDC4), // Punchy green
    inversePrimary: Color(0xFF4A5EBD), // Deep blue
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    titleLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: Color(0xFF8A4AF0), // Muted purple
    ),
  ),
);