import 'dart:io';
import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

/// Service for managing Google AdMob ads
class AdMobService {
  static AdMobService? _instance;
  static AdMobService get instance => _instance ??= AdMobService._();
  
  AdMobService._();

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdLoading = false;
  bool _isInterstitialAdShowing = false;
  DateTime? _adShowStartTime;

  // Test Ad Unit IDs - Replace these with your actual Ad Unit IDs from AdMob console
  // For testing, you can use these Google test ad unit IDs:
  // Android Banner: ca-app-pub-3940256099942544/6300978111
  // iOS Banner: ca-app-pub-3940256099942544/2934735716
  
  // TODO: Replace with your actual Ad Unit IDs from AdMob console
  String get bannerAdUnitId {
    if (kDebugMode) {
      // Use test ad unit IDs in debug mode to see ads immediately
      // These Google test IDs will always show test ads
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111' // Android Banner Test ID
          : 'ca-app-pub-3940256099942544/2934735716'; // iOS Banner Test ID
    } else {
      // Use your actual ad unit IDs in release mode
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111' // Android banner ad unit ID (TODO: Replace with your Android ad unit ID)
          : 'ca-app-pub-3425673808153409/8464817871'; // iOS Home Banner ad unit ID
    }
  }

  /// Settings Screen Banner Ad Unit ID
  String get settingsBannerAdUnitId {
    if (kDebugMode) {
      // Use test ad unit IDs in debug mode to see ads immediately
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111' // Android Banner Test ID
          : 'ca-app-pub-3940256099942544/2934735716'; // iOS Banner Test ID
    } else {
      // Use your actual ad unit IDs in release mode
      return Platform.isAndroid
          ? 'ca-app-pub-3425673808153409/7966711158' // Android Settings Screen Banner ad unit ID
          : 'ca-app-pub-3425673808153409/7966711158'; // iOS Settings Screen Banner ad unit ID
    }
  }

  /// Full Screen Interstitial Ad Unit ID
  String get interstitialAdUnitId {
    if (kDebugMode) {
      // Use test ad unit IDs in debug mode
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/1033173712' // Android Interstitial Test ID
          : 'ca-app-pub-3940256099942544/4411468910'; // iOS Interstitial Test ID
    } else {
      // Use your actual ad unit ID in release mode
      return 'ca-app-pub-3425673808153409/4135470870'; // FullScreen Ad Unit ID
    }
  }

  /// Initialize AdMob SDK
  Future<void> initialize() async {
    try {
      await MobileAds.instance.initialize();
      if (kDebugMode) {
        print('AdMob initialized successfully');
      }
      // Preload interstitial ad
      loadInterstitialAd();
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing AdMob: $e');
      }
    }
  }

  /// Load interstitial ad
  Future<void> loadInterstitialAd() async {
    if (_isInterstitialAdLoading || _interstitialAd != null) {
      return;
    }

    _isInterstitialAdLoading = true;

    try {
      await InterstitialAd.load(
        adUnitId: interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            if (kDebugMode) {
              print('✅ Interstitial ad loaded successfully');
            }
            _interstitialAd = ad;
            _isInterstitialAdLoading = false;

            // Set up ad event callbacks
            _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (InterstitialAd ad) {
                // Calculate and log ad display duration
                if (_adShowStartTime != null) {
                  final duration = DateTime.now().difference(_adShowStartTime!);
                  final seconds = duration.inSeconds;
                  final milliseconds = duration.inMilliseconds;
                  
                  if (kDebugMode) {
                    print('⏱️  FULL SCREEN AD: Dismissed after ${seconds}s ${milliseconds % 1000}ms (Total: ${milliseconds}ms)');
                  }
                  
                  // Log in a more readable format
                  if (seconds >= 60) {
                    final minutes = seconds ~/ 60;
                    final remainingSeconds = seconds % 60;
                    if (kDebugMode) {
                      print('⏱️  FULL SCREEN AD: Display time = ${minutes}m ${remainingSeconds}s');
                    }
                  } else {
                    if (kDebugMode) {
                      print('⏱️  FULL SCREEN AD: Display time = ${seconds}.${(milliseconds % 1000).toString().padLeft(3, '0')}s');
                    }
                  }
                  
                  _adShowStartTime = null;
                } else {
                  if (kDebugMode) {
                    print('Interstitial ad dismissed by user (time not tracked)');
                  }
                }
                
                ad.dispose();
                _interstitialAd = null;
                _isInterstitialAdShowing = false;
                // Load next ad
                loadInterstitialAd();
              },
              onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
                if (kDebugMode) {
                  print('Interstitial ad failed to show: $error');
                }
                _adShowStartTime = null;
                ad.dispose();
                _interstitialAd = null;
                _isInterstitialAdLoading = false;
                _isInterstitialAdShowing = false;
              },
              onAdShowedFullScreenContent: (InterstitialAd ad) {
                _adShowStartTime = DateTime.now();
                if (kDebugMode) {
                  print('⏱️  FULL SCREEN AD: Started showing at ${_adShowStartTime!.toIso8601String()}');
                }
                _isInterstitialAdShowing = true;
              },
            );
          },
          onAdFailedToLoad: (LoadAdError error) {
            if (kDebugMode) {
              print('❌ Interstitial ad failed to load: $error');
            }
            _isInterstitialAdLoading = false;
            _interstitialAd = null;
          },
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error loading interstitial ad: $e');
      }
      _isInterstitialAdLoading = false;
    }
  }

  /// Show interstitial ad
  /// Note: Interstitial ads are controlled by AdMob and will close automatically
  /// when the user dismisses them or when the ad completes (typically 5-30 seconds)
  Future<bool> showInterstitialAd() async {
    if (_interstitialAd == null || _isInterstitialAdShowing) {
      if (kDebugMode) {
        print('Interstitial ad not ready or already showing');
      }
      // Try to load ad if not available
      if (_interstitialAd == null) {
        await loadInterstitialAd();
      }
      return false;
    }

    try {
      _interstitialAd!.show();
      if (kDebugMode) {
        print('✅ Interstitial ad displayed (will close automatically)');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error showing interstitial ad: $e');
      }
      return false;
    }
  }

  /// Dispose resources
  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isInterstitialAdLoading = false;
    _isInterstitialAdShowing = false;
    _adShowStartTime = null;
  }
  
  /// Get last ad display duration (for debugging/analytics)
  Duration? getLastAdDuration() {
    if (_adShowStartTime != null) {
      return DateTime.now().difference(_adShowStartTime!);
    }
    return null;
  }
}

