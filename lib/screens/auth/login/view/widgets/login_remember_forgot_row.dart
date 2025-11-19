import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/core/strings/auth_strings.dart';
import 'package:love_connect/core/utils/media_query_extensions.dart';
import 'package:love_connect/screens/auth/login/view_model/login_view_model.dart';

class LoginRememberForgotRow extends StatelessWidget {
  final LoginViewModel viewModel;

  const LoginRememberForgotRow({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Obx(
          () => Checkbox(
            value: viewModel.rememberMe.value,
            onChanged: viewModel.toggleRememberMe,
            activeColor: AppColors.textFieldBorder,
            checkColor: Colors.white,
            side: const BorderSide(color: AppColors.textFieldBorder, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        Expanded(
          child: Text(
            AuthStrings.rememberMe,
            style: GoogleFonts.inter(
              color: AppColors.textLightPink,
              fontWeight: FontWeight.w600,
              fontSize: context.responsiveFont(13),
            ),
          ),
        ),
        TextButton(
          onPressed: viewModel.onForgotPasswordTap,
          child: Text(
            AuthStrings.forgotPassword,
            style: GoogleFonts.inter(
              color: AppColors.primaryRed,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
