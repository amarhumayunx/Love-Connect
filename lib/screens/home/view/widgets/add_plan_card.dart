import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/core/utils/media_query_extensions.dart';
import 'package:love_connect/screens/home/view/widgets/home_layout_metrics.dart';

enum AddPlanCardSize { small, large }

class AddPlanCard extends StatelessWidget {
  final String message;
  final String buttonText;
  final VoidCallback onAddTap;
  final HomeLayoutMetrics metrics;
  final AddPlanCardSize size;

  const AddPlanCard({
    super.key,
    required this.message,
    required this.buttonText,
    required this.onAddTap,
    required this.metrics,
    this.size = AddPlanCardSize.small,
  });

  /// Calculate responsive card width
  double _getCardWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final baseWidth = size == AddPlanCardSize.large ? 392.0 : 188.0;
    
    // Responsive scaling based on screen width
    if (screenWidth < 360) {
      // Small phones
      return baseWidth * 0.85;
    } else if (screenWidth < 414) {
      // Medium phones (iPhone 12/13, standard Android)
      return baseWidth;
    } else if (screenWidth < 768) {
      // Large phones (iPhone Pro Max, large Android)
      return baseWidth * 1.05;
    } else {
      // Tablets
      return baseWidth * 1.2;
    }
  }

  /// Calculate responsive card height
  double _getCardHeight(BuildContext context) {
    final baseHeight = 143.0;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Responsive scaling based on screen width
    if (screenWidth < 360) {
      return baseHeight * 0.9;
    } else if (screenWidth < 414) {
      return baseHeight;
    } else if (screenWidth < 768) {
      return baseHeight * 1.05;
    } else {
      return baseHeight * 1.1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardWidth = _getCardWidth(context);
    final cardHeight = _getCardHeight(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Use available width if constrained, otherwise use calculated width
        final effectiveWidth = constraints.maxWidth.isFinite && constraints.maxWidth > 0
            ? constraints.maxWidth
            : cardWidth;
        
        return Container(
          width: effectiveWidth,
          height: cardHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.textLightPink.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size == AddPlanCardSize.large ? 16 : 8),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: context.responsiveFont(size == AddPlanCardSize.large ? 14 : 12),
                fontWeight: FontWeight.w500,
                color: AppColors.textLightPink,
              ),
              maxLines: size == AddPlanCardSize.large ? 2 : 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: onAddTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(34),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: size == AddPlanCardSize.large ? 24 : 16,
                  vertical: 12,
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Add',
                    style: GoogleFonts.inter(
                      fontSize: context.responsiveFont(14),
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.add, size: 18, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
        );
      },
    );
  }
}

