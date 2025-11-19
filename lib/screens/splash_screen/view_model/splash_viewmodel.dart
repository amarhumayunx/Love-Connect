import 'package:get/get.dart';
import 'package:love_connect/core/navigation/smooth_transitions.dart';
import '../../get_started/view/get_started_screen.dart';

class SplashViewModel extends GetxController {
  final RxBool isLoading = true.obs;
  final RxBool isFadingOut = false.obs;

  @override
  void onInit() {
    super.onInit();
    navigateToNextScreen();
  }

  // Navigate to next screen after delay with smooth transition
  Future<void> navigateToNextScreen() async {
    // Wait for logo animation to complete (2.5 seconds)
    await Future.delayed(const Duration(milliseconds: 2500));

    isLoading.value = false;

    // Start fade-out animation
    await Future.delayed(const Duration(milliseconds: 200));
    isFadingOut.value = true;

    // Wait for fade-out animation to complete
    await Future.delayed(const Duration(milliseconds: 500));

    // Navigate to get started screen with smooth fade transition
    SmoothNavigator.off(
      () => const GetStartedScreen(),
      transition: Transition.fadeIn,
      duration: SmoothNavigator.slowDuration,
    );
  }
}
