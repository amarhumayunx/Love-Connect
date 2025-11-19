import 'package:flutter/widgets.dart';

/// Extension methods that expose MediaQuery-driven helpers directly on
/// BuildContext so responsive values can be accessed anywhere in the app.
extension MediaQueryResponsive on BuildContext {
  MediaQueryData get _mediaQuery => MediaQuery.of(this);

  Size get screenSize => _mediaQuery.size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;

  /// Width scaled by percentage of the current screen width.
  double widthPct(double percentage) => screenWidth * (percentage / 100);

  /// Height scaled by percentage of the current screen height.
  double heightPct(double percentage) => screenHeight * (percentage / 100);

  /// Font size that scales with the available screen width.
  double responsiveFont(double baseSize) {
    if (screenWidth < 360) {
      return baseSize * 0.85;
    } else if (screenWidth < 414) {
      return baseSize;
    } else if (screenWidth < 768) {
      return baseSize * 1.1;
    } else {
      return baseSize * 1.3;
    }
  }

  /// Padding that scales with device width while respecting individual values.
  EdgeInsets responsivePadding({
    double? horizontal,
    double? vertical,
    double? all,
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    double scaleFactor = 1.0;
    if (screenWidth < 360) {
      scaleFactor = 0.85;
    } else if (screenWidth > 768) {
      scaleFactor = 1.2;
    }

    double resolve(double? specific, double? fallbackAxis) =>
        (specific ?? all ?? fallbackAxis ?? 0) * scaleFactor;

    return EdgeInsets.only(
      left: resolve(left, horizontal),
      right: resolve(right, horizontal),
      top: resolve(top, vertical),
      bottom: resolve(bottom, vertical),
    );
  }

  /// Size for images and icons that scales with the smaller screen dimension.
  double responsiveImage(double baseSize) {
    final minDimension = screenWidth < screenHeight
        ? screenWidth
        : screenHeight;
    if (minDimension < 360) {
      return baseSize * 0.7;
    } else if (minDimension < 414) {
      return baseSize;
    } else if (minDimension < 768) {
      return baseSize * 1.2;
    } else {
      return baseSize * 1.5;
    }
  }

  bool get isTablet => screenWidth >= 768;
  bool get isSmallPhone => screenWidth < 360;

  /// Spacing that scales with the screen height.
  double responsiveSpacing(double baseSpacing) {
    if (screenHeight < 600) {
      return baseSpacing * 0.7;
    } else if (screenHeight < 800) {
      return baseSpacing;
    } else if (screenHeight < 1200) {
      return baseSpacing * 1.2;
    } else {
      return baseSpacing * 1.5;
    }
  }

  EdgeInsets get safeAreaPadding => _mediaQuery.padding;

  /// Button height tuned for the current device height.
  double responsiveButtonHeight() {
    if (screenHeight < 600) {
      return 44;
    } else if (screenHeight < 800) {
      return 48;
    } else {
      return 52;
    }
  }
}
