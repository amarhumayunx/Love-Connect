import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/core/utils/media_query_extensions.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final double? titleFontSize;
  final double? subtitleFontSize;
  final double spacing;
  final TextAlign textAlign;
  final CrossAxisAlignment alignment;
  final Color? titleColor;
  final Color? subtitleColor;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.titleFontSize,
    this.subtitleFontSize,
    this.spacing = 8,
    this.textAlign = TextAlign.center,
    this.alignment = CrossAxisAlignment.center,
    this.titleColor,
    this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          title,
          textAlign: textAlign,
          style: GoogleFonts.inter(
            fontSize: titleFontSize ?? context.responsiveFont(28),
            fontWeight: FontWeight.w700,
            color: titleColor ?? AppColors.textDarkPink,
          ),
        ),
        SizedBox(height: spacing),
        Text(
          subtitle,
          textAlign: textAlign,
          style: GoogleFonts.inter(
            fontSize: subtitleFontSize ?? context.responsiveFont(14),
            fontWeight: FontWeight.w500,
            color: subtitleColor ?? AppColors.textLightPink,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}
