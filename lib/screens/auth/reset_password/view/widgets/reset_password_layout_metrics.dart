import 'package:flutter/material.dart';

class ResetPasswordLayoutMetrics {
  final double horizontalPadding;
  final double topPadding;
  final double spacingLarge;
  final double spacingSmall;
  final double spacingMedium;
  final double titleFontSize;
  final double subtitleFontSize;
  final double buttonHeight;

  const ResetPasswordLayoutMetrics({
    required this.horizontalPadding,
    required this.topPadding,
    required this.spacingLarge,
    required this.spacingSmall,
    required this.spacingMedium,
    required this.titleFontSize,
    required this.subtitleFontSize,
    required this.buttonHeight,
  });

  factory ResetPasswordLayoutMetrics.fromContext(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenHeight = size.height;
    final screenWidth = size.width;

    return ResetPasswordLayoutMetrics(
      horizontalPadding: screenWidth * 0.05,
      topPadding: screenHeight * 0.01,
      spacingLarge: screenHeight * 0.032,
      spacingSmall: screenHeight * 0.010,
      spacingMedium: screenHeight * 0.020,
      titleFontSize: screenWidth * 0.075,
      subtitleFontSize: screenWidth * 0.036,
      buttonHeight: (screenHeight * 0.065).clamp(50.0, 65.0),
    );
  }
}

