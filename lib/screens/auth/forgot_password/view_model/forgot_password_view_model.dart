import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_connect/core/navigation/smooth_transitions.dart';
import 'package:love_connect/core/utils/snackbar_helper.dart';
import 'package:love_connect/core/services/auth/auth_service.dart';
import 'package:love_connect/screens/auth/forgot_password/model/forgot_password_model.dart';
import 'package:love_connect/screens/auth/verification/view/verification_view.dart';

class ForgotPasswordViewModel extends GetxController {
  final ForgotPasswordModel model = const ForgotPasswordModel();
  final AuthService _authService = AuthService();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final RxBool isLoading = false.obs;

  Future<void> onSendCode() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (isLoading.value) return;

    isLoading.value = true;

    try {
      final result = await _authService.sendPasswordResetEmail(
        emailController.text.trim(),
      );

      if (result.success) {
        SnackbarHelper.showSafe(
          title: 'Email Sent',
          message: 'Password reset email has been sent. Please check your inbox.',
          duration: const Duration(seconds: 4),
        );
        // Navigate to verification screen
        SmoothNavigator.to(
          () => VerificationView(email: emailController.text),
          transition: Transition.downToUp,
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
    emailController.dispose();
    super.onClose();
  }
}
