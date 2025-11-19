import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/screens/auth/common/widgets/auth_header.dart';
import 'package:love_connect/screens/auth/common/widgets/auth_primary_button.dart';
import 'package:love_connect/screens/auth/verification/view/widgets/verification_back_button.dart';
import 'package:love_connect/screens/auth/verification/view/widgets/verification_layout_metrics.dart';
import 'package:love_connect/screens/auth/verification/view/widgets/verification_otp_row.dart';
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
                        ? '${viewModel.model.subtitle} sent to ${widget.email}'
                        : viewModel.model.subtitle,
                    titleFontSize: metrics.titleFontSize,
                    subtitleFontSize: metrics.subtitleFontSize,
                    spacing: metrics.topSpacing * 0.5,
                  ),
                ),

                SizedBox(height: metrics.otpSpacing),

                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenSize.width * 0.02,
                  ),
                  child: VerificationOtpRow(
                    viewModel: viewModel,
                    screenWidth: screenSize.width,
                    screenHeight: screenSize.height,
                  ),
                ),

                SizedBox(height: metrics.buttonSpacing),

                AuthPrimaryButton(
                  label: viewModel.model.verifyButtonText,
                  onPressed: viewModel.onVerifyTap,
                  height: screenSize.height * 0.06,
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
}
