import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFF3A7FEA),
  scaffoldBackgroundColor: Colors.white,

  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black87,
    elevation: 0.5,
    iconTheme: IconThemeData(color: Colors.black87),
  ),

  cardTheme: CardThemeData(
    color: Colors.white,
    shadowColor: Colors.grey.shade200,
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
    fillColor: const Color(0xFFF4F4F4),
    filled: true,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    hintStyle: const TextStyle(color: Colors.black45),
    floatingLabelStyle: const TextStyle(color: Color(0xFF3A7FEA)),
    prefixIconColor: Colors.grey,
    suffixIconColor: Colors.grey,
  ),

  textTheme: const TextTheme(
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    ),
    titleMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
    ),
    bodyLarge: TextStyle(color: Colors.black87),
    bodyMedium: TextStyle(color: Colors.black87),
    labelLarge: TextStyle(
      color: Colors.black87,
      fontWeight: FontWeight.w600,
    ),
  ),

  dialogTheme: DialogThemeData(
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  ),

  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Colors.white,
    modalBackgroundColor: Colors.white,
  ),
);
