import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_connect/core/strings/auth_strings.dart';
import 'package:love_connect/core/utils/snackbar_helper.dart';
import 'package:love_connect/screens/auth/verification/model/verification_model.dart';

class VerificationViewModel extends GetxController {
  final VerificationModel model = const VerificationModel();
  final RxString statusMessage = ''.obs;
  final List<TextEditingController> otpControllers = List.generate(
    5,
    (_) => TextEditingController(),
  );
  final List<FocusNode> focusNodes = List.generate(5, (_) => FocusNode());

  String get otpCode =>
      otpControllers.map((controller) => controller.text).join();

  void onChangedOtp(String value, int index) {
    if (value.length == 1 && index < focusNodes.length - 1) {
      focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
  }

  void onVerifyTap() {
    if (otpCode.length != otpControllers.length) {
      SnackbarHelper.showSafe(
        title: AuthStrings.verifyCode,
        message: 'Enter the complete code',
      );
      return;
    }

    SnackbarHelper.showSafe(
      title: AuthStrings.verifyCode,
      message: AuthStrings.codeVerified,
    );
  }

  void onResendTap() {
    otpControllers.forEach((controller) => controller.clear());
    focusNodes.first.requestFocus();
    SnackbarHelper.showSafe(
      title: AuthStrings.resendCode,
      message: AuthStrings.codeSent,
    );
  }

  @override
  void onClose() {
    for (final controller in otpControllers) {
      controller.dispose();
    }
    for (final node in focusNodes) {
      node.dispose();
    }
    super.onClose();
  }
}
