import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/core/models/plan_model.dart';
import 'package:love_connect/core/utils/media_query_extensions.dart';
import 'package:love_connect/screens/home/view/widgets/home_layout_metrics.dart';
import 'package:love_connect/screens/home/view/widgets/plan_card.dart';
import 'package:love_connect/screens/home/view/widgets/add_plan_card.dart';

class UpcomingPlansCard extends StatelessWidget {
  final String message;
  final String buttonText;
  final VoidCallback onAddTap;
  final VoidCallback? onViewAllTap;
  final Function(PlanModel)? onEditPlan;
  final Function(String)? onDeletePlan;
  final HomeLayoutMetrics metrics;
  final List<PlanModel> plans;
  final bool isLoading;

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
    this.isLoading = false,
  });

  /// Calculate responsive card width for saved plan cards
  double _getPlanCardWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final baseWidth = 188.0;
    
    // Responsive scaling based on screen width
    if (screenWidth < 360) {
      return baseWidth * 0.85;
    } else if (screenWidth < 414) {
      return baseWidth;
    } else if (screenWidth < 768) {
      return baseWidth * 1.05;
    } else {
      return baseWidth * 1.2;
    }
  }

  /// Calculate responsive spacing between cards
  double _getCardSpacing(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return metrics.cardPadding;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final planCardWidth = _getPlanCardWidth(context);
    final cardSpacing = _getCardSpacing(context);

    // Show loading animation when loading
    if (isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: metrics.cardPadding,
          vertical: metrics.sectionSpacing * 0.5,
        ),
        child: Center(
          child: SizedBox(
            height: 200,
            child: LoadingAnimationWidget.horizontalRotatingDots(
              color: AppColors.primaryRed,
              size: 50,
            ),
          ),
        ),
      );
    }

    // If no plans, show the empty state (large add card)
    if (plans.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: metrics.cardPadding,
          vertical: metrics.sectionSpacing * 0.5,
        ),
        child: Center(
          child: AddPlanCard(
            message: message,
            buttonText: buttonText,
            onAddTap: onAddTap,
            metrics: metrics,
            size: AddPlanCardSize.large,
          ),
        ),
      );
    }

    // Determine how many plans to show (max 4)
    final plansToShow = plans.length > 4 ? plans.sublist(0, 4) : plans;
    final hasMorePlans = plans.length > 4;
    final planCount = plansToShow.length;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: metrics.cardPadding,
        vertical: metrics.sectionSpacing * 0.5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Flow based on number of plans
          if (planCount == 1) ...[
            // 1 plan: 1 saved plan card + 1 small add card (side by side)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: PlanCard(
                    plan: plansToShow[0],
                    onEdit: () => onEditPlan?.call(plansToShow[0]),
                    onDelete: () => onDeletePlan?.call(plansToShow[0].id),
                    metrics: metrics,
                  ),
                ),
                SizedBox(width: cardSpacing),
                Expanded(
                  child: AddPlanCard(
                    message: message,
                    buttonText: buttonText,
                    onAddTap: onAddTap,
                    metrics: metrics,
                    size: AddPlanCardSize.small,
                  ),
                ),
              ],
            ),
          ] else if (planCount == 2) ...[
            // 2 plans: 2 saved plan cards (side by side) + 1 large add card below
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: PlanCard(
                    plan: plansToShow[0],
                    onEdit: () => onEditPlan?.call(plansToShow[0]),
                    onDelete: () => onDeletePlan?.call(plansToShow[0].id),
                    metrics: metrics,
                  ),
                ),
                SizedBox(width: cardSpacing),
                Expanded(
                  child: PlanCard(
                    plan: plansToShow[1],
                    onEdit: () => onEditPlan?.call(plansToShow[1]),
                    onDelete: () => onDeletePlan?.call(plansToShow[1].id),
                    metrics: metrics,
                  ),
                ),
              ],
            ),
            SizedBox(height: metrics.sectionSpacing * 0.5),
            Center(
              child: AddPlanCard(
                message: message,
                buttonText: buttonText,
                onAddTap: onAddTap,
                metrics: metrics,
                size: AddPlanCardSize.large,
              ),
            ),
          ] else if (planCount == 3) ...[
            // 3 plans: 3 saved plan cards (2 on top row, 1 on second row) + 1 small add card (side by side with 3rd card)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: PlanCard(
                    plan: plansToShow[0],
                    onEdit: () => onEditPlan?.call(plansToShow[0]),
                    onDelete: () => onDeletePlan?.call(plansToShow[0].id),
                    metrics: metrics,
                  ),
                ),
                SizedBox(width: cardSpacing),
                Expanded(
                  child: PlanCard(
                    plan: plansToShow[1],
                    onEdit: () => onEditPlan?.call(plansToShow[1]),
                    onDelete: () => onDeletePlan?.call(plansToShow[1].id),
                    metrics: metrics,
                  ),
                ),
              ],
            ),
            SizedBox(height: metrics.sectionSpacing * 0.5),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: PlanCard(
                    plan: plansToShow[2],
                    onEdit: () => onEditPlan?.call(plansToShow[2]),
                    onDelete: () => onDeletePlan?.call(plansToShow[2].id),
                    metrics: metrics,
                  ),
                ),
                SizedBox(width: cardSpacing),
                Expanded(
                  child: AddPlanCard(
                    message: message,
                    buttonText: buttonText,
                    onAddTap: onAddTap,
                    metrics: metrics,
                    size: AddPlanCardSize.small,
                  ),
                ),
              ],
            ),
          ] else if (planCount == 4) ...[
            // 4 plans: 4 saved plan cards (2x2 grid), no add card
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: PlanCard(
                    plan: plansToShow[0],
                    onEdit: () => onEditPlan?.call(plansToShow[0]),
                    onDelete: () => onDeletePlan?.call(plansToShow[0].id),
                    metrics: metrics,
                  ),
                ),
                SizedBox(width: cardSpacing),
                Expanded(
                  child: PlanCard(
                    plan: plansToShow[1],
                    onEdit: () => onEditPlan?.call(plansToShow[1]),
                    onDelete: () => onDeletePlan?.call(plansToShow[1].id),
                    metrics: metrics,
                  ),
                ),
              ],
            ),
            SizedBox(height: metrics.sectionSpacing * 0.5),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: PlanCard(
                    plan: plansToShow[2],
                    onEdit: () => onEditPlan?.call(plansToShow[2]),
                    onDelete: () => onDeletePlan?.call(plansToShow[2].id),
                    metrics: metrics,
                  ),
                ),
                SizedBox(width: cardSpacing),
                Expanded(
                  child: PlanCard(
                    plan: plansToShow[3],
                    onEdit: () => onEditPlan?.call(plansToShow[3]),
                    onDelete: () => onDeletePlan?.call(plansToShow[3].id),
                    metrics: metrics,
                  ),
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
}
