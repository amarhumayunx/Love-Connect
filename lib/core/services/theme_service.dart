// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:love_connect/core/colors/app_colors.dart';

// /// Theme service for managing custom theme colors
// class ThemeService extends GetxController {
//   static const String _loveColorKey = 'love_color';
  
//   final Rx<LoveColor> loveColor = LoveColor.passionRed.obs;
  
//   @override
//   void onInit() {
//     super.onInit();
//     _loadThemePreferences();
//   }

//   /// Load theme preferences from storage
//   Future<void> _loadThemePreferences() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
      
//       // Load love color preference
//       final loveColorString = prefs.getString(_loveColorKey);
//       if (loveColorString != null) {
//         loveColor.value = LoveColor.values.firstWhere(
//           (color) => color.toString() == loveColorString,
//           orElse: () => LoveColor.passionRed,
//         );
//       }
//     } catch (e) {
//       // Use defaults if loading fails
//       loveColor.value = LoveColor.passionRed;
//     }
//   }

//   /// Save theme preferences to storage
//   Future<void> _saveThemePreferences() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString(_loveColorKey, loveColor.value.toString());
//     } catch (e) {
//       // Silently handle save errors
//     }
//   }

//   /// Set love color
//   Future<void> setLoveColor(LoveColor color) async {
//     loveColor.value = color;
//     await _saveThemePreferences();
//     Get.forceAppUpdate();
//   }

//   /// Get current accent color based on love color selection
//   Color get accentColor => loveColor.value.color;

//   /// Get primary color (uses love color)
//   Color get primaryColor => loveColor.value.color;
// }

// /// Available love colors for theming
// enum LoveColor {
//   passionRed,
//   deepBlue,
//   romanticPink,
//   sunsetOrange,
//   lavenderPurple,
//   emeraldGreen,
// }

// extension LoveColorExtension on LoveColor {
//   Color get color {
//     switch (this) {
//       case LoveColor.passionRed:
//         return const Color(0xFFE5364B); // Existing primary red
//       case LoveColor.deepBlue:
//         return const Color(0xFF1E3A8A); // Deep blue
//       case LoveColor.romanticPink:
//         return const Color(0xFFEC4899); // Romantic pink
//       case LoveColor.sunsetOrange:
//         return const Color(0xFFF97316); // Sunset orange
//       case LoveColor.lavenderPurple:
//         return const Color(0xFFA855F7); // Lavender purple
//       case LoveColor.emeraldGreen:
//         return const Color(0xFF10B981); // Emerald green
//     }
//   }

//   String get displayName {
//     switch (this) {
//       case LoveColor.passionRed:
//         return 'Passion Red';
//       case LoveColor.deepBlue:
//         return 'Deep Blue';
//       case LoveColor.romanticPink:
//         return 'Romantic Pink';
//       case LoveColor.sunsetOrange:
//         return 'Sunset Orange';
//       case LoveColor.lavenderPurple:
//         return 'Lavender Purple';
//       case LoveColor.emeraldGreen:
//         return 'Emerald Green';
//     }
//   }
// }
