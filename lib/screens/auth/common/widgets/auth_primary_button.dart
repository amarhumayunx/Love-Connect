import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/core/utils/media_query_extensions.dart';

class AuthPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final double? height;
  final bool expanded;
  final EdgeInsetsGeometry? margin;
  final bool isLoading;

  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height,
    this.expanded = true,
    this.margin,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonHeight = height ?? context.responsiveButtonHeight();

    final button = SizedBox(
      width: expanded ? double.infinity : null,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryRed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? LoadingAnimationWidget.dotsTriangle(
          color: AppColors.primaryDark,
          size: 35,
        )
            : Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: context.responsiveFont(18),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );

    if (margin == null) {
      return button;
    }

    return Padding(padding: margin!, child: button);
  }
}
