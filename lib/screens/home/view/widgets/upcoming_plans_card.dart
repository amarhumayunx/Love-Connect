import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/core/models/plan_model.dart';
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
    // If there are plans, show them
    if (plans.isNotEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: metrics.cardPadding,
          vertical: metrics.sectionSpacing * 0.5,
        ),
        child: Column(
          children: [
            // Show up to 3 upcoming plans
            ...plans.take(3).map((plan) => PlanCard(
                  plan: plan,
                  onEdit: () => onEditPlan?.call(plan),
                  onDelete: () => onDeletePlan?.call(plan.id),
                  metrics: metrics,
                )),
            // Show "Add Plan" button if there are plans
            if (plans.length < 3)
              Padding(
                padding: EdgeInsets.only(top: metrics.sectionSpacing * 0.5),
                child: Center(
                  child: SizedBox(
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
                ),
              ),
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

