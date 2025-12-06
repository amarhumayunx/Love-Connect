import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_connect/core/navigation/smooth_transitions.dart';
import 'package:love_connect/core/strings/auth_strings.dart';
import 'package:love_connect/core/utils/snackbar_helper.dart';
import 'package:love_connect/core/services/auth/auth_service.dart';
import 'package:love_connect/core/services/auth/google_sign_up_service.dart';
import 'package:love_connect/core/services/user_database_service.dart';
import 'package:love_connect/screens/auth/common/models/social_button_model.dart';
import 'package:love_connect/screens/auth/login/view/login_view.dart';
import 'package:love_connect/screens/auth/sign_up/model/sign_up_model.dart';
import 'package:love_connect/screens/auth/verification/view/verification_view.dart';
import 'package:love_connect/screens/home/view/main_navigation_view.dart';

import '../../../../core/models/auth/auth_result.dart';

class SignUpViewModel extends GetxController {
  final SignUpModel model = const SignUpModel();
  final AuthService _authService = AuthService();
  final GoogleSignUpService _googleSignUpService = GoogleSignUpService();
  final UserDatabaseService _userDbService = UserDatabaseService();
  late final GlobalKey<FormState> formKey;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;
  final RxBool isLoading = false.obs;

  SignUpViewModel({String? email}) {
    // Create a unique key for this form instance to avoid conflicts
    formKey = GlobalKey<FormState>();
    // Pre-fill email if provided (e.g., when coming from login screen)
    if (email != null && email.isNotEmpty) {
      emailController.text = email;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  Future<void> onSignUpTap() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (isLoading.value) return;

    isLoading.value = true;

    try {
      final email = emailController.text.trim();
      final password =
          passwordController.text; // Don't trim password - preserve exact input

      // Validate password is not empty
      if (password.isEmpty) {
        SnackbarHelper.showSafe(
          title: 'Sign Up Failed',
          message: 'Password cannot be empty.',
        );
        return;
      }

      // Attempt to sign up - Firebase will handle account creation
      // If email already exists, we'll get 'email-already-in-use' error
      final result = await _authService.signUpWithEmailPassword(
        email: email,
        password: password,
        displayName: nameController.text.trim(),
      );

      if (result.success) {
        // Show success message
        SnackbarHelper.showSafe(
          title: 'Account Created',
          message:
              'Please verify your email address. A verification email has been sent.',
          duration: const Duration(seconds: 4),
        );

        // Navigate to verification screen after successful signup
        SmoothNavigator.offAll(
          () => VerificationView(email: email),
          transition: Transition.fadeIn,
          duration: SmoothNavigator.slowDuration,
        );
      } else {
        // Handle specific error cases
        String errorMessage =
            result.errorMessage ?? 'An error occurred. Please try again.';

        if (result.errorCode == 'email-already-in-use') {
          // Email already exists - redirect to login
          errorMessage =
              'An account with this email already exists. Please sign in instead.';

          SnackbarHelper.showSafe(
            title: 'Account Already Exists',
            message: errorMessage,
            duration: const Duration(seconds: 4),
          );

          // Navigate to login with email pre-filled
          SmoothNavigator.off(
            () => LoginView(email: email),
            transition: Transition.cupertino,
            duration: SmoothNavigator.extraSlowDuration,
            curve: SmoothNavigator.smoothCurve,
          );
          return;
        } else if (result.errorCode == 'weak-password') {
          errorMessage =
              result.errorMessage ??
              'Password is too weak. Please choose a stronger password.';
        } else if (result.errorCode == 'network-request-failed') {
          errorMessage =
              'Network error. Please check your internet connection and try again.';
        }

        SnackbarHelper.showSafe(title: 'Sign Up Failed', message: errorMessage);
      }
    } finally {
      isLoading.value = false;
    }
  }

  void onLoginTap() {
    // Use smooth back navigation for consistent reverse transition
    // Get.back() will automatically reverse the cupertino transition smoothly
    if (Get.previousRoute.isNotEmpty) {
      SmoothNavigator.back();
      return;
    }
    // Fallback: if no previous route, navigate with smooth transition
    SmoothNavigator.off(
      () => const LoginView(),
      transition: Transition.cupertino,
      duration: SmoothNavigator.extraSlowDuration,
      curve: SmoothNavigator.smoothCurve,
    );
  }

  Future<void> onSocialTap(SocialButtonModel provider) async {
    if (isLoading.value) return;

    isLoading.value = true;

    try {
      AuthResult result;

      switch (provider.type) {
        case SocialButtonType.google:
          // Skip database save initially to check if user exists first
          result = await _googleSignUpService.signUp(skipDatabaseSave: true);
          break;
        case SocialButtonType.apple:
          result = await _authService.signUpWithApple();
          break;
        default:
          SnackbarHelper.showSafe(
            title: provider.tooltip,
            message: AuthStrings.featurePending,
          );
          return;
      }

      if (result.success) {
        // Reload user to get latest data
        await _authService.reloadUser();
        final userEmail = _authService.currentUser?.email;
        final userId = _authService.currentUserId;

        if (userEmail == null) {
          // Email is required, sign out and show error
          await _authService.signOut();
          SnackbarHelper.showSafe(
            title: 'Sign Up Failed',
            message: 'Unable to retrieve email address. Please try again.',
          );
          return;
        }

        // Check if user already exists in database
        // If user exists, they should sign in instead
        final userExistsInDb = await _userDbService.checkUserExistsById(
          userId ?? '',
        );

        if (userExistsInDb) {
          // User already exists in database - they should sign in, not sign up
          await _authService.signOut();

          SnackbarHelper.showSafe(
            title: 'Account Already Exists',
            message:
                'An account with this email already exists. Please sign in instead.',
            duration: const Duration(seconds: 4),
          );

          // Navigate to login screen with email pre-filled
          SmoothNavigator.offAll(
            () => LoginView(email: userEmail),
            transition: Transition.cupertino,
            duration: SmoothNavigator.extraSlowDuration,
            curve: SmoothNavigator.smoothCurve,
          );
          return;
        }

        // New user - create account in database
        if (userId != null) {
          final currentUser = _authService.currentUser;
          await _userDbService.saveUserData(
            userId: userId,
            email: userEmail,
            displayName: currentUser?.displayName,
            isEmailVerified: currentUser?.emailVerified ?? false,
          );
        }

        // Check email verification status
        final isVerified = _authService.isEmailVerified;

        // Update verification status in database
        if (userId != null) {
          await _userDbService.updateEmailVerificationStatus(
            userId: userId,
            isVerified: isVerified,
          );
        }

        if (!isVerified) {
          // Account created but not verified, send verification email and navigate to verification screen
          await _authService.resendEmailVerification();

          SmoothNavigator.offAll(
            () => VerificationView(email: userEmail),
            transition: Transition.fadeIn,
            duration: SmoothNavigator.slowDuration,
          );
        } else {
          // Navigate to home screen with navbar after successful signup
          SmoothNavigator.offAll(
            () => const MainNavigationView(),
            transition: Transition.fadeIn,
            duration: SmoothNavigator.slowDuration,
          );
        }
      } else {
        // Only show error if user didn't cancel
        if (result.errorCode != 'sign-up-canceled' &&
            result.errorCode != 'sign-in-canceled') {
          SnackbarHelper.showSafe(
            title: '${provider.tooltip} Failed',
            message:
                result.errorMessage ?? 'An error occurred. Please try again.',
          );
        }
      }
    } finally {
      isLoading.value = false;
    }
  }
}
