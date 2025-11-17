import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_connect/core/strings/get_started_screens_app_strings.dart';
import '../model/get_started_model.dart';

class GetStartedViewModel extends GetxController {
  final data = GetStartedModel(
    title: AppStrings.appTitle,
    subtitle: AppStrings.subtitle,
  );

  void onGetStartedClick() {
    Get.snackbar(
      AppStrings.getStarted,
      AppStrings.stillInDevelopment,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      backgroundColor: Colors.black.withOpacity(0.85),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }
}
