import 'package:flutter/material.dart';

class ChangePasswordLayoutMetrics {
  final double horizontalPadding;
  final double topSpacing;
  final double titleSpacing;
  final double formSpacing;
  final double iconSize;
  final double buttonHeight;
  final double spacingMedium;
  final double spacingLarge;

  ChangePasswordLayoutMetrics({
    required this.horizontalPadding,
    required this.topSpacing,
    required this.titleSpacing,
    required this.formSpacing,
    required this.iconSize,
    required this.buttonHeight,
    required this.spacingMedium,
    required this.spacingLarge,
  });

  factory ChangePasswordLayoutMetrics.fromContext(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return ChangePasswordLayoutMetrics(
      horizontalPadding: isTablet ? 40 : 24,
      topSpacing: 16,
      titleSpacing: 24,
      formSpacing: 32,
      iconSize: 24,
      buttonHeight: screenSize.height * 0.06,
      spacingMedium: 16,
      spacingLarge: 24,
    );
  }
}
