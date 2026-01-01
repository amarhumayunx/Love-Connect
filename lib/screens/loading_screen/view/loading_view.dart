import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/core/utils/media_query_extensions.dart';
import '../view_model/loading_view_model.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(LoadingViewModel());
    final LoadingViewModel viewModel = Get.find<LoadingViewModel>();

    return Scaffold(
      backgroundColor: AppColors.backgroundPink,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Loading Animation
              LoadingAnimationWidget.inkDrop(
                color: AppColors.primaryDark,
                size: context.responsiveImage(60),
              ),
              SizedBox(height: context.responsiveSpacing(30)),
              // Loading Text
              Text(
                'Opening your app',
                style: TextStyle(
                  fontSize: context.responsiveFont(18),
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDark,
                ),
              ),
              SizedBox(height: context.responsiveSpacing(10)),
              Text(
                'Loading your data...',
                style: TextStyle(
                  fontSize: context.responsiveFont(14),
                  fontWeight: FontWeight.w400,
                  color: AppColors.textLightPink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

