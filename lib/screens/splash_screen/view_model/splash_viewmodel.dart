import 'package:get/get.dart';
import 'package:love_connect/core/navigation/smooth_transitions.dart';
import 'package:love_connect/core/services/auth/auth_service.dart';
import 'package:love_connect/core/services/app_preferences_service.dart';
import '../../get_started/view/get_started_screen.dart';
import '../../auth/login/view/login_view.dart';
import '../../home/view/home_view.dart';

class SplashViewModel extends GetxController {
  final RxBool isLoading = true.obs;
  final RxBool isFadingOut = false.obs;
  final AuthService _authService = AuthService();
  final AppPreferencesService _prefsService = AppPreferencesService();

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

    // Check authentication state and route accordingly
    final isAuthenticated = _authService.isAuthenticated;
    final isFirstTime = await _prefsService.isFirstTime();
    final hasSeenGetStarted = await _prefsService.hasSeenGetStarted();

    if (isAuthenticated) {
      // User is logged in, go directly to home
      SmoothNavigator.offAll(
        () => const HomeView(),
        transition: Transition.fadeIn,
        duration: SmoothNavigator.slowDuration,
      );
    } else {
      // User is not logged in
      if (isFirstTime || !hasSeenGetStarted) {
        // First time or haven't seen get started, show get started screen
        SmoothNavigator.off(
          () => const GetStartedScreen(),
          transition: Transition.fadeIn,
          duration: SmoothNavigator.slowDuration,
        );
      } else {
        // Not first time, go directly to login
        SmoothNavigator.off(
          () => const LoginView(),
          transition: Transition.fadeIn,
          duration: SmoothNavigator.slowDuration,
        );
      }
    }
  }
}
