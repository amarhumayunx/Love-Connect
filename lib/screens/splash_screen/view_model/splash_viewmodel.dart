import 'package:get/get.dart';
import 'package:love_connect/core/navigation/smooth_transitions.dart';
import 'package:love_connect/core/services/auth/auth_service.dart';
import 'package:love_connect/core/services/app_preferences_service.dart';
import '../../get_started/view/get_started_screen.dart';
import '../../auth/login/view/login_view.dart';
import '../../auth/verification/view/verification_view.dart';
import '../../home/view/main_navigation_view.dart';
import '../../loading_screen/view/loading_view.dart';

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
    try {
      // Wait for logo animation to complete (2.5 seconds)
      await Future.delayed(const Duration(milliseconds: 2500));

      isLoading.value = false;

      // Start fade-out animation
      await Future.delayed(const Duration(milliseconds: 200));
      isFadingOut.value = true;

      // Wait for fade-out animation to complete
      await Future.delayed(const Duration(milliseconds: 500));

      // Check authentication state and route accordingly
      bool isAuthenticated = false;
      bool isFirstTime = true;
      bool hasSeenGetStarted = false;

      try {
        isAuthenticated = _authService.isAuthenticated;
        isFirstTime = await _prefsService.isFirstTime();
        hasSeenGetStarted = await _prefsService.hasSeenGetStarted();
      } catch (e) {
        // If preference check fails, default to first time flow
        isFirstTime = true;
        hasSeenGetStarted = false;
      }

      if (isAuthenticated && !isFirstTime) {
        // User is logged in AND it's not first run - navigate to loading screen
        // Loading screen will handle authentication checks and data loading
        // This only happens after first run (not on first run)
        SmoothNavigator.offAll(
          () => const LoadingView(),
          transition: Transition.fadeIn,
          duration: SmoothNavigator.slowDuration,
        );
      } else if (isAuthenticated && isFirstTime) {
        // User is authenticated but it's still first run
        // Skip loading screen and go directly to home (first run flow)
        try {
          await _authService.reloadUser();
        } catch (e) {
          // If reload fails, continue with cached user data
        }

        final isVerified = _authService.isEmailVerified;
        final userEmail = _authService.currentUser?.email;

        if (!isVerified) {
          SmoothNavigator.offAll(
            () => VerificationView(email: userEmail),
            transition: Transition.fadeIn,
            duration: SmoothNavigator.slowDuration,
          );
        } else {
          SmoothNavigator.offAll(
            () => const MainNavigationView(),
            transition: Transition.fadeIn,
            duration: SmoothNavigator.slowDuration,
          );
        }
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
    } catch (e) {
      // If navigation fails, default to login screen
      try {
        SmoothNavigator.offAll(
          () => const LoginView(),
          transition: Transition.fadeIn,
          duration: SmoothNavigator.slowDuration,
        );
      } catch (_) {
        // If navigation itself fails, try get started screen
        try {
          SmoothNavigator.offAll(
            () => const GetStartedScreen(),
            transition: Transition.fadeIn,
            duration: SmoothNavigator.slowDuration,
          );
        } catch (_) {
          // Last resort: do nothing and let user see splash screen
        }
      }
    }
  }
}
