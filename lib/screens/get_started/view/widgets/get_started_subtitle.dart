import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:love_connect/core/colors/app_colors.dart';

class GetStartedSubtitle extends StatelessWidget {
  final String text;
  final double fontSize;
  final EdgeInsetsGeometry? padding;

  const GetStartedSubtitle({
    super.key,
    required this.text,
    required this.fontSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = Text(
      text,
      textAlign: TextAlign.left,
      style: TextStyle(
        fontSize: fontSize,
        fontFamily: GoogleFonts.inter().fontFamily,
        fontWeight: FontWeight.w500,
        color: AppColors.textLightPink,
        height: 1.5,
      ),
    );

    if (padding == null) {
      return subtitle;
    }

    return Padding(padding: padding!, child: subtitle);
  }
}
