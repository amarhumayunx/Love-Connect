import 'package:flutter/material.dart';
import 'package:love_connect/core/strings/get_started_screens_app_strings.dart';

class GetStartedLogo extends StatelessWidget {
  final double width;
  final double height;
  final BoxFit fit;

  const GetStartedLogo({
    super.key,
    required this.width,
    required this.height,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppStrings.app_logo_strings,
      width: width,
      height: height,
      fit: fit,
    );
  }
}
