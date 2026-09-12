import 'package:flutter/material.dart';

import 'app_colors.dart';

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  scaffoldBackgroundColor: const Color(0xffF8FAFC),

  colorScheme: const ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    surface: Colors.white,
    error: AppColors.danger,
    onPrimary: AppColors.white,
    onSecondary: Colors.black,
    onSurface: Color(0xff0F172A),
    onError: AppColors.white,
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Color(0xff0F172A),
    elevation: 0,
    centerTitle: true,
  ),

  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 1,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),

  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Color(0xff0F172A)),
    bodyMedium: TextStyle(color: Color(0xff0F172A)),
    titleLarge: TextStyle(color: Color(0xff0F172A), fontWeight: FontWeight.bold),
    titleMedium: TextStyle(color: Color(0xff0F172A), fontWeight: FontWeight.w600),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xffF1F5F9),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    hintStyle: TextStyle(color: const Color(0xff0F172A).withOpacity(0.4)),
  ),

  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: Colors.grey,
  ),

  snackBarTheme: SnackBarThemeData(
    backgroundColor: const Color(0xff0F172A),
    contentTextStyle: const TextStyle(color: AppColors.white),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),

  dividerColor: const Color(0xff0F172A).withOpacity(0.08),
);