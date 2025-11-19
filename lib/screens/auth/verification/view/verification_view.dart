import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:love_connect/core/colors/app_colors.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive values based on screen size
    final double horizontalPadding = screenWidth * 0.05;
    final double topSpacing = screenHeight * 0.02;
    final double titleSpacing = screenHeight * 0.03;
    final double otpSpacing = screenHeight * 0.04;
    final double buttonSpacing = screenHeight * 0.035;

    return Scaffold(
      backgroundColor: AppColors.backgroundPink,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: topSpacing,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button
                IconButton(
                  onPressed: Get.back,
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  color: AppColors.backArrow,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),

                SizedBox(height: titleSpacing),

                // Title and subtitle
                Center(
                  child: Column(
                    children: [
                      Text(
                        viewModel.model.title,
                        style: GoogleFonts.inter(
                          fontSize: screenWidth * 0.07,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDarkPink,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
                        child: Text(
                          widget.email != null
                              ? '${viewModel.model.subtitle} sent to ${widget.email}'
                              : viewModel.model.subtitle,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: screenWidth * 0.038,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textLightPink,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: otpSpacing),

                // OTP Boxes
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      viewModel.otpControllers.length,
                          (index) => _OtpBox(
                        controller: viewModel.otpControllers[index],
                        focusNode: viewModel.focusNodes[index],
                        onChanged: (value) =>
                            viewModel.onChangedOtp(value, index),
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: buttonSpacing),

                // Verify button
                SizedBox(
                  width: double.infinity, // FULL width
                  height: MediaQuery.of(context).size.height * 0.06, // around 48px
                  child: ElevatedButton(
                    onPressed: viewModel.onVerifyTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      viewModel.model.verifyButtonText,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.width * 0.045,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
  final double screenWidth;
  final double screenHeight;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    // Responsive OTP box size
    final double boxSize = screenWidth * 0.14;
    final double fontSize = screenWidth * 0.08;
    final double borderRadius = boxSize * 0.1;

    return Container(
      width: boxSize,
      height: boxSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        maxLength: 1,
        textAlign: TextAlign.center,
        onChanged: onChanged,
        cursorColor: AppColors.textFieldBorder,
        cursorWidth: 2.0,
        cursorHeight: fontSize * 0.8,
        style: GoogleFonts.inter(
          fontSize: fontSize,
          fontWeight: FontWeight.w400,
          color: AppColors.textFieldBorder,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: AppColors.backgroundPink,
          contentPadding: EdgeInsets.zero,

          // Default border (unfocused)
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(
              color: AppColors.textFieldBorder,
              width: 1.5,
            ),
          ),

          // Focused border
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(
              color: AppColors.textFieldBorder,
              width: 2.0,
            ),
          ),

          // Error border
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: const BorderSide(
              color: AppColors.textFieldBorder,
              width: 1.5,
            ),
          ),

          // Focused error border
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: const BorderSide(
              color: AppColors.textFieldBorder,
              width: 2.0,
            ),
          ),
        ),
      ),
    );
  }
}