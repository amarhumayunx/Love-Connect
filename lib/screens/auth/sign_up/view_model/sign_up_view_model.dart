import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_connect/core/strings/auth_strings.dart';
import 'package:love_connect/screens/auth/login/view/login_view.dart';
import 'package:love_connect/screens/auth/sign_up/model/sign_up_model.dart';

class SignUpViewModel extends GetxController {
  final SignUpModel model = const SignUpModel();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  void onSignUpTap() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    Get.snackbar(
      AuthStrings.signUp,
      AuthStrings.featurePending,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void onLoginTap() {
    if (Get.previousRoute.isNotEmpty) {
      Get.back();
    } else {
      Get.off(() => const LoginView());
    }
  }

  void onSocialTap(String provider) {
    Get.snackbar(
      provider,
      AuthStrings.featurePending,
      snackPosition: SnackPosition.BOTTOM,
    );
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

