import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/screens/home/view/widgets/home_layout_metrics.dart';

class UpcomingPlansCard extends StatelessWidget {
  final String message;
  final String buttonText;
  final VoidCallback onAddTap;
  final HomeLayoutMetrics metrics;

  const UpcomingPlansCard({
    super.key,
    required this.message,
    required this.buttonText,
    required this.onAddTap,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: metrics.cardPadding,
          vertical: metrics.sectionSpacing * 0.5,
        ),
        width: 392,
        height: 143,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.textLightPink.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: metrics.addButtonFontSize * 0.9,
                fontWeight: FontWeight.w500,
                color: AppColors.textLightPink,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 97,
              height: 40,
              child: ElevatedButton(
                onPressed: onAddTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(34),
                  ),
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(97, 40),
                  elevation: 0,
                ),
                child: Text(
                  buttonText,
                  style: GoogleFonts.inter(
                    fontSize: metrics.addButtonFontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

