import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:love_connect/core/colors/app_colors.dart';

class GetStartedTitle extends StatelessWidget {
  final String text;
  final double fontSize;
  final EdgeInsetsGeometry? padding;

  const GetStartedTitle({
    super.key,
    required this.text,
    required this.fontSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final title = Text(
      text,
      textAlign: TextAlign.left,
      style: GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
        color: AppColors.textDarkPink,
        letterSpacing: 0,
        height: 1.2,
      ),
    );

    if (padding == null) {
      return title;
    }

    return Padding(padding: padding!, child: title);
  }
}
