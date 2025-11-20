import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_connect/core/navigation/smooth_transitions.dart';
import 'package:love_connect/core/strings/auth_strings.dart';
import 'package:love_connect/core/utils/snackbar_helper.dart';
import 'package:love_connect/screens/auth/common/models/social_button_model.dart';
import 'package:love_connect/screens/auth/login/view/login_view.dart';
import 'package:love_connect/screens/auth/sign_up/model/sign_up_model.dart';
import 'package:love_connect/screens/home/view/home_view.dart';

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
    
    // Navigate to home screen after successful signup
    SmoothNavigator.offAll(
      () => const HomeView(),
      transition: Transition.fadeIn,
      duration: SmoothNavigator.slowDuration,
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
    SnackbarHelper.showSafe(
      title: provider.tooltip,
      message: AuthStrings.featurePending,
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
