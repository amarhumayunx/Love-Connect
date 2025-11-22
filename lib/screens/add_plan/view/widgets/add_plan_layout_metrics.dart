import 'package:flutter/material.dart';
import 'package:love_connect/core/utils/media_query_extensions.dart';

class AddPlanLayoutMetrics {
  final double screenWidth;
  final double screenHeight;
  final double cardPadding;
  final double sectionSpacing;
  final double inputFieldHeight;
  final double inputFieldFontSize;
  final double labelFontSize;
  final double buttonHeight;
  final double buttonFontSize;
  final double headerFontSize;
  final double iconSize;

  AddPlanLayoutMetrics({
    required this.screenWidth,
    required this.screenHeight,
    required this.cardPadding,
    required this.sectionSpacing,
    required this.inputFieldHeight,
    required this.inputFieldFontSize,
    required this.labelFontSize,
    required this.buttonHeight,
    required this.buttonFontSize,
    required this.headerFontSize,
    required this.iconSize,
  });

  factory AddPlanLayoutMetrics.fromContext(BuildContext context) {
    final width = context.screenWidth;
    final height = context.screenHeight;
    
    return AddPlanLayoutMetrics(
      screenWidth: width,
      screenHeight: height,
      cardPadding: width * 0.05,
      sectionSpacing: height * 0.02,
      inputFieldHeight: context.responsiveButtonHeight(),
      inputFieldFontSize: context.responsiveFont(14),
      labelFontSize: context.responsiveFont(14),
      buttonHeight: context.responsiveButtonHeight(),
      buttonFontSize: context.responsiveFont(16),
      headerFontSize: context.responsiveFont(20),
      iconSize: context.responsiveImage(20),
    );
  }
}

