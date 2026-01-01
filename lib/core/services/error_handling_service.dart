import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Global error handling service for catching and logging unexpected errors
class ErrorHandlingService {
  static final ErrorHandlingService _instance = ErrorHandlingService._internal();
  factory ErrorHandlingService() => _instance;
  ErrorHandlingService._internal();

  final List<ErrorLog> _errorLogs = [];
  final int _maxLogs = 100;

  /// Initialize error handlers
  void initialize() {
    // Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      _handleError(
        error: details.exception,
        stackTrace: details.stack,
        context: 'Flutter Framework',
        fatal: false,
      );
      
      if (kDebugMode) {
        FlutterError.presentError(details);
      }
    };

    // Zone errors (async errors)
    runZonedGuarded(
      () {
        // App will run in this zone
      },
      (error, stackTrace) {
        _handleError(
          error: error,
          stackTrace: stackTrace,
          context: 'Zone Error',
          fatal: false,
        );
      },
    );
  }

  /// Handle and log an error
  void _handleError({
    required Object error,
    StackTrace? stackTrace,
    required String context,
    required bool fatal,
  }) {
    final errorLog = ErrorLog(
      error: error,
      stackTrace: stackTrace,
      context: context,
      fatal: fatal,
      timestamp: DateTime.now(),
    );

    _errorLogs.add(errorLog);
    
    // Keep only the last _maxLogs entries
    if (_errorLogs.length > _maxLogs) {
      _errorLogs.removeAt(0);
    }

    // Log to console in debug mode
    if (kDebugMode) {
      debugPrint('[$context] Error: $error');
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
    }

    // In production, you might want to send to crash reporting service
    // Example: Firebase Crashlytics, Sentry, etc.
    if (!kDebugMode && fatal) {
      // Send to crash reporting service
      _sendToCrashReporting(errorLog);
    }
  }

  /// Handle error manually (for try-catch blocks)
  void handleError({
    required Object error,
    StackTrace? stackTrace,
    String? context,
    bool showSnackbar = false,
    String? userMessage,
  }) {
    _handleError(
      error: error,
      stackTrace: stackTrace,
      context: context ?? 'Manual Error Handling',
      fatal: false,
    );

    if (showSnackbar) {
      Get.snackbar(
        'Error',
        userMessage ?? 'An unexpected error occurred. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Send error to crash reporting service (implement as needed)
  void _sendToCrashReporting(ErrorLog errorLog) {
    // TODO: Implement crash reporting integration
    // Example: Firebase Crashlytics, Sentry, etc.
  }

  /// Get error logs (for debugging)
  List<ErrorLog> getErrorLogs() => List.unmodifiable(_errorLogs);

  /// Clear error logs
  void clearLogs() => _errorLogs.clear();
}

/// Error log model
class ErrorLog {
  final Object error;
  final StackTrace? stackTrace;
  final String context;
  final bool fatal;
  final DateTime timestamp;

  ErrorLog({
    required this.error,
    this.stackTrace,
    required this.context,
    required this.fatal,
    required this.timestamp,
  });

  @override
  String toString() {
    return '[$context] ${error.toString()} at ${timestamp.toIso8601String()}';
  }
}
