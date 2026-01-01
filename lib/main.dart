import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart';
import 'core/MyApp.dart';
import 'core/services/error_handling_service.dart';
import 'core/services/dependency_injection.dart';
import 'core/services/admob_service.dart';
import 'core/colors/app_colors.dart';

// Helper function to log errors that works in both debug and release mode
void _logError(String message, [Object? error, StackTrace? stack]) {
  // Use print instead of debugPrint for release mode compatibility
  print('[$message] ${error ?? ''}');
  if (stack != null) {
    print('Stack trace: $stack');
  }
  
  // Also use debugPrint for debug mode (shows in IDE console)
  if (kDebugMode) {
    debugPrint('[$message] ${error ?? ''}');
    if (stack != null) {
      debugPrint('Stack trace: $stack');
    }
  }
}

bool _isFontLoadingNetworkError(String errorString) {
  if (!errorString.contains('google_fonts')) {
    return false;
  }

  return errorString.contains('Failed host lookup') ||
      errorString.contains('SocketException') ||
      errorString.contains('fonts.gstatic.com');
}

void _handleFontLoadingError(Object error) {
  _logError('Font loading error (network issue) - using system fonts', error);
}

void _flutterErrorHandler(FlutterErrorDetails details) {
  final exceptionString = details.exception.toString();

  if (_isFontLoadingNetworkError(exceptionString)) {
    _handleFontLoadingError(details.exception);
    return;
  }

  // Log error in both debug and release mode
  _logError('Flutter Error', details.exception, details.stack);

  // Record non-fatal to Crashlytics if available
  FirebaseCrashlytics.instance.recordFlutterError(details);
  
  if (kDebugMode) {
    FlutterError.presentError(details);
  }
  // In release mode, don't show error UI to prevent app crash
}

void _unhandledExceptionHandler(Object error, StackTrace stack) {
  final errorString = error.toString();

  if (_isFontLoadingNetworkError(errorString)) {
    _handleFontLoadingError(error);
    return;
  }

  // Log the error but don't crash the app
  _logError('Unhandled Exception', error, stack);

  // Record to Crashlytics as non-fatal
  FirebaseCrashlytics.instance.recordError(error, stack, fatal: false);
  
  // NEVER re-throw in release mode to prevent app crash
  // Only throw in debug mode for easier debugging
  if (kDebugMode) {
    throw error;
  }
  // In release mode, silently handle and continue
}

Future<void> _initializeApp() async {
  try {
    // Ensure Flutter binding is initialized first
    WidgetsFlutterBinding.ensureInitialized();
    _logError('App', 'Flutter binding initialized');
    
    // Set status bar color to pink
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: AppColors.backgroundPink,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
    
    // Initialize dependency injection
    await DependencyInjection.init();
    _logError('App', 'Dependency injection initialized');
    
    // Initialize global error handling service
    ErrorHandlingService().initialize();
    _logError('App', 'Error handling service initialized');
    
    // Initialize AdMob
    try {
      await AdMobService.instance.initialize();
      _logError('App', 'AdMob initialized');
    } catch (e, stackTrace) {
      _logError('AdMob initialization error', e, stackTrace);
      // Continue app initialization even if AdMob fails
    }
    
    // Initialize Firebase with error handling and timeout
    try {
      _logError('Firebase', 'Starting initialization...');
      
      // Add timeout to prevent hanging
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          _logError('Firebase', 'Initialization timeout');
          throw TimeoutException('Firebase initialization timeout');
        },
      );
      
      _logError('Firebase', 'Initialization successful');

      // Enable Crashlytics collection once Firebase is ready
      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(!kDebugMode);
    } catch (e, stackTrace) {
      // Log Firebase initialization error but don't crash
      _logError('Firebase initialization error', e, stackTrace);
      ErrorHandlingService().handleError(
        error: e,
        stackTrace: stackTrace,
        context: 'Firebase Initialization',
      );
      
      // Continue app initialization even if Firebase fails
      // The app will handle Firebase errors gracefully in individual services
    }
    
    // Run the app
    _logError('App', 'Starting MyApp...');
    runApp(const MyApp());
  } catch (e, stackTrace) {
    // Catch any other initialization errors
    _logError('App initialization error', e, stackTrace);
    
    // Still try to run the app with a basic error handler
    // This ensures the app never crashes completely
    try {
      runApp(MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'App initialization error',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (kDebugMode)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      '$e',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ));
    } catch (fallbackError) {
      // If even the fallback fails, log and do nothing
      _logError('Critical: Fallback app also failed', fallbackError);
    }
  }
}

void main() async {
  // Set up error handlers BEFORE any async operations
  FlutterError.onError = _flutterErrorHandler;

  // Run app with zone error handling
  // This catches all unhandled exceptions and errors
  runZonedGuarded(
    () async {
      try {
        await _initializeApp();
      } catch (e, stack) {
        // Extra safety net for initialization
        _logError('Main initialization error', e, stack);
        // Try to run app anyway
        try {
          runApp(const MyApp());
        } catch (_) {
          // If all else fails, show error screen
          runApp(MaterialApp(
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text(
                      'Unable to start app',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ));
        }
      }
    },
    _unhandledExceptionHandler,
  );
}
