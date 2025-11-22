import 'dart:async';
import 'package:get/get.dart';
import 'package:love_connect/core/navigation/smooth_transitions.dart';
import 'package:love_connect/core/utils/snackbar_helper.dart';
import 'package:love_connect/core/services/auth/auth_service.dart';
import 'package:love_connect/screens/auth/verification/model/verification_model.dart';
import 'package:love_connect/screens/home/view/main_navigation_view.dart';

class VerificationViewModel extends GetxController {
  final VerificationModel model = const VerificationModel();
  final AuthService _authService = AuthService();
  final RxString statusMessage = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isChecking = false.obs;
  Timer? _verificationCheckTimer;

  @override
  void onInit() {
    super.onInit();
    // Start periodic check for email verification
    _startVerificationCheck();
  }

  void _startVerificationCheck() {
    // Check every 3 seconds
    _verificationCheckTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _checkEmailVerification(),
    );
  }

  Future<void> _checkEmailVerification() async {
    if (isChecking.value) return;

    try {
      await _authService.reloadUser();
      final isVerified = _authService.isEmailVerified;

      if (isVerified) {
        _verificationCheckTimer?.cancel();
        // Navigate to home screen
        SmoothNavigator.offAll(
          () => const MainNavigationView(),
          transition: Transition.fadeIn,
          duration: SmoothNavigator.slowDuration,
        );
        SnackbarHelper.showSafe(
          title: 'Email Verified',
          message: 'Your email has been successfully verified!',
        );
      }
    } catch (e) {
      // Silently handle errors during automatic check
    }
  }

  Future<void> onVerifyTap() async {
    if (isLoading.value) return;

    isLoading.value = true;
    isChecking.value = true;

    try {
      await _authService.reloadUser();
      final isVerified = _authService.isEmailVerified;

      if (isVerified) {
        _verificationCheckTimer?.cancel();
        // Navigate to home screen
        SmoothNavigator.offAll(
          () => const MainNavigationView(),
          transition: Transition.fadeIn,
          duration: SmoothNavigator.slowDuration,
        );
        SnackbarHelper.showSafe(
          title: 'Email Verified',
          message: 'Your email has been successfully verified!',
        );
      } else {
        SnackbarHelper.showSafe(
          title: 'Not Verified Yet',
          message: 'Please check your email and click the verification link.',
        );
      }
    } catch (e) {
      SnackbarHelper.showSafe(
        title: 'Error',
        message: 'Failed to check verification status. Please try again.',
      );
    } finally {
      isLoading.value = false;
      isChecking.value = false;
    }
  }

  Future<void> onResendTap() async {
    if (isLoading.value) return;

    isLoading.value = true;

    try {
      final result = await _authService.resendEmailVerification();

      if (result.success) {
        SnackbarHelper.showSafe(
          title: 'Email Sent',
          message: 'Verification email has been sent. Please check your inbox.',
          duration: const Duration(seconds: 4),
        );
      } else {
        SnackbarHelper.showSafe(
          title: 'Failed to Send Email',
          message: result.errorMessage ?? 'An error occurred. Please try again.',
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _verificationCheckTimer?.cancel();
    super.onClose();
  }
}
