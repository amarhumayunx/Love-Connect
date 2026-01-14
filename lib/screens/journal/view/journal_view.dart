import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/core/models/journal_entry_model.dart';
import 'package:love_connect/core/utils/media_query_extensions.dart';
import 'package:love_connect/core/widgets/empty_state_widget.dart';
import 'package:love_connect/core/widgets/banner_ad_widget.dart';
import 'package:love_connect/core/services/admob_service.dart';
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
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.widthPct(5),
                vertical: context.responsiveSpacing(16),
              ),
              child: Row(
                children: [
                  homeViewModel != null
                      ? Obx(
                        () => homeViewModel!.isFromNavbar('journal')
                        ? const SizedBox.shrink()
                        : GestureDetector(
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
                  )
                      : GestureDetector(
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
                      viewModel.model.title,
                      style: GoogleFonts.inter(
                        fontSize: context.responsiveFont(24),
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Search Bar
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.widthPct(5),
                vertical: context.responsiveSpacing(8),
              ),
              child: TextField(
                onChanged: viewModel.updateSearchQuery,
                decoration: InputDecoration(
                  hintText: 'Search journal entries...',
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

                  // Show empty state if no entries at all (not filtered)
                  if (viewModel.entries.isEmpty && !viewModel.isLoading.value) {
                    return JournalEmptyState(
                      onAddEntry: () => viewModel.showAddEntryModal(),
                    );
                  }

                  // Show no search results if search is active but no filtered results
                  if (viewModel.filteredEntries.isEmpty && 
                      viewModel.searchQuery.value.isNotEmpty && 
                      !viewModel.isLoading.value) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
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
                              'No entries found',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDarkPink,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Try a different search term',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textLightPink,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.primaryRed,
                    onRefresh: viewModel.refreshEntries,
                    child: ListView.builder(
                      shrinkWrap: false,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.only(
                        left: metrics.cardPadding,
                        right: metrics.cardPadding,
                        top: metrics.sectionSpacing * 0.5,
                        bottom: 80, // Extra padding for FAB
                      ),
                      itemCount: viewModel.filteredEntries.length,
                      itemBuilder: (context, index) {
                        final entry = viewModel.filteredEntries[index];
                        return _buildEntryCard(entry, metrics, context);
                      },
                    ),
                  );
                },
              ),
            ),
            
            // Banner Ad at the bottom
            SafeArea(
              top: false,
              child: BannerAdWidget(
                adUnitId: AdMobService.instance.journalBannerAdUnitId,
                useAnchoredAdaptive: true,
                margin: EdgeInsets.symmetric(
                  vertical: context.responsiveSpacing(8),
                ),
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
          color: AppColors.IdeaColorText,
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
                  color: AppColors.IdeaColorText,
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/svg/new_svg/reward.svg',
                    width: 16,
                    height: 16,
                    colorFilter: ColorFilter.mode(
                      AppColors.primaryRed,
                      BlendMode.srcIn,
                    ),
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
                          color: AppColors.IdeaColorText,
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
                    child: SvgPicture.asset(
                      'assets/svg/new_svg/pencil.svg',
                      width: 20,
                      height: 20,
                      colorFilter: ColorFilter.mode(
                        AppColors.primaryRed,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  InkWell(
                    onTap: () => viewModel.deleteEntry(entry.id),
                    child: SvgPicture.asset(
                      'assets/svg/new_svg/delete.svg',
                      width: 22,
                      height: 22,
                      colorFilter: ColorFilter.mode(
                        AppColors.primaryRed,
                        BlendMode.srcIn,
                      ),
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
                SvgPicture.asset(
                  'assets/svg/new_svg/reward.svg',
                  width: 16,
                  height: 16,
                  colorFilter: ColorFilter.mode(
                    AppColors.primaryRed,
                    BlendMode.srcIn,
                  ),
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
                  child: SvgPicture.asset(
                    'assets/svg/new_svg/pencil.svg',
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(
                      AppColors.primaryRed,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                InkWell(
                  onTap: () => viewModel.deleteEntry(entry.id),
                  child: SvgPicture.asset(
                    'assets/svg/new_svg/delete.svg',
                    width: 22,
                    height: 22,
                    colorFilter: ColorFilter.mode(
                      AppColors.primaryRed,
                      BlendMode.srcIn,
                    ),
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
            color: AppColors.IdeaColorText,
            height: 1.5, // Line height for better readability
          ),
          softWrap: true,
        ),
      ],
    );
  }
}