import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:love_connect/core/navigation/smooth_transitions.dart';
import 'package:love_connect/core/utils/snackbar_helper.dart';
import 'package:love_connect/core/services/auth/auth_service.dart';
import 'package:love_connect/core/services/user_database_service.dart';
import 'package:love_connect/screens/auth/verification/model/verification_model.dart';
import 'package:love_connect/screens/home/view/main_navigation_view.dart';

class VerificationViewModel extends GetxController {
  final VerificationModel model = const VerificationModel();
  final AuthService _authService = AuthService();
  final UserDatabaseService _userDbService = UserDatabaseService();
  final RxString statusMessage = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isChecking = false.obs;
  Timer? _verificationCheckTimer;
  StreamSubscription<User?>? _authStateSubscription;
  bool _isNavigating = false;

  @override
  void onInit() {
    super.onInit();
    // Start real-time verification check using auth state changes
    _startAuthStateListener();
    // Also start periodic check as backup
    _startVerificationCheck();
  }

  /// Listen to auth state changes for real-time verification detection
  void _startAuthStateListener() {
    _authStateSubscription = _authService.authStateChanges.listen(
      (User? user) async {
        if (user != null && !_isNavigating) {
          await _checkEmailVerification();
        }
      },
      onError: (error) {
        // Silently handle errors
      },
    );
  }

  void _startVerificationCheck() {
    // Check every 3 seconds as backup
    _verificationCheckTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _checkEmailVerification(),
    );
  }

  Future<void> _checkEmailVerification() async {
    if (isChecking.value || _isNavigating) return;

    isChecking.value = true;

    try {
      await _authService.reloadUser();
      final isVerified = _authService.isEmailVerified;

      if (isVerified) {
        _isNavigating = true;
        _verificationCheckTimer?.cancel();
        _authStateSubscription?.cancel();
        
        // Update verification status in database
        final userId = _authService.currentUserId;
        if (userId != null) {
          await _userDbService.updateEmailVerificationStatus(
            userId: userId,
            isVerified: true,
          );
        }
        
        // Small delay to ensure UI updates
        await Future.delayed(const Duration(milliseconds: 500));
        
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
    } finally {
      isChecking.value = false;
    }
  }

  Future<void> onVerifyTap() async {
    if (isLoading.value || _isNavigating) return;

    isLoading.value = true;
    isChecking.value = true;

    try {
      await _authService.reloadUser();
      final isVerified = _authService.isEmailVerified;

      if (isVerified) {
        _isNavigating = true;
        _verificationCheckTimer?.cancel();
        _authStateSubscription?.cancel();
        
        // Update verification status in database
        final userId = _authService.currentUserId;
        if (userId != null) {
          await _userDbService.updateEmailVerificationStatus(
            userId: userId,
            isVerified: true,
          );
        }
        
        // Small delay to ensure UI updates
        await Future.delayed(const Duration(milliseconds: 500));
        
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
          message: 'Please check your email and click the verification link. The app will automatically detect when you verify.',
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
    _authStateSubscription?.cancel();
    super.onClose();
  }
}
