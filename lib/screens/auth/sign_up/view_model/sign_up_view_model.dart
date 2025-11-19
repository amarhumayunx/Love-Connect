import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_connect/core/navigation/smooth_transitions.dart';
import 'package:love_connect/core/strings/auth_strings.dart';
import 'package:love_connect/screens/auth/common/models/social_button_model.dart';
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

  void onSocialTap(SocialButtonModel provider) {
    Get.snackbar(
      provider.tooltip,
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
