import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/core/models/plan_model.dart';
import 'package:love_connect/core/utils/media_query_extensions.dart';
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
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.widthPct(5),
                vertical: context.responsiveSpacing(16),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: EdgeInsets.all(context.responsiveSpacing(8)),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryRed.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            color: AppColors.primaryDark,
                            size: context.responsiveImage(20),
                          ),
                        ),
                      ),
                      SizedBox(width: context.responsiveSpacing(16)),
                      Expanded(
                        child: Text(
                          'All Plans',
                          style: GoogleFonts.inter(
                            fontSize: context.responsiveFont(24),
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.responsiveSpacing(12)),
                  // Search Bar
                  TextField(
                    onChanged: viewModel.updateSearchQuery,
                    decoration: InputDecoration(
                      hintText: 'Search plans...',
                      hintStyle: GoogleFonts.inter(
                        color: AppColors.textLightPink,
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColors.primaryRed,
                      ),
                      suffixIcon: Obx(() => viewModel.searchQuery.value.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: AppColors.primaryRed,
                              ),
                              onPressed: () => viewModel.updateSearchQuery(''),
                            )
                          : const SizedBox.shrink()),
                      filled: true,
                      fillColor: AppColors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.primaryRed.withOpacity(0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.primaryRed.withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.primaryRed,
                          width: 2,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  SizedBox(height: context.responsiveSpacing(8)),
                  // Filter Row
                  Row(
                    children: [
                      Expanded(
                        child: Obx(() => DropdownButtonFormField<PlanType?>(
                          value: viewModel.selectedTypeFilter.value,
                          decoration: InputDecoration(
                            hintText: 'Filter by Type',
                            hintStyle: GoogleFonts.inter(
                              color: AppColors.textLightPink,
                              fontSize: 12,
                            ),
                            filled: true,
                            fillColor: AppColors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.primaryRed.withOpacity(0.3),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.primaryRed.withOpacity(0.3),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.primaryRed,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          items: [
                            DropdownMenuItem<PlanType?>(
                              value: null,
                              child: Text(
                                'All Types',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ),
                            ...PlanType.values.map((type) {
                              return DropdownMenuItem<PlanType?>(
                                value: type,
                                child: Text(
                                  type.displayName,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                              );
                            }),
                          ],
                          onChanged: viewModel.updateTypeFilter,
                        )),
                      ),
                      SizedBox(width: context.responsiveSpacing(8)),
                      Obx(() => (viewModel.selectedTypeFilter.value != null ||
                              viewModel.selectedDateFilter.value != null ||
                              viewModel.searchQuery.value.isNotEmpty)
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: AppColors.primaryRed,
                              ),
                              onPressed: viewModel.clearFilters,
                              tooltip: 'Clear Filters',
                            )
                          : const SizedBox.shrink()),
                    ],
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Obx(() {
                if (viewModel.isLoading.value && viewModel.plans.isEmpty) {
                  return Center(
                    child: LoadingAnimationWidget.horizontalRotatingDots(
                      color: AppColors.primaryRed,
                      size: 50,
                    ),
                  );
                }

                // Show empty state if no plans at all (not filtered)
                if (viewModel.plans.isEmpty && !viewModel.isLoading.value) {
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

                // Show no search results if search/filter is active but no filtered results
                if (viewModel.filteredPlans.isEmpty && 
                    !viewModel.plans.isEmpty &&
                    !viewModel.isLoading.value &&
                    (viewModel.searchQuery.value.isNotEmpty || 
                     viewModel.selectedTypeFilter.value != null ||
                     viewModel.selectedDateFilter.value != null)) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: AppColors.textLightPink,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No plans found',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDarkPink,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Try adjusting your search or filters',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textLightPink,
                          ),
                        ),
                        SizedBox(height: 16),
                        TextButton(
                          onPressed: viewModel.clearFilters,
                          child: Text(
                            'Clear Filters',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryRed,
                            ),
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
                        // Display plans in 2-column grid with swipe actions
                        for (int i = 0; i < viewModel.filteredPlans.length; i += 2) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left card with swipe
                              SizedBox(
                                width: cardWidth,
                                child: _buildSwipeablePlanCard(
                                  viewModel.filteredPlans[i],
                                  metrics,
                                  cardWidth,
                                ),
                              ),
                              SizedBox(width: metrics.cardPadding),
                              // Right card (if exists) with swipe
                              SizedBox(
                                width: cardWidth,
                                child: i + 1 < viewModel.filteredPlans.length
                                    ? _buildSwipeablePlanCard(
                                  viewModel.filteredPlans[i + 1],
                                  metrics,
                                  cardWidth,
                                )
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          ),
                          if (i + 2 < viewModel.filteredPlans.length)
                            SizedBox(height: metrics.sectionSpacing * 0.5),
                        ],
                        // Bottom spacing
                        SizedBox(height: metrics.contentBottomSpacing),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
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
    );
  }

  Widget _buildSwipeablePlanCard(
    PlanModel plan,
    HomeLayoutMetrics metrics,
    double cardWidth,
  ) {
    return Dismissible(
      key: Key(plan.id),
      direction: DismissDirection.horizontal,
      background: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryRed,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 20),
        child: Row(
          children: [
            Icon(
              Icons.edit,
              color: AppColors.white,
              size: 24,
            ),
            SizedBox(width: 8),
            Text(
              'Edit',
              style: GoogleFonts.inter(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Delete',
              style: GoogleFonts.inter(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.delete,
              color: AppColors.white,
              size: 24,
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // Delete
          return await _showDeleteConfirmation(plan);
        } else if (direction == DismissDirection.startToEnd) {
          // Edit
          viewModel.editPlan(plan);
          return false; // Don't dismiss, just edit
        }
        return false;
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          viewModel.deletePlan(plan.id);
        }
      },
      child: PlanCard(
        plan: plan,
        onEdit: () => viewModel.editPlan(plan),
        onDelete: () => viewModel.deletePlan(plan.id),
        metrics: metrics,
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(PlanModel plan) async {
    return await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Delete Plan?',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDark,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${plan.title}"?',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textDarkPink,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: AppColors.textLightPink,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'Delete',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: AppColors.primaryRed,
              ),
            ),
          ),
        ],
      ),
    ) ?? false;
  }
}