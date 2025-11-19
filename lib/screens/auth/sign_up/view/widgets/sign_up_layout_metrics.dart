import 'package:flutter/material.dart';
import 'package:love_connect/core/utils/media_query_extensions.dart';

class SignUpLayoutMetrics {
  final double titleSize;
  final double subtitleSize;
  final double spacingLarge;
  final double spacingMedium;
  final double logoHeight;
  final double spacingTop;
  final double spacingScrollView;
  
  final double spacingtopsignpbutton;

  const SignUpLayoutMetrics({
    required this.titleSize,
    required this.subtitleSize,
    required this.spacingLarge,
    required this.spacingMedium,
    required this.logoHeight,
    required this.spacingTop,
    required this.spacingScrollView,
    required this.spacingtopsignpbutton,
  });

  factory SignUpLayoutMetrics.fromContext(BuildContext context) {
    return SignUpLayoutMetrics(
      spacingtopsignpbutton: context.responsiveSpacing(16),
      titleSize: context.responsiveFont(28),
      subtitleSize: context.responsiveFont(15),
      spacingLarge: context.responsiveSpacing(10),
      spacingMedium: context.responsiveSpacing(10),
      spacingScrollView: context.responsiveSpacing(20),
      spacingTop: context.responsiveSpacing(40),
      logoHeight: context.responsiveImage(200),
    );
  }
}
