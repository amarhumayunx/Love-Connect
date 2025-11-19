import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/core/strings/auth_strings.dart';

class LoginOrDivider extends StatelessWidget {
  final double horizontalPadding;

  const LoginOrDivider({super.key, required this.horizontalPadding});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.textFieldBorder)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Text(
            AuthStrings.orText,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textLightPink,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.textFieldBorder)),
      ],
    );
  }
}
