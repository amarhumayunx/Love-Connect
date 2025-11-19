import 'package:flutter/material.dart';
import 'package:love_connect/core/strings/get_started_screens_app_strings.dart';

class LoginLogo extends StatelessWidget {
  final double height;

  const LoginLogo({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return Image.asset(AppStrings.heart_logo_strings, height: height);
  }
}
