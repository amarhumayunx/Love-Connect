import 'package:flutter/material.dart';
import 'package:love_connect/core/strings/get_started_screens_app_strings.dart';

class GetStartedIllustration extends StatelessWidget {
  final double size;
  final BoxFit fit;

  const GetStartedIllustration({
    super.key,
    required this.size,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppStrings.heart_logo_strings,
      width: size,
      height: size,
      fit: fit,
    );
  }
}
