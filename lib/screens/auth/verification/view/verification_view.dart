import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/core/utils/media_query_extensions.dart';
import 'package:love_connect/screens/auth/verification/view_model/verification_view_model.dart';

class VerificationView extends StatefulWidget {
  final String? email;

  const VerificationView({super.key, this.email});

  @override
  State<VerificationView> createState() => _VerificationViewState();
}

class _VerificationViewState extends State<VerificationView> {
  late final VerificationViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Get.put(VerificationViewModel());
  }

  @override
  void dispose() {
    Get.delete<VerificationViewModel>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double horizontalPadding = context.widthPct(8);
    final double spacingLarge = context.responsiveSpacing(30);
    final double spacingMedium = context.responsiveSpacing(18);

    return Scaffold(
      backgroundColor: AppColors.backgroundPink,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: spacingLarge,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: Get.back,
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                color: AppColors.primaryRed,
              ),
              SizedBox(height: spacingMedium),
              Center(
                child: Column(
                  children: [
                    Text(
                      viewModel.model.title,
                      style: GoogleFonts.inter(
                        fontSize: context.responsiveFont(28),
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDarkPink,
                      ),
                    ),
                    SizedBox(height: context.responsiveSpacing(8)),
                    Text(
                      widget.email != null
                          ? '${viewModel.model.subtitle} sent to ${widget.email}'
                          : viewModel.model.subtitle,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: context.responsiveFont(15),
                        fontWeight: FontWeight.w500,
                        color: AppColors.textLightPink,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: spacingLarge),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  viewModel.otpControllers.length,
                  (index) => _OtpBox(
                    controller: viewModel.otpControllers[index],
                    focusNode: viewModel.focusNodes[index],
                    onChanged: (value) =>
                        viewModel.onChangedOtp(value, index),
                  ),
                ),
              ),
              SizedBox(height: spacingLarge),
              SizedBox(
                width: double.infinity,
                height: context.responsiveButtonHeight(),
                child: ElevatedButton(
                  onPressed: viewModel.onVerifyTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    viewModel.model.verifyButtonText,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: context.responsiveFont(16),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: spacingMedium),
              Center(
                child: TextButton(
                  onPressed: viewModel.onResendTap,
                  child: Text(
                    viewModel.model.resendText,
                    style: GoogleFonts.inter(
                      color: AppColors.primaryRed,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final double size = context.widthPct(12);
    return SizedBox(
      width: size,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        maxLength: 1,
        textAlign: TextAlign.center,
        onChanged: onChanged,
        style: GoogleFonts.inter(
          fontSize: context.responsiveFont(20),
          fontWeight: FontWeight.w700,
          color: AppColors.textDarkPink,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: AppColors.primaryRed),
          ),
        ),
      ),
    );
  }
}

