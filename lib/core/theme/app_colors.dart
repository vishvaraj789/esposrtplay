import 'package:flutter/material.dart';

/// Single source of truth for colors. Screens should reference these tokens
/// instead of declaring private `_kXxx` consts or inline `Color(0x...)` values.
class AppColors {
  // ---- Theme palette (used by dark_theme.dart / light_theme.dart) ----
  static const primary = Color(0xff6C3CF0);
  static const secondary = Color(0xff00E5FF);

  static const backgroundDark = Color(0xff0F172A);
  static const surfaceDark = Color(0xff1E293B);

  static const success = Color(0xff22C55E);
  static const danger = Color(0xffEF4444);

  static const white = Colors.white;

  // ---- Dark UI surfaces used by most feature screens ----
  static const backgroundDeep = Color(0xFF0B0C12);
  static const card = Color(0xFF171821);
  static const chip = Color(0xFF1D1E29);
  static const hairline = Color(0xFF2A2C38);
  static const textSecondary = Color(0xFF9CA0AF);

  // ---- Accents ----
  static const orange = Color(0xFFFF6A3D);
  static const pink = Color(0xFFFF3D5A);
  static const gold = Color(0xFFFFC24B);
  static const green = Color(0xFF3DDC84);
  static const blue = Color(0xFF3DA9FC);
  static const purple = Color(0xFF8B5CF6);
  static const liveRed = Color(0xFFE23744);
  static const silver = Color(0xFFC0C6D4);
  static const bronze = Color(0xFFCD7F32);

  static const brandGradient = LinearGradient(
    colors: [orange, pink],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // ---- Light form fields (auth / profile screens) ----
  static const fieldLight = Color(0xFFF7F8FC);
  static const fieldLightDisabled = Color(0xFFEDEEF2);
}