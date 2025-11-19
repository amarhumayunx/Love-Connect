import 'package:flutter/material.dart';

class VerificationLayoutMetrics {
  final double horizontalPadding;
  final double topSpacing;
  final double titleSpacing;
  final double otpSpacing;
  final double buttonSpacing;
  final double titleFontSize;
  final double subtitleFontSize;

  const VerificationLayoutMetrics({
    required this.horizontalPadding,
    required this.topSpacing,
    required this.titleSpacing,
    required this.otpSpacing,
    required this.buttonSpacing,
    required this.titleFontSize,
    required this.subtitleFontSize,
  });

  factory VerificationLayoutMetrics.fromContext(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return VerificationLayoutMetrics(
      horizontalPadding: screenWidth * 0.05,
      topSpacing: screenHeight * 0.02,
      titleSpacing: screenHeight * 0.03,
      otpSpacing: screenHeight * 0.04,
      buttonSpacing: screenHeight * 0.035,
      titleFontSize: screenWidth * 0.07,
      subtitleFontSize: screenWidth * 0.038,
    );
  }
}
