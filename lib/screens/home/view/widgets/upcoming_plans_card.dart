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
  final VoidCallback? onViewAllTap;
  final Function(PlanModel)? onEditPlan;
  final Function(String)? onDeletePlan;
  final HomeLayoutMetrics metrics;
  final List<PlanModel> plans;

  const UpcomingPlansCard({
    super.key,
    required this.message,
    required this.buttonText,
    required this.onAddTap,
    this.onViewAllTap,
    this.onEditPlan,
    this.onDeletePlan,
    required this.metrics,
    this.plans = const [],
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - (metrics.cardPadding * 3)) / 2;

    // If no plans, show the empty state (full-width card with Add button)
    if (plans.isEmpty) {
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
                      Icon(Icons.add, size: 18, color: Colors.white),
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

    // Determine how many plans to show (max 4)
    final plansToShow = plans.length > 4 ? plans.sublist(0, 4) : plans;
    final hasMorePlans = plans.length > 4;

    // If there are plans, show them in a 2-column grid
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: metrics.cardPadding,
        vertical: metrics.sectionSpacing * 0.5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // First row (index 0 and 1 / Add card)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: cardWidth,
                child: PlanCard(
                  plan: plansToShow[0],
                  onEdit: () => onEditPlan?.call(plansToShow[0]),
                  onDelete: () => onDeletePlan?.call(plansToShow[0].id),
                  metrics: metrics,
                ),
              ),
              SizedBox(width: metrics.cardPadding),
              SizedBox(
                width: cardWidth,
                child: plansToShow.length >= 2
                    ? PlanCard(
                        plan: plansToShow[1],
                        onEdit: () => onEditPlan?.call(plansToShow[1]),
                        onDelete: () => onDeletePlan?.call(plansToShow[1].id),
                        metrics: metrics,
                      )
                    : _buildAddNewPlanCard(context, cardWidth),
              ),
            ],
          ),

          // Second row - show Add card if exactly 2 plans, or show plans 2 and 3
          if (plansToShow.length == 2) ...[
            // Show full-width Add card below when there are exactly 2 plans
            SizedBox(height: metrics.sectionSpacing * 0.5),
            Center(child: _buildFullWidthAddCard(context, screenWidth)),
          ] else if (plansToShow.length > 2) ...[
            SizedBox(height: metrics.sectionSpacing * 0.5),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: cardWidth,
                  child: PlanCard(
                    plan: plansToShow[2],
                    onEdit: () => onEditPlan?.call(plansToShow[2]),
                    onDelete: () => onDeletePlan?.call(plansToShow[2].id),
                    metrics: metrics,
                  ),
                ),
                SizedBox(width: metrics.cardPadding),
                SizedBox(
                  width: cardWidth,
                  child: plansToShow.length >= 4
                      ? PlanCard(
                          plan: plansToShow[3],
                          onEdit: () => onEditPlan?.call(plansToShow[3]),
                          onDelete: () => onDeletePlan?.call(plansToShow[3].id),
                          metrics: metrics,
                        )
                      : _buildAddNewPlanCard(context, cardWidth),
                ),
              ],
            ),
          ],

          // View All Plans button - only show if more than 4 plans
          if (hasMorePlans) ...[
            SizedBox(height: metrics.sectionSpacing * 0.7),
            Center(
              child: SizedBox(
                width: screenWidth - (metrics.cardPadding * 2),
                height: 48,
                child: ElevatedButton(
                  onPressed: onViewAllTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'View All Plans',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFullWidthAddCard(BuildContext context, double screenWidth) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: plans.isEmpty
            ? metrics.cardPadding
            : 0, // Only apply horizontal margin if it's the initial empty state
        vertical: metrics.sectionSpacing * 0.5,
      ),
      width:
          screenWidth -
          (metrics.cardPadding * 2), // Adjust width for full-width card
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
                  Icon(Icons.add, size: 18, color: Colors.white),
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

  Widget _buildAddNewPlanCard(BuildContext context, double cardWidth) {
    return Container(
      constraints: BoxConstraints(minHeight: 180),
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
                  Icon(Icons.add, size: 18, color: Colors.white),
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
}
