import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:love_connect/core/services/admob_service.dart';

/// Widget for displaying banner ads
/// Supports both regular banners and anchored adaptive banners
class BannerAdWidget extends StatefulWidget {
  final AdSize? adSize;
  final EdgeInsets? margin;
  final String? adUnitId;
  final bool useAnchoredAdaptive;

  const BannerAdWidget({
    super.key,
    this.adSize,
    this.margin,
    this.adUnitId,
    this.useAnchoredAdaptive = false,
  });

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Wait for the first frame to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAd();
    });
  }

  Future<void> _loadAd() async {
    if (_isLoading) return;
    
    final adUnitId = widget.adUnitId ?? AdMobService.instance.bannerAdUnitId;
    
    if (kDebugMode) {
      print('📱 BANNER AD: Loading ad with unit ID: $adUnitId');
    }
    
    AdSize adSize;
    
    // Use anchored adaptive banner if requested and no explicit size provided
    if (widget.useAnchoredAdaptive && widget.adSize == null) {
      _isLoading = true;
      try {
        // Ensure context is mounted and available
        if (!mounted) {
          _isLoading = false;
          return;
        }
        
        final width = MediaQuery.sizeOf(context).width.truncate();
        final adaptiveSize = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);
        
        if (adaptiveSize == null) {
          if (kDebugMode) {
            print('❌ BANNER AD: Unable to get anchored adaptive banner size');
          }
          _isLoading = false;
          return;
        }
        
        adSize = adaptiveSize;
        if (kDebugMode) {
          print('✅ BANNER AD: Got anchored adaptive size: ${adSize.width}x${adSize.height}');
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ BANNER AD: Error getting adaptive size: $e');
        }
        _isLoading = false;
        return;
      }
      _isLoading = false;
    } else {
      adSize = widget.adSize ?? AdSize.banner;
    }
    
    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (kDebugMode) {
            print('✅ BANNER AD: Ad loaded successfully');
          }
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          if (kDebugMode) {
            print('❌ BANNER AD: Failed to load ad. Error: ${error.message}');
            print('   Error code: ${error.code}');
            print('   Error domain: ${error.domain}');
            print('   Ad unit ID: $adUnitId');
          }
          // Dispose the ad if it fails to load
          ad.dispose();
          if (mounted) {
            setState(() {
              _isAdLoaded = false;
            });
          }
        },
        onAdOpened: (_) {
          if (kDebugMode) {
            print('📂 BANNER AD: Ad opened');
          }
        },
        onAdClosed: (_) {
          if (kDebugMode) {
            print('🔒 BANNER AD: Ad closed, reloading...');
          }
          // Ad closed, reload a new ad
          _loadAd();
        },
        onAdImpression: (_) {
          if (kDebugMode) {
            print('👁️ BANNER AD: Ad recorded an impression');
          }
        },
        onAdClicked: (_) {
          if (kDebugMode) {
            print('🖱️ BANNER AD: Ad was clicked');
          }
        },
      ),
    );

    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show a placeholder container with minimum height while ad is loading
    if (!_isAdLoaded || _bannerAd == null) {
      if (kDebugMode) {
        return Container(
          margin: widget.margin ?? EdgeInsets.zero,
          height: 50, // Minimum height for banner ad
          alignment: Alignment.center,
          child: const SizedBox.shrink(), // Hide in debug, but reserve space
        );
      }
      return const SizedBox.shrink();
    }

    return Container(
      margin: widget.margin ?? EdgeInsets.zero,
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}

