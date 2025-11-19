import 'package:flutter/material.dart';
import 'package:love_connect/screens/auth/verification/view/widgets/verification_otp_box.dart';
import 'package:love_connect/screens/auth/verification/view_model/verification_view_model.dart';

class VerificationOtpRow extends StatelessWidget {
  final VerificationViewModel viewModel;
  final double screenWidth;
  final double screenHeight;

  const VerificationOtpRow({
    super.key,
    required this.viewModel,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        viewModel.otpControllers.length,
        (index) => VerificationOtpBox(
          controller: viewModel.otpControllers[index],
          focusNode: viewModel.focusNodes[index],
          onChanged: (value) => viewModel.onChangedOtp(value, index),
          screenWidth: screenWidth,
          screenHeight: screenHeight,
        ),
      ),
    );
  }
}
