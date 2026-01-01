import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:love_connect/core/services/admob_service.dart';

/// Widget for displaying banner ads
class BannerAdWidget extends StatefulWidget {
  final AdSize? adSize;
  final EdgeInsets? margin;
  final String? adUnitId;

  const BannerAdWidget({
    super.key,
    this.adSize,
    this.margin,
    this.adUnitId,
  });

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    final adUnitId = widget.adUnitId ?? AdMobService.instance.bannerAdUnitId;
    
    if (kDebugMode) {
      print('📱 BANNER AD: Loading ad with unit ID: $adUnitId');
    }
    
    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: widget.adSize ?? AdSize.banner,
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

