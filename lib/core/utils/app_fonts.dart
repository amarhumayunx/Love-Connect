import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A utility class that wraps Google Fonts with error handling.
/// Falls back to system fonts when network requests fail (e.g., on iOS simulators with network issues).
class AppFonts {
  /// Get Inter font with error handling
  /// Falls back to system font if Google Fonts fails to load
  static TextStyle inter({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
    FontStyle? fontStyle,
    TextDecoration? decoration,
  }) {
    try {
      return GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
        fontStyle: fontStyle,
        decoration: decoration,
      );
    } catch (e) {
      // Fallback to system font if Google Fonts fails
      return TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
        fontStyle: fontStyle,
        decoration: decoration,
        fontFamily: Platform.isIOS ? '.SF Pro Text' : 'Roboto',
      );
    }
  }

  /// Get Poppins font with error handling
  /// Falls back to system font if Google Fonts fails to load
  static TextStyle poppins({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
    FontStyle? fontStyle,
    TextDecoration? decoration,
  }) {
    try {
      return GoogleFonts.poppins(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
        fontStyle: fontStyle,
        decoration: decoration,
      );
    } catch (e) {
      // Fallback to system font if Google Fonts fails
      return TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
        fontStyle: fontStyle,
        decoration: decoration,
        fontFamily: Platform.isIOS ? '.SF Pro Text' : 'Roboto',
      );
    }
  }

  /// Get Inter font family name with error handling
  static String? interFontFamily() {
    try {
      return GoogleFonts.inter().fontFamily;
    } catch (e) {
      return Platform.isIOS ? '.SF Pro Text' : 'Roboto';
    }
  }

  /// Get Poppins font family name with error handling
  static String? poppinsFontFamily() {
    try {
      return GoogleFonts.poppins().fontFamily;
    } catch (e) {
      return Platform.isIOS ? '.SF Pro Text' : 'Roboto';
    }
  }
}

