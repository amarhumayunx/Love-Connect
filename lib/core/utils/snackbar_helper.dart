import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/core/strings/get_started_screens_app_strings.dart';

/// Helper class for safely showing snackbars
class SnackbarHelper {
  SnackbarHelper._();

  /// Safely shows a snackbar using Flutter's native SnackBar
  static void showSafe({
    required String title,
    required String message,
    Duration? duration,
    Color? backgroundColor,
    Color? colorText,
  }) {
    try {
      final context = Get.context;

      if (context == null || !context.mounted) {
        debugPrint('SnackbarHelper: Context not available');
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              // App Icon with white background circle
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(6),
                child: Image.asset(
                  AppStrings.app_logo_snackbar,
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint('SnackbarHelper: Error loading app logo - $error');
                    debugPrint('SnackbarHelper: Asset path - ${AppStrings.app_logo_strings}');
                    // Fallback to heart icon if image fails
                    return const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 20,
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Title and Message
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: backgroundColor ?? AppColors.primaryRed.withValues(alpha: 0.9),
          duration: duration ?? const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(38),
          ),
          dismissDirection: DismissDirection.horizontal,
        ),
      );
    } catch (e) {
      debugPrint('SnackbarHelper: Error showing snackbar - $e');
    }
  }

  /// Show error snackbar
  static void showError({
    required String message,
    String title = 'Error',
    Duration? duration,
  }) {
    showSafe(
      title: title,
      message: message,
      duration: duration,
      backgroundColor: Colors.red.shade700,
      colorText: Colors.white,
    );
  }

  /// Show success snackbar
  static void showSuccess({
    required String message,
    String title = 'Success',
    Duration? duration,
  }) {
    showSafe(
      title: title,
      message: message,
      duration: duration,
      backgroundColor: Colors.green.shade700,
      colorText: Colors.white,
    );
  }

  /// Show info snackbar
  static void showInfo({
    required String message,
    String title = 'Info',
    Duration? duration,
  }) {
    showSafe(
      title: title,
      message: message,
      duration: duration,
      backgroundColor: Colors.blue.shade700,
      colorText: Colors.white,
    );
  }

  /// Show warning snackbar
  static void showWarning({
    required String message,
    String title = 'Warning',
    Duration? duration,
  }) {
    showSafe(
      title: title,
      message: message,
      duration: duration,
      backgroundColor: Colors.orange.shade700,
      colorText: Colors.white,
    );
  }
}