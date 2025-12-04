import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/core/navigation/smooth_transitions.dart';
import 'package:love_connect/screens/auth/login/view/login_view.dart';

class VerificationBackButton extends StatelessWidget {
  const VerificationBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        SmoothNavigator.offAll(
          () => const LoginView(),
          transition: Transition.rightToLeftWithFade,
          duration: SmoothNavigator.defaultDuration,
        );
      },
      child: Row(
        children: [
          Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.backArrow,
            size: 20,
          ),
          const SizedBox(width: 4),
          Text(
            'Back to login',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.backArrow,
            ),
          ),
        ],
      ),
    );
  }
}
