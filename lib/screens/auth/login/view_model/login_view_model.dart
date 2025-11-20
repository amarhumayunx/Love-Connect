import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_connect/core/navigation/smooth_transitions.dart';
import 'package:love_connect/core/strings/auth_strings.dart';
import 'package:love_connect/core/utils/snackbar_helper.dart';
import 'package:love_connect/core/services/auth/auth_service.dart';
import 'package:love_connect/core/services/app_preferences_service.dart';
import 'package:love_connect/screens/auth/common/models/social_button_model.dart';
import 'package:love_connect/screens/auth/forgot_password/view/forgot_password_view.dart';
import 'package:love_connect/screens/auth/login/model/login_model.dart';
import 'package:love_connect/screens/auth/sign_up/view/sign_up_view.dart';
import 'package:love_connect/screens/home/view/home_view.dart';

import '../../../../core/models/auth/auth_result.dart';

class LoginViewModel extends GetxController {
  final LoginModel model = const LoginModel();
  final AuthService _authService = AuthService();
  final AppPreferencesService _prefsService = AppPreferencesService();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxBool rememberMe = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadRememberedEmail();
  }

  /// Load remembered email if "Remember Me" was previously checked
  Future<void> _loadRememberedEmail() async {
    final rememberedEmail = await _prefsService.getRememberedEmail();
    final isRememberMeEnabled = await _prefsService.isRememberMeEnabled();
    
    if (rememberedEmail != null && rememberedEmail.isNotEmpty) {
      emailController.text = rememberedEmail;
      rememberMe.value = isRememberMeEnabled;
    }
  }

  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
    
    // If user unchecks "Remember Me", clear saved email
    if (!rememberMe.value) {
      _prefsService.clearRememberedEmail();
    }
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> onLoginTap() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (isLoading.value) return;

    isLoading.value = true;

    try {
      final email = emailController.text.trim();
      final result = await _authService.signInWithEmailPassword(
        email: email,
        password: passwordController.text,
      );

      if (result.success) {
        // Save email if "Remember Me" is checked
        if (rememberMe.value) {
          await _prefsService.saveRememberedEmail(email);
        } else {
          // Clear saved email if "Remember Me" is unchecked
          await _prefsService.clearRememberedEmail();
        }
        
        // Navigate to home screen after successful login
        SmoothNavigator.offAll(
          () => const HomeView(),
          transition: Transition.fadeIn,
          duration: SmoothNavigator.slowDuration,
        );
      } else {
        // Show user-friendly error message for authentication failures
        String errorMessage = 'Wrong email or password';
        
        // Check for specific error codes that indicate wrong credentials
        if (result.errorCode == 'user-not-found' || 
            result.errorCode == 'wrong-password' ||
            result.errorCode == 'invalid-credential' ||
            result.errorCode == 'invalid-email') {
          errorMessage = 'Wrong email or password';
        } else if (result.errorMessage != null) {
          // For other errors, show the specific error message
          errorMessage = result.errorMessage!;
        }
        
        SnackbarHelper.showSafe(
          title: 'Login Failed',
          message: errorMessage,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  void onForgotPasswordTap() {
    SmoothNavigator.to(
      () => const ForgotPasswordView(),
      transition: Transition.downToUp,
    );
  }

  Future<void> onSocialTap(SocialButtonModel provider) async {
    if (isLoading.value) return;

    isLoading.value = true;

    try {
      AuthResult result;

      switch (provider.type) {
        case SocialButtonType.google:
          result = await _authService.signInWithGoogle();
          break;
        case SocialButtonType.apple:
          result = await _authService.signInWithApple();
          break;
        default:
          SnackbarHelper.showSafe(
            title: provider.tooltip,
            message: AuthStrings.featurePending,
          );
          return;
      }

      if (result.success) {
        // Navigate to home screen after successful login
        SmoothNavigator.offAll(
          () => const HomeView(),
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

  void onSignUpTap() {
    SmoothNavigator.to(
      () => const SignUpView(),
      transition: Transition.cupertino,
      duration: SmoothNavigator.extraSlowDuration,
      curve: SmoothNavigator.smoothCurve,
    );
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
