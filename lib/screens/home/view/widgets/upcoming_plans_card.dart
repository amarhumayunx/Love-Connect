import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/core/models/plan_model.dart';
import 'package:love_connect/core/utils/media_query_extensions.dart';
import 'package:love_connect/screens/home/view/widgets/home_layout_metrics.dart';
import 'package:love_connect/screens/home/view/widgets/plan_card.dart';

class UpcomingPlansCard extends StatelessWidget {
  final String message;
  final String buttonText;
  final VoidCallback onAddTap;
  final Function(PlanModel)? onEditPlan;
  final Function(String)? onDeletePlan;
  final HomeLayoutMetrics metrics;
  final List<PlanModel> plans;

  const UpcomingPlansCard({
    super.key,
    required this.message,
    required this.buttonText,
    required this.onAddTap,
    this.onEditPlan,
    this.onDeletePlan,
    required this.metrics,
    this.plans = const [],
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - (metrics.cardPadding * 3)) / 2;

    // If there are plans, show them horizontally
    if (plans.isNotEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: metrics.cardPadding,
          vertical: metrics.sectionSpacing * 0.5,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row of plan cards
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Show first plan card
                SizedBox(
                  width: cardWidth,
                  child: PlanCard(
                    plan: plans[0],
                    onEdit: () => onEditPlan?.call(plans[0]),
                    onDelete: () => onDeletePlan?.call(plans[0].id),
                    metrics: metrics,
                  ),
                ),
                SizedBox(width: metrics.cardPadding),
                // Show second plan card or "Add New Plan" card
                SizedBox(
                  width: cardWidth,
                  child: plans.length >= 2
                      ? PlanCard(
                          plan: plans[1],
                          onEdit: () => onEditPlan?.call(plans[1]),
                          onDelete: () => onDeletePlan?.call(plans[1].id),
                          metrics: metrics,
                        )
                      : _buildAddNewPlanCard(context, cardWidth),
                ),
              ],
            ),
            // Show "Add New Plan" card below when there are 2+ plans
            if (plans.length >= 2) ...[
              SizedBox(height: metrics.sectionSpacing * 0.5),
              Center(
                child: _buildAddNewPlanCardBelow(context, screenWidth),
              ),
            ],
          ],
        ),
      );
    }

    // If no plans, show the empty state
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
              color: AppColors.textLightPink.withValues(alpha: 0.1),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add,
                      size: 18,
                      color: Colors.white,
                    ),
                    SizedBox(width: 4),
                    Text(
                      buttonText.replaceAll('+', '').trim(),
                      style: GoogleFonts.inter(
                        fontSize: metrics.addButtonFontSize,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddNewPlanCard(BuildContext context, double cardWidth) {
    return Container(
      constraints: BoxConstraints(
        minHeight: 180,
      ),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Center(
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: context.responsiveFont(12),
                  fontWeight: FontWeight.w500,
                  color: AppColors.textLightPink,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          SizedBox(height: metrics.sectionSpacing * 0.5),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onAddTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(34),
                ),
                padding: EdgeInsets.symmetric(vertical: 10),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add,
                    size: 18,
                    color: Colors.white,
                  ),
                  SizedBox(width: 4),
                  Text(
                    buttonText.replaceAll('+', '').trim(),
                    style: GoogleFonts.inter(
                      fontSize: context.responsiveFont(14),
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddNewPlanCardBelow(BuildContext context, double screenWidth) {
    return Container(
      width: screenWidth - (metrics.cardPadding * 2),
      padding: EdgeInsets.symmetric(
        horizontal: metrics.cardPadding * 1.5,
        vertical: metrics.cardPadding * 1.5,
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
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: context.responsiveFont(14),
              fontWeight: FontWeight.w500,
              color: AppColors.textLightPink,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 16),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add,
                    size: 18,
                    color: Colors.white,
                  ),
                  SizedBox(width: 4),
                  Text(
                    buttonText.replaceAll('+', '').trim(),
                    style: GoogleFonts.inter(
                      fontSize: metrics.addButtonFontSize,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

