import 'package:love_connect/core/strings/auth_strings.dart';

class ForgotPasswordModel {
  final String title;
  final String subtitle;
  final String emailHint;

  const ForgotPasswordModel({
    this.title = AuthStrings.forgotPasswordTitle,
    this.subtitle = AuthStrings.forgotPasswordSubtitle,
    this.emailHint = AuthStrings.emailHint,
  });
}
