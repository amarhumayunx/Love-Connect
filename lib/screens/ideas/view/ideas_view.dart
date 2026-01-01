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
                horizontal: context.widthPct(5),
                vertical: context.responsiveSpacing(16),
              ),
              child: Row(
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
                      'Ideas',
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
      margin: EdgeInsets.only(bottom: metrics.sectionSpacing * 0.6),
      padding: EdgeInsets.symmetric(
        horizontal: metrics.cardPadding * 1.1,
        vertical: metrics.cardPadding * 0.9,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 1,
            offset: Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: AppColors.IdeaColorText,
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
                    color: AppColors.textDarkPink,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  '${idea.category} • ${idea.location}',
                  style: GoogleFonts.inter(
                    fontSize: context.responsiveFont(13),
                    fontWeight: FontWeight.w400,
                    color: AppColors.IdeaColorText,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          ElevatedButton(
            onPressed: () => viewModel.useIdea(idea),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              foregroundColor: AppColors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(34),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 26,
                vertical: 8,
              ),
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