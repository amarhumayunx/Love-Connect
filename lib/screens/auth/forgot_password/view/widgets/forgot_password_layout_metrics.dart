import 'package:flutter/material.dart';

class ForgotPasswordLayoutMetrics {
  final double horizontalPadding;
  final double topPadding;
  final double spacingLarge;
  final double spacingSmall;
  final double titleFontSize;
  final double subtitleFontSize;
  final double imageHeight;
  final double buttonHeight;

  const ForgotPasswordLayoutMetrics({
    required this.horizontalPadding,
    required this.topPadding,
    required this.spacingLarge,
    required this.spacingSmall,
    required this.titleFontSize,
    required this.subtitleFontSize,
    required this.imageHeight,
    required this.buttonHeight,
  });

  factory ForgotPasswordLayoutMetrics.fromContext(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenHeight = size.height;
    final screenWidth = size.width;

    return ForgotPasswordLayoutMetrics(
      horizontalPadding: screenWidth * 0.05,
      topPadding: screenHeight * 0.01,
      spacingLarge: screenHeight * 0.032,
      spacingSmall: screenHeight * 0.010,
      titleFontSize: screenWidth * 0.075,
      subtitleFontSize: screenWidth * 0.036,
      imageHeight: (screenHeight * 0.25).clamp(180.0, 250.0),
      buttonHeight: (screenHeight * 0.065).clamp(50.0, 65.0),
    );
  }
}
