import 'package:flutter/material.dart';
import 'package:love_connect/core/utils/media_query_extensions.dart';

class HomeLayoutMetrics {
  final double headerTopPadding;
  final double headerHorizontalPadding;
  final double headerBottomPadding;
  final double profileImageSize;
  final double userNameFontSize;
  final double userTaglineFontSize;
  final double iconSize;
  final double sectionTitleFontSize;
  final double sectionSpacing;
  final double cardPadding;
  final double cardBorderRadius;
  final double upcomingPlansCardPadding;
  final double addButtonHeight;
  final double addButtonFontSize;
  final double quickActionCardSize;
  final double quickActionIconSize;
  final double quickActionFontSize;
  final double quickActionGridSpacing;
  final double bottomNavHeight;
  final double bottomNavIconSize;
  final double bottomNavFontSize;
  final double contentBottomSpacing;
  final double notificationBadgeSize;
  final double quickActionPadding;

  const HomeLayoutMetrics({
    required this.headerTopPadding,
    required this.headerHorizontalPadding,
    required this.headerBottomPadding,
    required this.profileImageSize,
    required this.userNameFontSize,
    required this.userTaglineFontSize,
    required this.iconSize,
    required this.sectionTitleFontSize,
    required this.sectionSpacing,
    required this.cardPadding,
    required this.cardBorderRadius,
    required this.upcomingPlansCardPadding,
    required this.addButtonHeight,
    required this.addButtonFontSize,
    required this.quickActionCardSize,
    required this.quickActionIconSize,
    required this.quickActionFontSize,
    required this.quickActionGridSpacing,
    required this.bottomNavHeight,
    required this.bottomNavIconSize,
    required this.bottomNavFontSize,
    required this.contentBottomSpacing,
    required this.notificationBadgeSize,
    required this.quickActionPadding,
  });

  factory HomeLayoutMetrics.fromContext(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final safeAreaTop = MediaQuery.of(context).padding.top;

    // Calculate responsive values based on screen dimensions
    double scaleFactor = 1.0;
    if (screenWidth < 360) {
      // Small phones (iPhone SE, small Android)
      scaleFactor = 0.85;
    } else if (screenWidth < 414) {
      // Medium phones (iPhone 12/13, standard Android)
      scaleFactor = 1.0;
    } else if (screenWidth < 768) {
      // Large phones (iPhone Pro Max, large Android)
      scaleFactor = 1.0;
    } else {
      // Tablets
      scaleFactor = 1.2;
    }

    // Height-based scaling for very short screens
    double heightScaleFactor = 1.0;
    if (screenHeight < 600) {
      heightScaleFactor = 0.8;
    } else if (screenHeight < 700) {
      heightScaleFactor = 0.9;
    } else if (screenHeight < 800) {
      heightScaleFactor = 1.0;
    } else {
      heightScaleFactor = 1.1;
    }

    // Combine both factors for better responsiveness
    final combinedScale = (scaleFactor + heightScaleFactor) / 2;

    return HomeLayoutMetrics(
      headerTopPadding: (safeAreaTop + (18 * combinedScale)).clamp(30.0, 110.0),
      headerHorizontalPadding: (screenWidth * 0.04).clamp(16.0, 24.0),
      headerBottomPadding: (4 * combinedScale).clamp(8.0, 20.0),
      quickActionPadding: (screenHeight * 0.01).clamp(12.0, 32.0),
      profileImageSize: (40 * combinedScale).clamp(48.0, 72.0),
      userNameFontSize: context.responsiveFont(16),
      userTaglineFontSize: context.responsiveFont(12),
      iconSize: context.responsiveImage(20),
      sectionTitleFontSize: context.responsiveFont(24),
      sectionSpacing: (screenHeight * 0.02).clamp(18.0, 32.0),
      cardPadding: (screenWidth * 0.04).clamp(10.0, 18.0),
      cardBorderRadius: (20 * combinedScale).clamp(16.0, 24.0),
      upcomingPlansCardPadding: (24 * combinedScale).clamp(20.0, 32.0),
      addButtonHeight: context.responsiveButtonHeight(),
      addButtonFontSize: context.responsiveFont(16),
      quickActionCardSize: ((screenWidth - (screenWidth * 0.1) - 24) / 3)
          .clamp(80.0, 120.0),
      quickActionIconSize: context.responsiveImage(30),
      quickActionFontSize: context.responsiveFont(12),
      quickActionGridSpacing: (10 * combinedScale).clamp(6.0, 14.0),
      bottomNavHeight: (56 * combinedScale).clamp(56.0, 70.0),
      bottomNavIconSize: context.responsiveImage(24),
      bottomNavFontSize: context.responsiveFont(12),
      contentBottomSpacing: (screenHeight * 0.10).clamp(80.0, 120.0),
      notificationBadgeSize: (4 * combinedScale).clamp(12.0, 22.0),
    );
  }
}

