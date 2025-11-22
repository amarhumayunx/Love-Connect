import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/screens/auth/verification/view_model/verification_view_model.dart';

class VerificationResendButton extends StatelessWidget {
  final VerificationViewModel viewModel;

  const VerificationResendButton({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => TextButton(
        onPressed: viewModel.isLoading.value ? null : viewModel.onResendTap,
        child: viewModel.isLoading.value
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryRed),
                ),
              )
            : Text(
                viewModel.model.resendText,
                style: GoogleFonts.inter(
                  color: AppColors.primaryRed,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
