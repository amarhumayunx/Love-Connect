import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/screens/home/view/widgets/home_layout_metrics.dart';

class QuickActionCard extends StatelessWidget {
  final String title;
  final String iconPath;
  final VoidCallback onTap;
  final HomeLayoutMetrics metrics;

  const QuickActionCard({
    super.key,
    required this.title,
    required this.iconPath,
    required this.onTap,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 92,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.textLightPink.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 12,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                iconPath,
                width: metrics.quickActionIconSize,
                height: metrics.quickActionIconSize,
                colorFilter: ColorFilter.mode(
                  AppColors.textDarkPink,
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: metrics.quickActionFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDarkPink,
                  height: 1.1,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}