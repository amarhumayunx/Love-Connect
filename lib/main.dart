import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/MyApp.dart';

void main() async {
  // Configure error handling for font loading failures on iOS
  FlutterError.onError = (FlutterErrorDetails details) {
    // Suppress font loading errors to prevent crashes
    final exceptionString = details.exception.toString();
    if (exceptionString.contains('google_fonts') &&
        (exceptionString.contains('Failed host lookup') ||
            exceptionString.contains('SocketException') ||
            exceptionString.contains('fonts.gstatic.com'))) {
      // Silently handle font loading network errors - app will use system fonts
      if (kDebugMode) {
        debugPrint(
          'Font loading error (network issue) - using system fonts: ${details.exception}',
        );
      }
      return; // Don't crash the app
    }
    // Handle other errors normally
    FlutterError.presentError(details);
  };

  // Handle unhandled exceptions (like font loading errors)
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      // Note: Notification permissions will be requested when user creates their first plan
      // This provides better context and UX than requesting at app startup
      runApp(const MyApp());
    },
    (error, stack) {
      // Catch unhandled exceptions, especially font loading errors
      final errorString = error.toString();
      if (errorString.contains('google_fonts') &&
          (errorString.contains('Failed host lookup') ||
              errorString.contains('SocketException') ||
              errorString.contains('fonts.gstatic.com'))) {
        // Silently handle font loading network errors
        if (kDebugMode) {
          debugPrint(
            'Unhandled font loading error (network issue) - using system fonts: $error',
          );
        }
        return; // Don't crash the app
      }
      // Re-throw other errors
      throw error;
    },
  );
}
