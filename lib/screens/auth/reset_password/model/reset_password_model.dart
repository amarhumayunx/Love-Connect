import 'package:love_connect/core/strings/auth_strings.dart';

class ResetPasswordModel {
  final String title;
  final String subtitle;
  final String passwordHint;
  final String confirmPasswordHint;

  const ResetPasswordModel({
    this.title = AuthStrings.resetPasswordTitle,
    this.subtitle = AuthStrings.resetPasswordSubtitle,
    this.passwordHint = AuthStrings.newPasswordHint,
    this.confirmPasswordHint = AuthStrings.confirmNewPasswordHint,
  });
}

