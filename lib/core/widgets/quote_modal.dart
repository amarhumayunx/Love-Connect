import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/core/models/idea_model.dart';
import 'package:love_connect/core/services/quotes_service.dart';
import 'package:love_connect/core/utils/media_query_extensions.dart';
import 'package:love_connect/screens/add_plan/view/add_plan_view.dart';

class QuoteModal extends StatefulWidget {
  final String? initialQuote;

  const QuoteModal({
    super.key,
    this.initialQuote,
  });

  static void show({String? quote}) {
    Get.dialog(
      QuoteModal(initialQuote: quote),
      barrierDismissible: true,
    );
  }

  @override
  State<QuoteModal> createState() => _QuoteModalState();
}

class _QuoteModalState extends State<QuoteModal> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final QuotesService _quotesService = QuotesService();
  late String _currentQuote;
  late List<IdeaModel> _ideas;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _currentQuote = widget.initialQuote ?? _quotesService.getRandomQuote();
    _ideas = _quotesService.getRandomIdeas(count: 8);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _changeQuote() {
    setState(() {
      _currentQuote = _quotesService.getRandomQuote();
    });
  }

  Future<void> _copyQuote() async {
    await Clipboard.setData(ClipboardData(text: _currentQuote));
    Get.back();
    Get.snackbar(
      'Copied',
      'Quote copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primaryRed,
      colorText: AppColors.white,
      duration: Duration(seconds: 2),
    );
  }

  void _useIdea(IdeaModel idea) {
    Get.back();
    Get.to(
      () => AddPlanView(),
      arguments: {
        'title': idea.title,
        'place': idea.location,
        'type': idea.category,
      },
    );
    Get.snackbar(
      'Idea Selected',
      '${idea.title} has been added to your plan',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primaryRed,
      colorText: AppColors.white,
      duration: Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(20),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _currentTabIndex == 0 ? 'Romantic Quotes' : 'Romantic Ideas',
                    style: GoogleFonts.inter(
                      fontSize: context.responsiveFont(18),
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: AppColors.primaryDark,
                    ),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),

            // Tabs
            TabBar(
              controller: _tabController,
              labelColor: AppColors.primaryRed,
              unselectedLabelColor: AppColors.textLightPink,
              indicatorColor: AppColors.primaryRed,
              tabs: [
                Tab(
                  child: Text(
                    'Quotes',
                    style: GoogleFonts.inter(
                      fontSize: context.responsiveFont(14),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    'Ideas',
                    style: GoogleFonts.inter(
                      fontSize: context.responsiveFont(14),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            // Content
            Flexible(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Quotes Tab
                  _buildQuotesTab(context),
                  // Ideas Tab
                  _buildIdeasTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuotesTab(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Quote Card - Tap to change
          GestureDetector(
            onTap: _changeQuote,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.backgroundPink.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.textLightPink.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.favorite,
                    color: AppColors.primaryRed,
                    size: 32,
                  ),
                  SizedBox(height: 12),
                  Text(
                    _currentQuote,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: context.responsiveFont(16),
                      fontWeight: FontWeight.w400,
                      color: AppColors.primaryDark,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap to change quote',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: context.responsiveFont(12),
                      fontWeight: FontWeight.w400,
                      color: AppColors.textLightPink,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 20),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.primaryRed),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: Size(
                      double.infinity,
                      context.responsiveButtonHeight(),
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: GoogleFonts.inter(
                      fontSize: context.responsiveFont(16),
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryRed,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _copyQuote,
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
                  child: Text(
                    'Copy',
                    style: GoogleFonts.inter(
                      fontSize: context.responsiveFont(16),
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIdeasTab(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _ideas.length,
        itemBuilder: (context, index) {
          final idea = _ideas[index];
          return Container(
            margin: EdgeInsets.only(bottom: 12),
            padding: EdgeInsets.all(16),
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
                  onPressed: () => _useIdea(idea),
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
        },
      ),
    );
  }
}

