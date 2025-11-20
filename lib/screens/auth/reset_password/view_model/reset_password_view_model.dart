import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_connect/core/navigation/smooth_transitions.dart';
import 'package:love_connect/core/strings/auth_strings.dart';
import 'package:love_connect/core/utils/snackbar_helper.dart';
import 'package:love_connect/screens/auth/reset_password/model/reset_password_model.dart';

class ResetPasswordViewModel extends GetxController {
  final ResetPasswordModel model = const ResetPasswordModel();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
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

  void onResetPasswordTap() {
    if (!(formKey.currentState?.validate() ?? false)) return;

    SnackbarHelper.showSafe(
      title: AuthStrings.resetPassword,
      message: AuthStrings.passwordResetSuccess,
    );

    // Navigate back after successful reset
    SmoothNavigator.back();
  }

  @override
  void onClose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}

