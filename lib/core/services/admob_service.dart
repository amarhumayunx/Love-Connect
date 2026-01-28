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

  // App Open Ad variables
  AppOpenAd? _appOpenAd;
  bool _isAppOpenAdLoading = false;
  bool _isAppOpenAdShowing = false;
  DateTime? _appOpenAdLoadTime;
  Completer<void>? _appOpenAdCompleter;

  // Initialization state
  bool _isInitialized = false;
  bool _isInitializing = false;
  int _interstitialRetryCount = 0;
  int _appOpenRetryCount = 0;
  int _initRetryCount = 0;
  static const int _maxRetries = 3;
  static const int _maxInitRetries = 3;

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

  /// All Plans Screen Banner Ad Unit ID
  String get allPlansBannerAdUnitId {
    if (kDebugMode) {
      // Use test ad unit IDs in debug mode to see ads immediately
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111' // Android Banner Test ID
          : 'ca-app-pub-3940256099942544/2934735716'; // iOS Banner Test ID
    } else {
      // Use your actual ad unit IDs in release mode
      return Platform.isAndroid
          ? 'ca-app-pub-3425673808153409/7642383309' // Android All Plans Screen Banner ad unit ID
          : 'ca-app-pub-3425673808153409/7642383309'; // iOS All Plans Screen Banner ad unit ID
    }
  }

  /// Ideas Screen Banner Ad Unit ID
  String get ideasBannerAdUnitId {
    if (kDebugMode) {
      // Use test ad unit IDs in debug mode to see ads immediately
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111' // Android Banner Test ID
          : 'ca-app-pub-3940256099942544/2934735716'; // iOS Banner Test ID
    } else {
      // Use your actual ad unit IDs in release mode
      return Platform.isAndroid
          ? 'ca-app-pub-3425673808153409/1742161690' // Android Ideas Screen Banner ad unit ID
          : 'ca-app-pub-3425673808153409/1742161690'; // iOS Ideas Screen Banner ad unit ID
    }
  }

  /// Journal Screen Banner Ad Unit ID
  String get journalBannerAdUnitId {
    if (kDebugMode) {
      // Use test ad unit IDs in debug mode to see ads immediately
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111' // Android Banner Test ID
          : 'ca-app-pub-3940256099942544/2934735716'; // iOS Banner Test ID
    } else {
      // Use your actual ad unit IDs in release mode
      return Platform.isAndroid
          ? 'ca-app-pub-3425673808153409/6802916684' // Android Journal Screen Banner ad unit ID
          : 'ca-app-pub-3425673808153409/6802916684'; // iOS Journal Screen Banner ad unit ID
    }
  }

  /// Surprise Screen Banner Ad Unit ID
  String get surpriseBannerAdUnitId {
    if (kDebugMode) {
      // Use test ad unit IDs in debug mode to see ads immediately
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111' // Android Banner Test ID
          : 'ca-app-pub-3940256099942544/2934735716'; // iOS Banner Test ID
    } else {
      // Use your actual ad unit IDs in release mode
      return Platform.isAndroid
          ? 'ca-app-pub-3425673808153409/2863671670' // Android Surprise Screen Banner ad unit ID
          : 'ca-app-pub-3425673808153409/2863671670'; // iOS Surprise Screen Banner ad unit ID
    }
  }

  /// Notification Screen Banner Ad Unit ID
  String get notificationBannerAdUnitId {
    if (kDebugMode) {
      // Use test ad unit IDs in debug mode to see ads immediately
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111' // Android Banner Test ID
          : 'ca-app-pub-3940256099942544/2934735716'; // iOS Banner Test ID
    } else {
      // Use your actual ad unit IDs in release mode
      return Platform.isAndroid
          ? 'ca-app-pub-3425673808153409/9829562947' // Android Notification Screen Banner ad unit ID
          : 'ca-app-pub-3425673808153409/9829562947'; // iOS Notification Screen Banner ad unit ID
    }
  }

  /// Add Plan Screen Banner Ad Unit ID
  String get addPlanBannerAdUnitId {
    if (kDebugMode) {
      // Use test ad unit IDs in debug mode to see ads immediately
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111' // Android Banner Test ID
          : 'ca-app-pub-3940256099942544/2934735716'; // iOS Banner Test ID
    } else {
      // Use your actual ad unit IDs in release mode
      return Platform.isAndroid
          ? 'ca-app-pub-3425673808153409/3264154590' // Android Add Plan Screen Banner ad unit ID
          : 'ca-app-pub-3425673808153409/3264154590'; // iOS Add Plan Screen Banner ad unit ID
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

  /// App Open Ad Unit ID
  String get appOpenAdUnitId {
    if (kDebugMode) {
      // Use test ad unit IDs in debug mode
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/9257395921' // Android App Open Test ID
          : 'ca-app-pub-3940256099942544/5574492063'; // iOS App Open Test ID
    } else {
      // Use your actual ad unit ID in release mode
      return 'ca-app-pub-3425673808153409/9014162962'; // App Open Ad Unit ID
    }
  }

  /// Check if AdMob is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize AdMob SDK
  Future<void> initialize() async {
    if (_isInitialized || _isInitializing) {
      return;
    }

    _isInitializing = true;

    try {
      if (kDebugMode) {
        print('🔄 AdMob: Starting initialization...');
      }

      final initResponse = await MobileAds.instance.initialize();
      _isInitialized = true;
      _isInitializing = false;
      _initRetryCount = 0; // Reset retry count on success

      if (kDebugMode) {
        print('✅ AdMob initialized successfully');
        print('AdMob initialization status: ${initResponse.adapterStatuses}');
      }

      // Wait a bit for SDK to be fully ready before loading ads
      await Future.delayed(const Duration(seconds: 2));

      // Preload ads with retry logic
      loadInterstitialAd();
      loadAppOpenAd();
    } catch (e, stackTrace) {
      _isInitialized = false;
      _isInitializing = false;

      if (kDebugMode) {
        print('❌ Error initializing AdMob: $e');
        print('Stack trace: $stackTrace');
      }

      // Retry initialization with exponential backoff
      if (_initRetryCount < _maxInitRetries) {
        _initRetryCount++;
        final delaySeconds = _initRetryCount * 3; // 3s, 6s, 9s
        if (kDebugMode) {
          print(
            '🔄 Retrying AdMob initialization in ${delaySeconds}s (attempt $_initRetryCount/$_maxInitRetries)',
          );
        }
        Future.delayed(Duration(seconds: delaySeconds), () {
          initialize();
        });
      } else {
        if (kDebugMode) {
          print(
            '⚠️ Max initialization retries reached. AdMob initialization failed.',
          );
        }
        _initRetryCount = 0; // Reset for next session
      }
    }
  }

  /// Load interstitial ad
  Future<void> loadInterstitialAd() async {
    if (_isInterstitialAdLoading || _interstitialAd != null) {
      if (kDebugMode) {
        print('⏭️ Interstitial ad: Already loading or loaded. Skipping.');
      }
      return;
    }

    // Don't load ads if AdMob isn't initialized
    if (!_isInitialized) {
      if (kDebugMode) {
        print('⚠️ AdMob not initialized yet, skipping interstitial ad load');
      }
      return;
    }

    _isInterstitialAdLoading = true;

    if (kDebugMode) {
      print('🔄 Interstitial ad: Starting to load...');
      print('   Ad Unit ID: $interstitialAdUnitId');
    }

    try {
      await InterstitialAd.load(
        adUnitId: interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            if (kDebugMode) {
              print('✅ Interstitial ad loaded successfully');
              print('   Ad Unit ID: $interstitialAdUnitId');
            }
            _interstitialAd = ad;
            _isInterstitialAdLoading = false;
            _interstitialRetryCount = 0; // Reset retry count on success

            // Set up ad event callbacks
            _interstitialAd!
                .fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (InterstitialAd ad) {
                // Calculate and log ad display duration
                if (_adShowStartTime != null) {
                  final duration = DateTime.now().difference(_adShowStartTime!);
                  final seconds = duration.inSeconds;
                  final milliseconds = duration.inMilliseconds;

                  if (kDebugMode) {
                    print(
                      '⏱️  FULL SCREEN AD: Dismissed after ${seconds}s ${milliseconds % 1000}ms (Total: ${milliseconds}ms)',
                    );
                  }

                  // Log in a more readable format
                  if (seconds >= 60) {
                    final minutes = seconds ~/ 60;
                    final remainingSeconds = seconds % 60;
                    if (kDebugMode) {
                      print(
                        '⏱️  FULL SCREEN AD: Display time = ${minutes}m ${remainingSeconds}s',
                      );
                    }
                  } else {
                    if (kDebugMode) {
                      print(
                        '⏱️  FULL SCREEN AD: Display time = $seconds.${(milliseconds % 1000).toString().padLeft(3, '0')}s',
                      );
                    }
                  }

                  _adShowStartTime = null;
                } else {
                  if (kDebugMode) {
                    print(
                      'Interstitial ad dismissed by user (time not tracked)',
                    );
                  }
                }

                ad.dispose();
                _interstitialAd = null;
                _isInterstitialAdShowing = false;
                // Load next ad
                loadInterstitialAd();
              },
              onAdFailedToShowFullScreenContent:
                  (InterstitialAd ad, AdError error) {
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
                  print(
                    '⏱️  FULL SCREEN AD: Started showing at ${_adShowStartTime!.toIso8601String()}',
                  );
                }
                _isInterstitialAdShowing = true;
              },
            );
          },
          onAdFailedToLoad: (LoadAdError error) {
            if (kDebugMode) {
              print('❌ Interstitial ad failed to load: $error');
              print(
                '   Error code: ${error.code}, Domain: ${error.domain}, Message: ${error.message}',
              );
            }
            _isInterstitialAdLoading = false;
            _interstitialAd = null;

            // Retry logic with exponential backoff
            if (_interstitialRetryCount < _maxRetries) {
              _interstitialRetryCount++;
              final delaySeconds = _interstitialRetryCount * 2; // 2s, 4s, 6s
              if (kDebugMode) {
                print(
                  '🔄 Retrying interstitial ad load in ${delaySeconds}s (attempt $_interstitialRetryCount/$_maxRetries)',
                );
              }
              Future.delayed(Duration(seconds: delaySeconds), () {
                loadInterstitialAd();
              });
            } else {
              if (kDebugMode) {
                print(
                  '⚠️ Max retries reached for interstitial ad. Will retry on next app session.',
                );
              }
              _interstitialRetryCount = 0; // Reset for next session
            }
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
    // Check if AdMob is initialized first
    if (!_isInitialized) {
      if (kDebugMode) {
        print('⚠️ Cannot show interstitial ad: AdMob not initialized yet');
      }

      // Try to initialize if not already initializing
      if (!_isInitializing) {
        if (kDebugMode) {
          print('🔄 Attempting to initialize AdMob...');
        }
        await initialize();
      } else {
        if (kDebugMode) {
          print('⏳ AdMob initialization in progress, waiting...');
        }
      }

      // Wait for initialization to complete (with timeout)
      int waitAttempts = 0;
      const maxWaitAttempts = 10; // Wait up to 5 seconds (10 * 500ms)
      while (!_isInitialized && waitAttempts < maxWaitAttempts) {
        await Future.delayed(const Duration(milliseconds: 500));
        waitAttempts++;
      }

      // If still not initialized, return false
      if (!_isInitialized) {
        if (kDebugMode) {
          print('❌ AdMob initialization timeout or failed. Cannot show ad.');
        }
        return false;
      }

      if (kDebugMode) {
        print('✅ AdMob initialized, proceeding to show ad...');
      }
    }

    if (_isInterstitialAdShowing) {
      if (kDebugMode) {
        print('⚠️ Interstitial ad is already showing');
      }
      return false;
    }

    // If ad is not loaded, try to load it first
    if (_interstitialAd == null) {
      if (kDebugMode) {
        if (_isInterstitialAdLoading) {
          print('⏳ Interstitial ad is already loading, waiting...');
        } else {
          print('🔄 Interstitial ad not loaded, loading now...');
          await loadInterstitialAd();
        }
      } else {
        if (!_isInterstitialAdLoading) {
          await loadInterstitialAd();
        }
      }

      // Wait for ad to load (with timeout)
      int waitAttempts = 0;
      const maxWaitAttempts = 20; // Wait up to 10 seconds (20 * 500ms)
      while (_interstitialAd == null && waitAttempts < maxWaitAttempts) {
        await Future.delayed(const Duration(milliseconds: 500));
        waitAttempts++;

        // If we're not loading anymore and ad is still null, it failed
        if (!_isInterstitialAdLoading && _interstitialAd == null) {
          if (kDebugMode) {
            print('⚠️ Ad loading completed but ad is still null (load failed)');
          }
          break;
        }
      }

      // Check if ad loaded successfully
      if (_interstitialAd == null) {
        if (kDebugMode) {
          print(
            '❌ Interstitial ad failed to load or timeout after ${waitAttempts * 500}ms. Cannot show ad.',
          );
        }
        return false;
      }

      if (kDebugMode) {
        print('✅ Interstitial ad loaded successfully, proceeding to show...');
      }
    }

    try {
      if (kDebugMode) {
        print('🎬 Attempting to display interstitial ad...');
        print('   Ad is ready: ${_interstitialAd != null}');
        print('   Ad is showing: $_isInterstitialAdShowing');
      }

      _interstitialAd!.show();
      _isInterstitialAdShowing = true;

      if (kDebugMode) {
        print(
          '✅ Interstitial ad displayed successfully (will close automatically)',
        );
      }
      return true;
    } catch (e, stackTrace) {
      _isInterstitialAdShowing = false;
      if (kDebugMode) {
        print('❌ Error showing interstitial ad: $e');
        print('Stack trace: $stackTrace');
      }
      return false;
    }
  }

  /// Load App Open Ad
  Future<void> loadAppOpenAd() async {
    if (_isAppOpenAdLoading || _appOpenAd != null) {
      return;
    }

    // Don't load ads if AdMob isn't initialized
    if (!_isInitialized) {
      if (kDebugMode) {
        print('⚠️ AdMob not initialized yet, skipping app open ad load');
      }
      return;
    }

    _isAppOpenAdLoading = true;

    try {
      await AppOpenAd.load(
        adUnitId: appOpenAdUnitId,
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (AppOpenAd ad) {
            if (kDebugMode) {
              print('✅ App Open ad loaded successfully');
            }
            _appOpenAd = ad;
            _isAppOpenAdLoading = false;
            _appOpenAdLoadTime = DateTime.now();
            _appOpenRetryCount = 0; // Reset retry count on success
          },
          onAdFailedToLoad: (LoadAdError error) {
            if (kDebugMode) {
              print('❌ App Open ad failed to load: $error');
              print(
                '   Error code: ${error.code}, Domain: ${error.domain}, Message: ${error.message}',
              );
            }
            _isAppOpenAdLoading = false;
            _appOpenAd = null;

            // Retry logic with exponential backoff
            if (_appOpenRetryCount < _maxRetries) {
              _appOpenRetryCount++;
              final delaySeconds = _appOpenRetryCount * 2; // 2s, 4s, 6s
              if (kDebugMode) {
                print(
                  '🔄 Retrying app open ad load in ${delaySeconds}s (attempt $_appOpenRetryCount/$_maxRetries)',
                );
              }
              Future.delayed(Duration(seconds: delaySeconds), () {
                loadAppOpenAd();
              });
            } else {
              if (kDebugMode) {
                print(
                  '⚠️ Max retries reached for app open ad. Will retry on next app session.',
                );
              }
              _appOpenRetryCount = 0; // Reset for next session
            }
          },
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error loading App Open ad: $e');
      }
      _isAppOpenAdLoading = false;
    }
  }

  /// Check if ad was loaded less than n hours ago
  bool _wasLoadTimeLessThanNHoursAgo(DateTime? loadTime, int numHours) {
    if (loadTime == null) return false;
    final dateDifference = DateTime.now().difference(loadTime);
    final numMillisecondsPerHour = const Duration(hours: 1).inMilliseconds;
    return dateDifference.inMilliseconds < (numMillisecondsPerHour * numHours);
  }

  /// Check if App Open ad exists and can be shown
  bool isAppOpenAdAvailable() {
    // App open ads expire after 4 hours
    return _appOpenAd != null &&
        _wasLoadTimeLessThanNHoursAgo(_appOpenAdLoadTime, 4);
  }

  /// Show App Open Ad if available
  /// Returns a Future that completes when the ad is dismissed or fails to show
  /// Returns true if ad was shown, false otherwise
  Future<bool> showAppOpenAdIfAvailable() async {
    // If the app open ad is already showing, do not show the ad again
    if (_isAppOpenAdShowing) {
      if (kDebugMode) {
        print('App Open ad is already showing');
      }
      return false;
    }

    // If the app open ad is not available yet, return false
    if (!isAppOpenAdAvailable()) {
      if (kDebugMode) {
        print('App Open ad is not ready yet');
      }
      // Try to load a new ad
      loadAppOpenAd();
      return false;
    }

    try {
      _isAppOpenAdShowing = true;
      _appOpenAdCompleter = Completer<void>();

      // Set up full screen content callback
      _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (AppOpenAd ad) {
          if (kDebugMode) {
            print('App Open ad dismissed fullscreen content');
          }
          ad.dispose();
          _appOpenAd = null;
          _isAppOpenAdShowing = false;
          _appOpenAdLoadTime = null;
          // Complete the completer to signal ad dismissal
          if (!_appOpenAdCompleter!.isCompleted) {
            _appOpenAdCompleter!.complete();
          }
          _appOpenAdCompleter = null;
          // Load next ad
          loadAppOpenAd();
        },
        onAdFailedToShowFullScreenContent: (AppOpenAd ad, AdError error) {
          if (kDebugMode) {
            print('App Open ad failed to show: $error');
          }
          ad.dispose();
          _appOpenAd = null;
          _isAppOpenAdShowing = false;
          _appOpenAdLoadTime = null;
          // Complete the completer to signal ad failure
          if (!_appOpenAdCompleter!.isCompleted) {
            _appOpenAdCompleter!.complete();
          }
          _appOpenAdCompleter = null;
          // Load next ad
          loadAppOpenAd();
        },
        onAdShowedFullScreenContent: (AppOpenAd ad) {
          if (kDebugMode) {
            print('App Open ad showed fullscreen content');
          }
        },
        onAdImpression: (AppOpenAd ad) {
          if (kDebugMode) {
            print('App Open ad recorded an impression');
          }
        },
        onAdClicked: (AppOpenAd ad) {
          if (kDebugMode) {
            print('App Open ad was clicked');
          }
        },
      );

      // Show the ad
      await _appOpenAd!.show();
      if (kDebugMode) {
        print('✅ App Open ad displayed');
      }

      // Wait for the ad to be dismissed
      await _appOpenAdCompleter?.future;

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error showing App Open ad: $e');
      }
      _isAppOpenAdShowing = false;
      _appOpenAd = null;
      _appOpenAdLoadTime = null;
      if (_appOpenAdCompleter != null && !_appOpenAdCompleter!.isCompleted) {
        _appOpenAdCompleter!.complete();
      }
      _appOpenAdCompleter = null;
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

    _appOpenAd?.dispose();
    _appOpenAd = null;
    _isAppOpenAdLoading = false;
    _isAppOpenAdShowing = false;
    _appOpenAdLoadTime = null;
    if (_appOpenAdCompleter != null && !_appOpenAdCompleter!.isCompleted) {
      _appOpenAdCompleter!.complete();
    }
    _appOpenAdCompleter = null;
  }

  /// Get last ad display duration (for debugging/analytics)
  Duration? getLastAdDuration() {
    if (_adShowStartTime != null) {
      return DateTime.now().difference(_adShowStartTime!);
    }
    return null;
  }
}
