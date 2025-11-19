import 'package:flutter/material.dart';
import 'package:love_connect/core/strings/auth_strings.dart';

class ForgotPasswordIllustration extends StatelessWidget {
  final double height;

  const ForgotPasswordIllustration({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AuthStrings.forgotPasswordIllustration,
      height: height,
      fit: BoxFit.contain,
    );
  }
}
