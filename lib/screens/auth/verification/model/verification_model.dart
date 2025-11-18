import 'package:love_connect/core/strings/auth_strings.dart';

class VerificationModel {
  final String title;
  final String subtitle;
  final String verifyButtonText;
  final String resendText;

  const VerificationModel({
    this.title = AuthStrings.verificationTitle,
    this.subtitle = AuthStrings.verificationSubtitle,
    this.verifyButtonText = AuthStrings.verifyCode,
    this.resendText = AuthStrings.resendCode,
  });
}

