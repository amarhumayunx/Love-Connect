import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
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
  StreamSubscription? _screenIndexSubscription;

  @override
  void initState() {
    super.initState();
    viewModel = Get.put(JournalViewModel());
    try {
      homeViewModel = Get.find<HomeViewModel>();
      // Listen to screen index changes to reload entries when journal becomes visible
      _screenIndexSubscription = homeViewModel!.currentScreenIndex.listen((index) {
        // When journal screen (index 1) becomes visible, reload entries
        if (index == 1 && mounted) {
          viewModel.loadEntries();
        }
      });
      // If already on journal tab when view is created, reload entries
      if (homeViewModel!.currentScreenIndex.value == 1) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            viewModel.loadEntries();
          }
        });
      }
    } catch (e) {
      homeViewModel = null;
    }
  }

  @override
  void dispose() {
    _screenIndexSubscription?.cancel();
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
            Container(
              color: AppColors.backgroundPink,
              padding: EdgeInsets.symmetric(
                horizontal: metrics.headerHorizontalPadding,
                vertical: metrics.sectionSpacing * 0.5,
              ),
              child: Row(
                children: [
                  homeViewModel != null
                      ? Obx(
                        () => homeViewModel!.isFromNavbar('journal')
                        ? const SizedBox.shrink()
                        : IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: AppColors.primaryRed,
                        size: metrics.iconSize,
                      ),
                      onPressed: () => Get.back(),
                    ),
                  )
                      : IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.primaryRed,
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
                    return Center(
                      child: LoadingAnimationWidget.horizontalRotatingDots(
                        color: AppColors.primaryRed,
                        size: 50,
                      ),
                    );
                  }

                  if (viewModel.entries.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: metrics.cardPadding * 2,
                        ),
                        child: Text(
                          'No memories yet, add your first love note.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: context.responsiveFont(14),
                            fontWeight: FontWeight.w500,
                            color: AppColors.textLightPink,
                          ),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: false,
                    padding: EdgeInsets.only(
                      left: metrics.cardPadding,
                      right: metrics.cardPadding,
                      top: metrics.sectionSpacing * 0.5,
                      bottom: 80, // Extra padding for FAB
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
          ],
        ),
      ),
      // Floating Action Button
      floatingActionButton: SizedBox(
        height: 48,
        child: FloatingActionButton.extended(
          onPressed: () => viewModel.showAddEntryModal(),
          backgroundColor: AppColors.primaryRed,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(34),
          ),
          icon: Icon(
            Icons.add,
            color: AppColors.white,
            size: 20,
          ),
          label: Text(
            'Add Entry',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildEntryCard(
      JournalEntryModel entry,
      HomeLayoutMetrics metrics,
      BuildContext context,
      ) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    // Check if this is a reward entry
    final isRewardEntry = entry.note.contains('Lucky Love Coupon:');
    String? rewardText;
    if (isRewardEntry) {
      final parts = entry.note.split('Lucky Love Coupon:');
      if (parts.length > 1) {
        rewardText = parts[1].trim();
      }
    }

    // Check if it's a short single line entry (less than 50 characters)
    final isShortEntry = entry.note.length <= 50 && !entry.note.contains('\n');

    return Container(
      width: 392,
      margin: EdgeInsets.only(bottom: metrics.sectionSpacing * 0.5),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryRed,
          width: 1.0,
        ),
      ),
      child: isShortEntry
          ? _buildShortEntry(entry, dateFormat, context, isRewardEntry: isRewardEntry, rewardText: rewardText)
          : _buildLongEntry(entry, dateFormat, context, isRewardEntry: isRewardEntry, rewardText: rewardText),
    );
  }

  // Short entry: Date aur text same line par (height: 44)
  Widget _buildShortEntry(
      JournalEntryModel entry,
      DateFormat dateFormat,
      BuildContext context, {
      bool isRewardEntry = false,
      String? rewardText,
      }) {
    return SizedBox(
      height: isRewardEntry ? null : 44,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reward badge if it's a reward entry
          if (isRewardEntry && rewardText != null) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primaryRed,
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.card_giftcard,
                    size: 16,
                    color: AppColors.primaryRed,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Reward Won',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryRed,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Date aur text same line
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${dateFormat.format(entry.date)}   ',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.primaryRed,
                        ),
                      ),
                      TextSpan(
                        text: isRewardEntry && rewardText != null ? rewardText : entry.note,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: isRewardEntry ? FontWeight.w600 : FontWeight.w400,
                          color: AppColors.primaryRed,
                        ),
                      ),
                    ],
                  ),
                  maxLines: isRewardEntry ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Edit and delete icons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: 12),
                  InkWell(
                    onTap: () => viewModel.showAddEntryModal(entry: entry),
                    child: Icon(
                      Icons.edit_outlined,
                      color: AppColors.primaryRed,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 16),
                  InkWell(
                    onTap: () => viewModel.deleteEntry(entry.id),
                    child: Icon(
                      Icons.delete_outline,
                      color: AppColors.primaryRed,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Long entry: Date pehli line, content neeche (dynamic height)
  Widget _buildLongEntry(
      JournalEntryModel entry,
      DateFormat dateFormat,
      BuildContext context, {
      bool isRewardEntry = false,
      String? rewardText,
      }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Reward badge if it's a reward entry
        if (isRewardEntry && rewardText != null) ...[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.primaryRed,
                width: 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.card_giftcard,
                  size: 16,
                  color: AppColors.primaryRed,
                ),
                SizedBox(width: 6),
                Text(
                  'Reward Won',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryRed,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
        ],
        // First row: Date and icons (height: ~24)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              dateFormat.format(entry.date),
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.primaryRed,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () => viewModel.showAddEntryModal(entry: entry),
                  child: Icon(
                    Icons.edit_outlined,
                    color: AppColors.primaryRed,
                    size: 20,
                  ),
                ),
                SizedBox(width: 16),
                InkWell(
                  onTap: () => viewModel.deleteEntry(entry.id),
                  child: Icon(
                    Icons.delete_outline,
                    color: AppColors.primaryRed,
                    size: 22,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 16),
        // Full content neeche (dynamic height based on text)
        Text(
          isRewardEntry && rewardText != null ? rewardText : entry.note,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: isRewardEntry ? FontWeight.w600 : FontWeight.w400,
            color: AppColors.primaryRed,
            height: 1.5, // Line height for better readability
          ),
          softWrap: true,
        ),
      ],
    );
  }
}