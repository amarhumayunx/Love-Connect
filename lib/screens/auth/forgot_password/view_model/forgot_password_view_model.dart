import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_connect/core/navigation/smooth_transitions.dart';
import 'package:love_connect/core/strings/auth_strings.dart';
import 'package:love_connect/screens/auth/forgot_password/model/forgot_password_model.dart';
import 'package:love_connect/screens/auth/verification/view/verification_view.dart';

class ForgotPasswordViewModel extends GetxController {
  final ForgotPasswordModel model = const ForgotPasswordModel();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();

  void onSendCode() {
    if (!(formKey.currentState?.validate() ?? false)) return;

    Get.snackbar(
      AuthStrings.sendCode,
      AuthStrings.codeSent,
      snackPosition: SnackPosition.BOTTOM,
    );
    SmoothNavigator.to(
      () => VerificationView(email: emailController.text),
      transition: Transition.downToUp,
    );
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
