import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/core/strings/auth_strings.dart';
import 'package:love_connect/screens/auth/login/view_model/login_view_model.dart';

class LoginSignUpRedirect extends StatelessWidget {
  final LoginViewModel viewModel;

  const LoginSignUpRedirect({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: viewModel.onSignUpTap,
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: AuthStrings.dontHaveAccount,
          style: GoogleFonts.inter(color: AppColors.textLightPink),
          children: [
            TextSpan(
              text: AuthStrings.signUp,
              style: GoogleFonts.inter(
                color: AppColors.primaryRed,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
