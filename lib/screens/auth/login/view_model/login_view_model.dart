import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_connect/core/strings/auth_strings.dart';
import 'package:love_connect/screens/auth/forgot_password/view/forgot_password_view.dart';
import 'package:love_connect/screens/auth/sign_up/view/sign_up_view.dart';
import 'package:love_connect/screens/auth/login/model/login_model.dart';

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
    Get.snackbar(
      AuthStrings.login,
      AuthStrings.featurePending,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void onForgotPasswordTap() {
    Get.to(() => const ForgotPasswordView());
  }

  void onSocialTap(String provider) {
    Get.snackbar(
      provider,
      AuthStrings.featurePending,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void onSignUpTap() {
    Get.to(() => const SignUpView());
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

