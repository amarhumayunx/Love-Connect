import 'package:flutter/material.dart';
import 'package:love_connect/core/colors/app_colors.dart';

class SplashLogo extends StatelessWidget {
  final double size;
  final String assetPath;

  const SplashLogo({
    super.key,
    required this.size,
    this.assetPath = 'assets/images/splash_screen_logo.jpg',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
        alignment: Alignment.topCenter,
        filterQuality: FilterQuality.high,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.error,
            size: size * 0.5,
            color: AppColors.primaryRed,
          );
        },
      ),
    );
  }
}
