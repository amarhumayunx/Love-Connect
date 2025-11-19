import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_connect/core/colors/app_colors.dart';

class ForgotPasswordBackButton extends StatelessWidget {
  const ForgotPasswordBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: Get.back,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
      color: AppColors.backArrow,
    );
  }
}
