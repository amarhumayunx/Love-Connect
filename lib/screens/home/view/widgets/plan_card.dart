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

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd-MM-yyyy');
    final timeFormat = DateFormat('hh:mm a');
    
    return Container(
      padding: EdgeInsets.all(metrics.cardPadding),
      constraints: const BoxConstraints(
        minHeight: 180, // Match Add Plan card height for consistent layout
      ),
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
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.backgroundPink,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  plan.type.displayName,
                  style: GoogleFonts.inter(
                    fontSize: context.responsiveFont(10),
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: metrics.sectionSpacing * 0.4),
          
          // Date
          Row(
            children: [
              Flexible(
                child: Text(
                  dateFormat.format(plan.date),
                  style: GoogleFonts.inter(
                    fontSize: context.responsiveFont(12),
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 3),
          
          // Time
          if (plan.time != null)
            Row(
              children: [
                Flexible(
                  child: Text(
                    timeFormat.format(plan.time!),
                    style: GoogleFonts.inter(
                      fontSize: context.responsiveFont(12),
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ],
            ),
          if (plan.time != null) SizedBox(height: 3),
          
          // Place
          Row(
            children: [
              Expanded(
                child: Text(
                  plan.place,
                  style: GoogleFonts.inter(
                    fontSize: context.responsiveFont(12),
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          SizedBox(height: metrics.sectionSpacing * 0.4),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onEdit,
                  icon: Icon(
                    Icons.edit,
                    size: 16,
                    color: AppColors.white,
                  ),
                  label: Text(
                    'Edit',
                    style: GoogleFonts.inter(
                      fontSize: context.responsiveFont(12),
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
              SizedBox(width: 2),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: Icon(
                    Icons.delete,
                    size: 16,
                    color: AppColors.primaryRed,
                  ),
                  label: Text(
                    'Delete',
                    style: GoogleFonts.inter(
                      fontSize: context.responsiveFont(12),
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryRed,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.primaryRed),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

