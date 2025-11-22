import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/core/models/idea_model.dart';
import 'package:love_connect/core/utils/media_query_extensions.dart';
import 'package:love_connect/screens/home/view/widgets/home_layout_metrics.dart';
import 'package:love_connect/screens/ideas/view_model/ideas_view_model.dart';

class IdeasView extends StatefulWidget {
  const IdeasView({super.key});

  @override
  State<IdeasView> createState() => _IdeasViewState();
}

class _IdeasViewState extends State<IdeasView> {
  late final IdeasViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Get.put(IdeasViewModel());
  }

  @override
  void dispose() {
    Get.delete<IdeasViewModel>();
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
                  IconButton(
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
                () => ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: metrics.cardPadding,
                    vertical: metrics.sectionSpacing * 0.5,
                  ),
                  itemCount: viewModel.ideas.length,
                  itemBuilder: (context, index) {
                    final idea = viewModel.ideas[index];
                    return _buildIdeaCard(idea, metrics, context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdeaCard(
    IdeaModel idea,
    HomeLayoutMetrics metrics,
    BuildContext context,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: metrics.sectionSpacing * 0.5),
      padding: EdgeInsets.all(metrics.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.textLightPink.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  idea.title,
                  style: GoogleFonts.inter(
                    fontSize: context.responsiveFont(16),
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${idea.category} • ${idea.location}',
                  style: GoogleFonts.inter(
                    fontSize: context.responsiveFont(12),
                    fontWeight: FontWeight.w400,
                    color: AppColors.textLightPink,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => viewModel.useIdea(idea),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: Size(80, context.responsiveButtonHeight() * 0.8),
            ),
            child: Text(
              'Use',
              style: GoogleFonts.inter(
                fontSize: context.responsiveFont(14),
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

