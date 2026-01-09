import 'package:get/get.dart';
import 'package:love_connect/core/navigation/smooth_transitions.dart';
import 'package:love_connect/core/services/auth/auth_service.dart';
import '../../auth/verification/view/verification_view.dart';
import '../../auth/login/view/login_view.dart';
import '../../home/view/main_navigation_view.dart';

class LoadingViewModel extends GetxController {
  final AuthService _authService = AuthService();

  @override
  void onInit() {
    super.onInit();
    checkAuthenticationAndNavigate();
  }

  Future<void> checkAuthenticationAndNavigate() async {
    try {
      // Small delay to show loading animation
      await Future.delayed(const Duration(milliseconds: 500));

      // Check if user is authenticated
      bool isAuthenticated = false;
      try {
        isAuthenticated = _authService.isAuthenticated;
      } catch (e) {
        // If auth check fails, assume not authenticated
        isAuthenticated = false;
      }

      if (isAuthenticated) {
        // User is logged in, check if email is verified
        // Reload user data (handles network errors gracefully)
        try {
          await _authService.reloadUser();
        } catch (e) {
          // If reload fails, continue with cached user data
          // The _safeReloadUser method already handles most errors gracefully
        }

        final isVerified = _authService.isEmailVerified;
        final userEmail = _authService.currentUser?.email;

        // Small delay to ensure smooth transition
        await Future.delayed(const Duration(milliseconds: 300));

        try {
          if (!isVerified) {
            // Account exists but not verified, navigate to verification screen
            SmoothNavigator.offAll(
              () => VerificationView(email: userEmail),
              transition: Transition.fadeIn,
              duration: SmoothNavigator.slowDuration,
            );
          } else {
            // User is logged in and verified, go directly to home with navbar
            SmoothNavigator.offAll(
              () => const MainNavigationView(),
              transition: Transition.fadeIn,
              duration: SmoothNavigator.slowDuration,
            );
          }
        } catch (e) {
          // If navigation fails, try to go to home directly
          try {
            SmoothNavigator.offAll(
              () => const MainNavigationView(),
              transition: Transition.fadeIn,
              duration: SmoothNavigator.slowDuration,
            );
          } catch (_) {
            // If that also fails, go to login
            SmoothNavigator.offAll(
              () => const LoginView(),
              transition: Transition.fadeIn,
              duration: SmoothNavigator.slowDuration,
            );
          }
        }
      } else {
        // This shouldn't happen as loading screen should only show for authenticated users
        // But if it does, navigate to login
        SmoothNavigator.offAll(
          () => const LoginView(),
          transition: Transition.fadeIn,
          duration: SmoothNavigator.slowDuration,
        );
      }
    } catch (e) {
      // If anything fails, navigate to login screen as fallback
      try {
        SmoothNavigator.offAll(
          () => const LoginView(),
          transition: Transition.fadeIn,
          duration: SmoothNavigator.slowDuration,
        );
      } catch (_) {
        // If navigation itself fails, do nothing
        // User will see loading screen
      }
    }
  }
}
