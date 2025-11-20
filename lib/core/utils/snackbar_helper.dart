import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Helper class for safely showing snackbars
class SnackbarHelper {
  SnackbarHelper._();

  /// Safely shows a snackbar, ensuring the widget tree is ready
  static void showSafe({
    required String title,
    required String message,
    SnackPosition position = SnackPosition.BOTTOM,
    Duration? duration,
  }) {
    // Ensure we're on the next frame to allow widget tree to be ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        // Get.snackbar handles context internally
        Get.snackbar(
          title,
          message,
          snackPosition: position,
          duration: duration ?? const Duration(seconds: 2),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          borderRadius: 12,
          isDismissible: true,
          dismissDirection: DismissDirection.horizontal,
          forwardAnimationCurve: Curves.easeOutBack,
          animationDuration: const Duration(milliseconds: 300),
        );
      } catch (e) {
        // If snackbar fails, log it
        debugPrint('SnackbarHelper: Failed to show snackbar "$title" - $e');
      }
    });
  }
}

