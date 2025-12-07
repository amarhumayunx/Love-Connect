import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/screens/all_plans/view_model/all_plans_view_model.dart';
import 'package:love_connect/screens/home/view/widgets/home_layout_metrics.dart';
import 'package:love_connect/screens/home/view/widgets/plan_card.dart';

class AllPlansView extends StatefulWidget {
  const AllPlansView({super.key});

  @override
  State<AllPlansView> createState() => _AllPlansViewState();
}

class _AllPlansViewState extends State<AllPlansView> {
  late final AllPlansViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Get.put(AllPlansViewModel());
  }

  @override
  void dispose() {
    Get.delete<AllPlansViewModel>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final metrics = HomeLayoutMetrics.fromContext(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - (metrics.cardPadding * 3)) / 2;

    return Scaffold(
      backgroundColor: AppColors.backgroundPink,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundPink,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primaryDark),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'All Plans',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryDark,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: viewModel.onAddPlanTap,
        backgroundColor: AppColors.primaryRed,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(34),
        ),
        icon: Icon(Icons.add, color: Colors.white, size: 24),
        label: Text(
          'Add Plan',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Obx(() {
        if (viewModel.isLoading.value && viewModel.plans.isEmpty) {
          return Center(
            child: LoadingAnimationWidget.horizontalRotatingDots(
              color: AppColors.primaryRed,
              size: 50,
            ),
          );
        }

        if (viewModel.plans.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 80,
                  color: AppColors.textLightPink,
                ),
                SizedBox(height: 16),
                Text(
                  'No plans yet',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDarkPink,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Tap the + button to add your first plan',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textLightPink,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.primaryRed,
          onRefresh: viewModel.refreshPlans,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(metrics.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display plans in 2-column grid
                for (int i = 0; i < viewModel.plans.length; i += 2) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left card
                      SizedBox(
                        width: cardWidth,
                        child: PlanCard(
                          plan: viewModel.plans[i],
                          onEdit: () => viewModel.editPlan(viewModel.plans[i]),
                          onDelete: () =>
                              viewModel.deletePlan(viewModel.plans[i].id),
                          metrics: metrics,
                        ),
                      ),
                      SizedBox(width: metrics.cardPadding),
                      // Right card (if exists)
                      SizedBox(
                        width: cardWidth,
                        child: i + 1 < viewModel.plans.length
                            ? PlanCard(
                          plan: viewModel.plans[i + 1],
                          onEdit: () =>
                              viewModel.editPlan(viewModel.plans[i + 1]),
                          onDelete: () => viewModel.deletePlan(
                            viewModel.plans[i + 1].id,
                          ),
                          metrics: metrics,
                        )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                  if (i + 2 < viewModel.plans.length)
                    SizedBox(height: metrics.sectionSpacing * 0.5),
                ],
                // Bottom spacing
                SizedBox(height: metrics.contentBottomSpacing),
              ],
            ),
          ),
        );
      }),
    );
  }
}