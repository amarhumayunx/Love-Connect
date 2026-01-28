import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:love_connect/core/services/admob_service.dart';

/// Service to track app session time and show full-screen ads after 5 minutes
class AppSessionTracker {
  static AppSessionTracker? _instance;
  static AppSessionTracker get instance => _instance ??= AppSessionTracker._();

  AppSessionTracker._();

  DateTime? _sessionStartTime;
  DateTime? _lastPauseTime;
  Duration _accumulatedTime = Duration.zero;
  Timer? _checkTimer;
  bool _hasShownAdThisSession = false;
  bool _isTracking = false;

  /// Start tracking session time
  void startTracking() {
    if (_isTracking) {
      return;
    }

    _isTracking = true;
    _sessionStartTime = DateTime.now();
    _accumulatedTime = Duration.zero;
    _hasShownAdThisSession = false;

    if (kDebugMode) {
      print('📱 SESSION: Started tracking app usage time');
    }

    // Check every 30 seconds if we've reached 5 minutes (more frequent checks)
    _checkTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _checkAndShowAd(),
    );
  }

  /// Pause tracking when app goes to background
  void pauseTracking() {
    if (!_isTracking || _sessionStartTime == null) {
      return;
    }

    // Accumulate time before pausing
    if (_lastPauseTime == null) {
      // App was in foreground, accumulate the time
      final foregroundTime = DateTime.now().difference(_sessionStartTime!);
      _accumulatedTime += foregroundTime;

      if (kDebugMode) {
        final totalMinutes = _accumulatedTime.inMinutes;
        print(
          '📱 SESSION: Paused tracking (app in background). Total time: $totalMinutes minutes',
        );
      }
    }

    _lastPauseTime = DateTime.now();
  }

  /// Resume tracking when app comes to foreground
  void resumeTracking() {
    if (!_isTracking || _sessionStartTime == null) {
      return;
    }

    // Reset session start time for new foreground session
    _sessionStartTime = DateTime.now();
    _lastPauseTime = null;

    if (kDebugMode) {
      final totalMinutes = _accumulatedTime.inMinutes;
      print(
        '📱 SESSION: Resumed tracking. Total accumulated time: $totalMinutes minutes',
      );
    }
  }

  /// Stop tracking session
  void stopTracking() {
    _isTracking = false;
    _checkTimer?.cancel();
    _checkTimer = null;
    _sessionStartTime = null;
    _lastPauseTime = null;
    _accumulatedTime = Duration.zero;
    _hasShownAdThisSession = false;

    if (kDebugMode) {
      print('📱 SESSION: Stopped tracking');
    }
  }

  /// Check if 5 minutes have passed and show ad if needed
  Future<void> _checkAndShowAd() async {
    if (!_isTracking || _sessionStartTime == null || _hasShownAdThisSession) {
      return;
    }

    // Calculate total time spent
    Duration currentSessionTime = _accumulatedTime;

    if (_lastPauseTime == null) {
      // App is in foreground, add current session time
      currentSessionTime += DateTime.now().difference(_sessionStartTime!);
    }

    final totalMinutes = currentSessionTime.inMinutes;
    final totalSeconds = currentSessionTime.inSeconds;

    // Log every 30 seconds for debugging
    if (kDebugMode && totalSeconds % 30 == 0) {
      print(
        '📱 SESSION: Total usage time: ${totalMinutes}m ${totalSeconds % 60}s (${totalSeconds}s total)',
      );
    }

    // For testing: Show ad after 30 seconds in debug mode, 5 minutes in release
    final thresholdSeconds = kDebugMode ? 30 : 300;

    // Show ad after threshold (30 seconds for testing, 5 minutes for production)
    if (totalSeconds >= thresholdSeconds) {
      if (kDebugMode) {
        print(
          '📱 SESSION: ${thresholdSeconds == 30 ? "30 seconds" : "5 minutes"} reached! Showing full-screen ad...',
        );
      }

      _hasShownAdThisSession = true;

      // Show the interstitial ad
      // Note: The ad will display for its natural duration (typically 5-30 seconds)
      // and will close when the user dismisses it or when it completes
      // Check if AdMob is initialized before attempting to show ad
      if (kDebugMode) {
        print('🔄 SESSION: Attempting to show interstitial ad...');
      }

      final adShown = await AdMobService.instance.showInterstitialAd();

      if (adShown) {
        if (kDebugMode) {
          print('✅ SESSION: Full-screen ad displayed successfully');
        }

        // Reset tracking after showing ad (user can continue using app)
        // The ad will be shown again after another 5 minutes
        _accumulatedTime = Duration.zero;
        _sessionStartTime = DateTime.now();
        _hasShownAdThisSession = false;
      } else {
        // If ad failed to show, reset the flag so we can try again
        if (kDebugMode) {
          print('❌ SESSION: Failed to show ad. Will retry on next check.');
        }
        _hasShownAdThisSession = false;
      }
    }
  }

  /// Get current session time (for debugging)
  Duration getCurrentSessionTime() {
    if (!_isTracking || _sessionStartTime == null) {
      return Duration.zero;
    }

    Duration currentSessionTime = _accumulatedTime;

    if (_lastPauseTime == null) {
      // App is in foreground, add current session time
      currentSessionTime += DateTime.now().difference(_sessionStartTime!);
    }

    return currentSessionTime;
  }
}
