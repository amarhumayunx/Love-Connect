import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/core/models/plan_model.dart';
import 'package:love_connect/core/utils/media_query_extensions.dart';
import 'package:love_connect/screens/home/view/widgets/home_layout_metrics.dart';

class PlanCard extends StatelessWidget {
  final PlanModel plan;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final HomeLayoutMetrics metrics;

  const PlanCard({
    super.key,
    required this.plan,
    required this.onEdit,
    required this.onDelete,
    required this.metrics,
  });

  /// Calculate responsive card width
  double _getCardWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final baseWidth = 188.0;
    
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
    final dateFormat = DateFormat('dd-MM-yyyy');
    final timeFormat = DateFormat('hh:mm a');
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
          padding: EdgeInsets.all(metrics.cardPadding),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.textLightPink.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRect(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
          // Title and Type Tag
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  plan.title,
                  style: GoogleFonts.inter(
                    fontSize: context.responsiveFont(18),
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.backgroundPink,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  plan.type.displayName,
                  style: GoogleFonts.inter(
                    fontSize: context.responsiveFont(9),
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: metrics.sectionSpacing * 0.2),
          
          // Date
          Row(
            children: [
              Flexible(
                child: Text(
                  dateFormat.format(plan.date),
                  style: GoogleFonts.inter(
                    fontSize: context.responsiveFont(11),
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.0),
          
          // Time
          if (plan.time != null)
            Row(
              children: [
                Flexible(
                  child: Text(
                    timeFormat.format(plan.time!),
                    style: GoogleFonts.inter(
                      fontSize: context.responsiveFont(11),
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ],
            ),
          if (plan.time != null) SizedBox(height: 1.0),
          
          // Place
          Row(
            children: [
              Expanded(
                child: Text(
                  plan.place,
                  style: GoogleFonts.inter(
                    fontSize: context.responsiveFont(11),
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          SizedBox(height: metrics.sectionSpacing * 0.2),
          
          // Action Buttons
          Spacer(),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onEdit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.edit,
                        size: 14,
                        color: AppColors.white,
                      ),
                      SizedBox(width: 2),
                      Text(
                        'Edit',
                        style: GoogleFonts.inter(
                          fontSize: context.responsiveFont(12),
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 6),
              Expanded(
                child: OutlinedButton(
                  onPressed: onDelete,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.primaryRed, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.delete,
                        size: 14,
                        color: AppColors.primaryRed,
                      ),
                      SizedBox(width: 1),
                      Text(
                        'Delete',
                        style: GoogleFonts.inter(
                          fontSize: context.responsiveFont(12),
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryRed,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
            ),
          ),
        );
      },
    );
  }
}

