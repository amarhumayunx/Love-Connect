import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/core/models/journal_entry_model.dart';
import 'package:love_connect/core/utils/media_query_extensions.dart';
import 'package:love_connect/screens/home/view/widgets/home_layout_metrics.dart';
import 'package:love_connect/screens/home/view_model/home_view_model.dart';
import 'package:love_connect/screens/journal/view_model/journal_view_model.dart';

class JournalView extends StatefulWidget {
  const JournalView({super.key});

  @override
  State<JournalView> createState() => _JournalViewState();
}

class _JournalViewState extends State<JournalView> {
  late final JournalViewModel viewModel;
  HomeViewModel? homeViewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Get.put(JournalViewModel());
    // Try to find HomeViewModel, but don't fail if it doesn't exist
    try {
      homeViewModel = Get.find<HomeViewModel>();
      // Note: navigationSource will be set by onBottomNavTap (true) or onQuickActionTap (false)
      // The isFromNavbar method now defaults to true for journal screen
    } catch (e) {
      // HomeViewModel not found, likely navigated via Get.to() from outside MainNavigationView
      homeViewModel = null;
    }
  }

  @override
  void dispose() {
    Get.delete<JournalViewModel>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final metrics = HomeLayoutMetrics.fromContext(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundPink,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: metrics.headerHorizontalPadding,
                vertical: metrics.sectionSpacing * 0.5,
              ),
              child: Row(
                children: [
                  // Show back arrow only if navigated from quick actions
                  homeViewModel != null
                      ? Obx(
                          () => homeViewModel!.isFromNavbar('journal')
                              ? const SizedBox.shrink() // Hide back arrow if from navbar
                              : IconButton(
                                  icon: Icon(
                                    Icons.arrow_back_ios,
                                    color: AppColors.primaryDark,
                                    size: metrics.iconSize,
                                  ),
                                  onPressed: () => Get.back(),
                                ),
                        )
                      : IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: AppColors.primaryDark,
                            size: metrics.iconSize,
                          ),
                          onPressed: () => Get.back(),
                        ),
                  Text(
                    viewModel.model.title,
                    style: GoogleFonts.inter(
                      fontSize: context.responsiveFont(20),
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Obx(
                () {
                  if (viewModel.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryRed,
                      ),
                    );
                  }

                  if (viewModel.entries.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: metrics.cardPadding * 2,
                            ),
                            padding: EdgeInsets.all(metrics.cardPadding * 2),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'No memories yet, add your first love note.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: context.responsiveFont(14),
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textLightPink,
                                  ),
                                ),
                                SizedBox(height: metrics.sectionSpacing),
                                ElevatedButton(
                                  onPressed: () => viewModel.showAddEntryModal(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryRed,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    minimumSize: Size(
                                      120,
                                      context.responsiveButtonHeight(),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.add,
                                        color: AppColors.white,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Add',
                                        style: GoogleFonts.inter(
                                          fontSize: context.responsiveFont(16),
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: metrics.cardPadding,
                      vertical: metrics.sectionSpacing * 0.5,
                    ),
                    itemCount: viewModel.entries.length,
                    itemBuilder: (context, index) {
                      final entry = viewModel.entries[index];
                      return _buildEntryCard(entry, metrics, context);
                    },
                  );
                },
              ),
            ),

            // Add Entry Button
            if (viewModel.entries.isNotEmpty)
              Padding(
                padding: EdgeInsets.all(metrics.cardPadding),
                child: ElevatedButton(
                  onPressed: () => viewModel.showAddEntryModal(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: Size(
                      double.infinity,
                      context.responsiveButtonHeight(),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add,
                        color: AppColors.white,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Add Entry',
                        style: GoogleFonts.inter(
                          fontSize: context.responsiveFont(16),
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
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

  Widget _buildEntryCard(
    JournalEntryModel entry,
    HomeLayoutMetrics metrics,
    BuildContext context,
  ) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final isLongEntry = entry.note.length > 100;

    return Container(
      margin: EdgeInsets.only(bottom: metrics.sectionSpacing * 0.5),
      padding: EdgeInsets.all(metrics.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${dateFormat.format(entry.date)} | ${entry.note.split('\n').first}',
                style: GoogleFonts.inter(
                  fontSize: context.responsiveFont(14),
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDark,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: AppColors.primaryRed,
                      size: 20,
                    ),
                    onPressed: () => viewModel.showAddEntryModal(entry: entry),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: AppColors.primaryRed,
                      size: 20,
                    ),
                    onPressed: () => viewModel.deleteEntry(entry.id),
                  ),
                ],
              ),
            ],
          ),
          if (isLongEntry || entry.note.contains('\n')) ...[
            SizedBox(height: metrics.sectionSpacing * 0.5),
            Text(
              entry.note,
              style: GoogleFonts.inter(
                fontSize: context.responsiveFont(14),
                fontWeight: FontWeight.w400,
                color: AppColors.primaryDark,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

