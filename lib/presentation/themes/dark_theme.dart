import 'package:flutter/material.dart';

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xFF3A7FEA),
  scaffoldBackgroundColor: const Color(0xFF121212),

  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1E1E1E),
    foregroundColor: Colors.white,
    elevation: 0.5,
    iconTheme: IconThemeData(color: Colors.white),
  ),

  cardTheme: CardThemeData(
    color: const Color(0xFF1E1E1E),
    shadowColor: Colors.black54,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    elevation: 2,
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF3A7FEA),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      minimumSize: const Size(double.infinity, 50),
    ),
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF3A7FEA),
    foregroundColor: Colors.white,
  ),

  inputDecorationTheme: InputDecorationTheme(
    fillColor: const Color(0xFF2A2A2A),
    filled: true,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    hintStyle: const TextStyle(color: Colors.white54),
    floatingLabelStyle: const TextStyle(color: Color(0xFF3A7FEA)),
    prefixIconColor: Colors.grey,
    suffixIconColor: Colors.grey,
  ),

  textTheme: const TextTheme(
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    titleMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white70),
    labelLarge: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w600,
    ),
  ),

  dialogTheme: DialogThemeData(
    backgroundColor: const Color(0xFF1E1E1E),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  ),

  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Color(0xFF1E1E1E),
    modalBackgroundColor: Color(0xFF1E1E1E),
  ),
);
