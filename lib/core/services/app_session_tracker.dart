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

    // Check every minute if we've reached 5 minutes
    _checkTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _checkAndShowAd(),
    );
  }

  /// Pause tracking when app goes to background
  void pauseTracking() {
    if (!_isTracking || _sessionStartTime == null) {
      return;
    }

    _lastPauseTime = DateTime.now();
    
    if (kDebugMode) {
      print('📱 SESSION: Paused tracking (app in background)');
    }
  }

  /// Resume tracking when app comes to foreground
  void resumeTracking() {
    if (!_isTracking || _sessionStartTime == null) {
      return;
    }

    if (_lastPauseTime != null) {
      // Calculate time spent in foreground before pause
      final foregroundTime = _lastPauseTime!.difference(_sessionStartTime!);
      _accumulatedTime += foregroundTime;
      _sessionStartTime = DateTime.now();
      _lastPauseTime = null;

      if (kDebugMode) {
        final totalMinutes = _accumulatedTime.inMinutes;
        print('📱 SESSION: Resumed tracking. Total time: $totalMinutes minutes');
      }
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

    if (kDebugMode && totalMinutes % 5 == 0) {
      print('📱 SESSION: Total usage time: $totalMinutes minutes');
    }

    // Show ad after 5 minutes
    if (totalMinutes >= 5) {
      if (kDebugMode) {
        print('📱 SESSION: 5 minutes reached! Showing full-screen ad...');
      }

      _hasShownAdThisSession = true;
      
      // Show the interstitial ad
      // Note: The ad will display for its natural duration (typically 5-30 seconds)
      // and will close when the user dismisses it or when it completes
      final adShown = await AdMobService.instance.showInterstitialAd();

      if (adShown) {
        if (kDebugMode) {
          print('✅ SESSION: Full-screen ad displayed');
        }
        
        // Reset tracking after showing ad (user can continue using app)
        // The ad will be shown again after another 5 minutes
        _accumulatedTime = Duration.zero;
        _sessionStartTime = DateTime.now();
        _hasShownAdThisSession = false;
      } else {
        // If ad failed to show, reset the flag so we can try again
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

