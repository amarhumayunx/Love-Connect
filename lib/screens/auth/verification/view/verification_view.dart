import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/screens/auth/common/widgets/auth_header.dart';
import 'package:love_connect/screens/auth/common/widgets/auth_primary_button.dart';
import 'package:love_connect/screens/auth/verification/view/widgets/verification_back_button.dart';
import 'package:love_connect/screens/auth/verification/view/widgets/verification_layout_metrics.dart';
import 'package:love_connect/screens/auth/verification/view/widgets/verification_resend_button.dart';
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
    final metrics = VerificationLayoutMetrics.fromContext(context);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.backgroundPink,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: metrics.horizontalPadding,
              vertical: metrics.topSpacing,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const VerificationBackButton(),

                SizedBox(height: metrics.titleSpacing),

                Center(
                  child: AuthHeader(
                    title: viewModel.model.title,
                    subtitle: widget.email != null
                        ? 'We\'ve sent a verification link to ${widget.email}. Please check your email and click the link to verify your account.'
                        : 'We\'ve sent a verification link to your email. Please check your inbox and click the link to verify your account.',
                    titleFontSize: metrics.titleFontSize,
                    subtitleFontSize: metrics.subtitleFontSize,
                    spacing: metrics.topSpacing * 0.5,
                  ),
                ),

                SizedBox(height: metrics.otpSpacing * 2),

                // Email icon illustration
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.email_outlined,
                      size: 60,
                      color: AppColors.primaryRed,
                    ),
                  ),
                ),

                SizedBox(height: metrics.buttonSpacing * 1.5),

                // Instructions
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenSize.width * 0.05,
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Steps to verify:',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: metrics.buttonSpacing * 0.5),
                      _buildInstructionStep('1', 'Check your email inbox', screenSize),
                      SizedBox(height: metrics.buttonSpacing * 0.3),
                      _buildInstructionStep('2', 'Click the verification link', screenSize),
                      SizedBox(height: metrics.buttonSpacing * 0.3),
                      _buildInstructionStep('3', 'Return to this app', screenSize),
                    ],
                  ),
                ),

                SizedBox(height: metrics.buttonSpacing * 1.5),

                Obx(
                  () => AuthPrimaryButton(
                    label: viewModel.model.verifyButtonText,
                    onPressed: () {
                      viewModel.onVerifyTap();
                    },
                    height: screenSize.height * 0.06,
                    isLoading: viewModel.isLoading.value,
                  ),
                ),
                SizedBox(height: screenSize.height * 0.015),
                Center(child: VerificationResendButton(viewModel: viewModel)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text, Size screenSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.primaryRed,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.primaryDark,
            ),
          ),
        ),
      ],
    );
  }
}
