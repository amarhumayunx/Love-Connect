import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:love_connect/core/navigation/smooth_transitions.dart';
import 'package:love_connect/core/strings/get_started_screens_app_strings.dart';
import 'package:love_connect/core/services/app_preferences_service.dart';
import 'package:love_connect/screens/auth/login/view/login_view.dart';
import '../model/get_started_model.dart';

class GetStartedViewModel extends GetxController {
  final data = GetStartedModel(
    title: AppStrings.appTitle,
    subtitle: AppStrings.subtitle,
    highlights: AppStrings.highlights,
  );

  final RxBool isNavigating = false.obs;
  final AppPreferencesService _prefsService = AppPreferencesService();

  Future<void> onGetStartedClick() async {
    if (isNavigating.value) return;
    isNavigating.value = true;
    await HapticFeedback.lightImpact();

    await _prefsService.setHasSeenGetStarted();
    await _prefsService.setNotFirstTime();
    
    await Future.delayed(const Duration(milliseconds: 220));
    await SmoothNavigator.off(
      () => const LoginView(),
      transition: Transition.cupertino,
      duration: SmoothNavigator.extraSlowDuration,
      curve: SmoothNavigator.smoothCurve,
    );
    isNavigating.value = false;
  }
}
