import 'package:flutter/animation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:love_connect/core/strings/get_started_screens_app_strings.dart';
import 'package:love_connect/screens/auth/login/view/login_view.dart';
import '../model/get_started_model.dart';

class GetStartedViewModel extends GetxController {
  final data = GetStartedModel(
    title: AppStrings.appTitle,
    subtitle: AppStrings.subtitle,
    highlights: AppStrings.highlights,
  );

  final RxBool isNavigating = false.obs;

  Future<void> onGetStartedClick() async {
    if (isNavigating.value) return;
    isNavigating.value = true;
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 220));
    await Get.to(
      () => const LoginView(),
      transition: Transition.cupertinoDialog,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
    isNavigating.value = false;
  }
}
