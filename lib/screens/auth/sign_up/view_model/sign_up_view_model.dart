import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_connect/core/navigation/smooth_transitions.dart';
import 'package:love_connect/core/strings/auth_strings.dart';
import 'package:love_connect/core/utils/snackbar_helper.dart';
import 'package:love_connect/core/services/auth/auth_service.dart';
import 'package:love_connect/screens/auth/common/models/social_button_model.dart';
import 'package:love_connect/screens/auth/login/view/login_view.dart';
import 'package:love_connect/screens/auth/sign_up/model/sign_up_model.dart';
import 'package:love_connect/screens/auth/verification/view/verification_view.dart';
import 'package:love_connect/screens/home/view/main_navigation_view.dart';

import '../../../../core/models/auth/auth_result.dart';

class SignUpViewModel extends GetxController {
  final SignUpModel model = const SignUpModel();
  final AuthService _authService = AuthService();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;
  final RxBool isLoading = false.obs;

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
      final result = await _authService.signUpWithEmailPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
        displayName: nameController.text.trim(),
      );

      if (result.success) {
        // Show success message
        SnackbarHelper.showSafe(
          title: 'Account Created',
          message: 'Please verify your email address. A verification email has been sent.',
          duration: const Duration(seconds: 4),
        );

        // Navigate to verification screen after successful signup
        SmoothNavigator.offAll(
          () => VerificationView(email: emailController.text.trim()),
          transition: Transition.fadeIn,
          duration: SmoothNavigator.slowDuration,
        );
      } else {
        SnackbarHelper.showSafe(
          title: 'Sign Up Failed',
          message: result.errorMessage ?? 'An error occurred. Please try again.',
        );
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
          result = await _authService.signUpWithGoogle();
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
        // Navigate to home screen with navbar after successful signup
        SmoothNavigator.offAll(
          () => const MainNavigationView(),
          transition: Transition.fadeIn,
          duration: SmoothNavigator.slowDuration,
        );
      } else {
        // Only show error if user didn't cancel
        if (result.errorCode != 'sign-in-canceled') {
          SnackbarHelper.showSafe(
            title: '${provider.tooltip} Failed',
            message: result.errorMessage ?? 'An error occurred. Please try again.',
          );
        }
      }
    } finally {
      isLoading.value = false;
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
}
