import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_connect/core/colors/app_colors.dart';

class VerificationBackButton extends StatelessWidget {
  const VerificationBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: Get.back,
      icon: const Icon(Icons.arrow_back_ios_new_rounded),
      color: AppColors.backArrow,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }
}
