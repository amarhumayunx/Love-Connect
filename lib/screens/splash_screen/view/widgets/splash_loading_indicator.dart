import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:love_connect/core/colors/app_colors.dart';

class SplashLoadingIndicator extends StatelessWidget {
  final double size;

  const SplashLoadingIndicator({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return LoadingAnimationWidget.staggeredDotsWave(
      color: AppColors.primaryRed,
      size: size,
    );
  }
}
