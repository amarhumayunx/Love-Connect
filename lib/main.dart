import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/MyApp.dart';

/// Checks if an error string represents a font loading network error
bool _isFontLoadingNetworkError(String errorString) {
  if (!errorString.contains('google_fonts')) {
    return false;
  }

  return errorString.contains('Failed host lookup') ||
      errorString.contains('SocketException') ||
      errorString.contains('fonts.gstatic.com');
}

/// Handles font loading errors by logging in debug mode
void _handleFontLoadingError(Object error) {
  if (kDebugMode) {
    debugPrint(
      'Font loading error (network issue) - using system fonts: $error',
    );
  }
}

/// Error handler for FlutterError.onError
void _flutterErrorHandler(FlutterErrorDetails details) {
  final exceptionString = details.exception.toString();

  if (_isFontLoadingNetworkError(exceptionString)) {
    _handleFontLoadingError(details.exception);
    return; // Don't crash the app
  }

  // Handle other errors normally
  FlutterError.presentError(details);
}

/// Error handler for unhandled exceptions in runZonedGuarded
void _unhandledExceptionHandler(Object error, StackTrace stack) {
  final errorString = error.toString();

  if (_isFontLoadingNetworkError(errorString)) {
    _handleFontLoadingError(error);
    return; // Don't crash the app
  }

  // Re-throw other errors
  throw error;
}

/// Initializes the app by setting up Firebase and running MyApp
Future<void> _initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Note: Notification permissions will be requested when user creates their first plan
  // This provides better context and UX than requesting at app startup
  runApp(const MyApp());
}

void main() async {
  // Configure error handling for font loading failures on iOS
  FlutterError.onError = _flutterErrorHandler;

  // Handle unhandled exceptions (like font loading errors)
  runZonedGuarded(_initializeApp, _unhandledExceptionHandler);
}
