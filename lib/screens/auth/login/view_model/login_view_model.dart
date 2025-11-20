import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_connect/core/navigation/smooth_transitions.dart';
import 'package:love_connect/core/strings/auth_strings.dart';
import 'package:love_connect/core/utils/snackbar_helper.dart';
import 'package:love_connect/screens/auth/common/models/social_button_model.dart';
import 'package:love_connect/screens/auth/forgot_password/view/forgot_password_view.dart';
import 'package:love_connect/screens/auth/login/model/login_model.dart';
import 'package:love_connect/screens/auth/sign_up/view/sign_up_view.dart';
import 'package:love_connect/screens/home/view/home_view.dart';

class LoginViewModel extends GetxController {
  final LoginModel model = const LoginModel();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxBool rememberMe = false.obs;
  final RxBool obscurePassword = true.obs;

  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void onLoginTap() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    
    // Navigate to home screen after successful login
    SmoothNavigator.offAll(
      () => const HomeView(),
      transition: Transition.fadeIn,
      duration: SmoothNavigator.slowDuration,
    );
  }

  void onForgotPasswordTap() {
    SmoothNavigator.to(
      () => const ForgotPasswordView(),
      transition: Transition.downToUp,
    );
  }

  void onSocialTap(SocialButtonModel provider) {
    SnackbarHelper.showSafe(
      title: provider.tooltip,
      message: AuthStrings.featurePending,
    );
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
