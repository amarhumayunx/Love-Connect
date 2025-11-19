import 'package:flutter/material.dart';
import 'package:love_connect/core/utils/media_query_extensions.dart';

class LoginLayoutMetrics {
  final double titleSize;
  final double subtitleSize;
  final double spacingLarge;
  final double spacingMedium;
  final double spacingSmall;
  final double logoHeight;
  final double spacingTop;
  final double spacingScrollView;

  const LoginLayoutMetrics({
    required this.titleSize,
    required this.subtitleSize,
    required this.spacingLarge,
    required this.spacingMedium,
    required this.spacingSmall,
    required this.logoHeight,
    required this.spacingTop,
    required this.spacingScrollView,
  });

  factory LoginLayoutMetrics.fromContext(BuildContext context) {
    return LoginLayoutMetrics(
      titleSize: context.responsiveFont(30),
      subtitleSize: context.responsiveFont(14),
      spacingLarge: context.responsiveSpacing(13),
      spacingMedium: context.responsiveSpacing(10),
      spacingSmall: context.responsiveSpacing(12),
      spacingTop: context.responsiveSpacing(40),
      logoHeight: context.responsiveImage(200),
      spacingScrollView: context.responsiveSpacing(20),
    );
  }
}
