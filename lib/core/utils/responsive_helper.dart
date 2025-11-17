import 'package:flutter/material.dart';

/// Responsive helper class to handle different screen sizes
/// Works for all Android and iOS devices
class ResponsiveHelper {
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Get responsive width based on screen width percentage
  static double width(BuildContext context, double percentage) {
    return screenWidth(context) * (percentage / 100);
  }

  /// Get responsive height based on screen height percentage
  static double height(BuildContext context, double percentage) {
    return screenHeight(context) * (percentage / 100);
  }

  /// Get responsive font size that scales with screen size
  static double fontSize(BuildContext context, double baseSize) {
    final width = screenWidth(context);
    // Base width is 375 (iPhone X standard)
    // Scale factor for different screen sizes
    if (width < 360) {
      // Small phones
      return baseSize * 0.85;
    } else if (width < 414) {
      // Medium phones
      return baseSize;
    } else if (width < 768) {
      // Large phones / small tablets
      return baseSize * 1.1;
    } else {
      // Tablets
      return baseSize * 1.3;
    }
  }

  /// Get responsive padding that scales with screen size
  static EdgeInsets padding(BuildContext context, {
    double? horizontal,
    double? vertical,
    double? all,
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    final width = screenWidth(context);
    
    // Scale factor based on screen size
    double scaleFactor = 1.0;
    if (width < 360) {
      scaleFactor = 0.85; // Small phones
    } else if (width > 768) {
      scaleFactor = 1.2; // Tablets
    }

    return EdgeInsets.only(
      left: (left ?? all ?? horizontal ?? 0) * scaleFactor,
      right: (right ?? all ?? horizontal ?? 0) * scaleFactor,
      top: (top ?? all ?? vertical ?? 0) * scaleFactor,
      bottom: (bottom ?? all ?? vertical ?? 0) * scaleFactor,
    );
  }

  /// Get responsive size for images/icons that scales with screen size
  static double imageSize(BuildContext context, double baseSize) {
    final width = screenWidth(context);
    final height = screenHeight(context);
    
    // Use the smaller dimension to ensure it fits on all screens
    final minDimension = width < height ? width : height;
    
    // Scale based on screen size
    if (minDimension < 360) {
      return baseSize * 0.7; // Small phones
    } else if (minDimension < 414) {
      return baseSize; // Standard phones
    } else if (minDimension < 768) {
      return baseSize * 1.2; // Large phones
    } else {
      return baseSize * 1.5; // Tablets
    }
  }

  /// Check if device is a tablet
  static bool isTablet(BuildContext context) {
    return screenWidth(context) >= 768;
  }

  /// Check if device is a small phone
  static bool isSmallPhone(BuildContext context) {
    return screenWidth(context) < 360;
  }

  /// Get responsive spacing that adapts to screen size
  static double spacing(BuildContext context, double baseSpacing) {
    final height = screenHeight(context);
    
    // Scale spacing based on screen height
    if (height < 600) {
      // Small screens (like iPhone SE)
      return baseSpacing * 0.7;
    } else if (height < 800) {
      // Standard phones
      return baseSpacing;
    } else if (height < 1200) {
      // Large phones
      return baseSpacing * 1.2;
    } else {
      // Tablets
      return baseSpacing * 1.5;
    }
  }

  /// Get safe area padding
  static EdgeInsets safeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Get responsive button height
  static double buttonHeight(BuildContext context) {
    final height = screenHeight(context);
    if (height < 600) {
      return 44; // Small screens
    } else if (height < 800) {
      return 48; // Standard screens
    } else {
      return 52; // Large screens
    }
  }
}

