import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/core/strings/auth_strings.dart';
import 'package:love_connect/screens/auth/sign_up/view_model/sign_up_view_model.dart';

class SignUpLoginRedirect extends StatelessWidget {
  final SignUpViewModel viewModel;

  const SignUpLoginRedirect({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: viewModel.onLoginTap,
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: AuthStrings.alreadyHaveAccount,
          style: GoogleFonts.inter(color: AppColors.textLightPink),
          children: [
            TextSpan(
              text: AuthStrings.login,
              style: GoogleFonts.inter(
                color: AppColors.primaryRed,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
