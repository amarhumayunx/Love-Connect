import 'package:flutter/material.dart';

class AppColors {
  // Design System Colors (from Case Study 4)
  static const Color primaryDark = Color(0xFF96435D); // Dark reddish-brown
  static const Color primaryLight = Color(0xFFD892A1); // Light dusty rose pink
  static const Color primaryRed = Color(0xFFE5364B); // Vibrant red
  static const Color white = Color(0xFFFFFFFF); // White

  // Background Colors
  static const Color backgroundPink = Color(0xFFFCE4EC); // Light pink background
  static const Color backgroundGradientStart = Color(0xFFFCE4EC);
  static const Color backgroundGradientEnd = Color(0xFFFCE4EC);

  // Text Colors
  static const Color textDarkPink = Color(0xFF96435D);
  static const Color textLightPink = Color(0xFFD892A1);
  static const Color textWhite = Colors.white;
  static const Color hinttext = Color(0xFFD892A1);

  // UI Elements
  static const Color backArrow = Color(0xFF96435D);
  static const Color textFieldBorder = Color(0xFFD892A1);

  static const Color IdeaColorText = Color(0xFFEF95A9);

  // Surfaces
  static const Color translucentWhite30 = Color(0x4DFFFFFF);
  static const Color translucentWhite12 = Color(0x1FFFFFFF);

  // Accent & Decorative (kept for compatibility)
  static const Color accentPeach = Color(0xFFD892A1);
  static const Color accentLilac = Color(0xFFC7A0FF);
  static const Color accentWarmYellow = Color(0xFFFFDF91);

  // Private constructor to prevent instantiation
  AppColors._();
}
