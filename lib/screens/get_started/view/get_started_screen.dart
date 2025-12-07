import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_connect/core/strings/get_started_screens_app_strings.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/core/utils/media_query_extensions.dart';
import 'package:love_connect/screens/get_started/view/widgets/get_started_cta_button.dart';
import 'package:love_connect/screens/get_started/view/widgets/get_started_illustration.dart';
import 'package:love_connect/screens/get_started/view/widgets/get_started_logo.dart';
import 'package:love_connect/screens/get_started/view/widgets/get_started_subtitle.dart';
import 'package:love_connect/screens/get_started/view/widgets/get_started_title.dart';
import '../view_model/get_started_view_model.dart';

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    Get.put(GetStartedViewModel());

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final GetStartedViewModel viewModel = Get.find();
    final horizontalPadding = context.widthPct(2.5);
    final logoWidth = context.responsiveImage(170);
    final logoHeight = context.responsiveImage(67);
    final heartImageSize = context.responsiveImage(300);
    final titleFontSize = context.responsiveFont(30);
    final subtitleFontSize = context.responsiveFont(16);
    final buttonWidth = context.widthPct(45);
    final buttonHeight = context.responsiveButtonHeight();
    final buttonFontSize = context.responsiveFont(16);

    return Scaffold(
      backgroundColor: AppColors.backgroundPink,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(
                      bottom: context.responsiveSpacing(4),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: context.responsiveSpacing(20)),
                          Row(
                            children: [
                              GetStartedLogo(
                                width: logoWidth,
                                height: logoHeight,
                              ),
                            ],
                          ),
                          SizedBox(height: context.responsiveSpacing(20)),
                          Center(
                            child: GetStartedIllustration(
                              size: heartImageSize,
                            ),
                          ),
                          SizedBox(height: context.responsiveSpacing(25)),
                          Center(
                            child: GetStartedTitle(
                              text: viewModel.data.title,
                              fontSize: titleFontSize,
                              padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding,
                              ),
                            ),
                          ),
                          SizedBox(height: context.responsiveSpacing(16)),
                          Center(
                            child: GetStartedSubtitle(
                              text: viewModel.data.subtitle,
                              fontSize: subtitleFontSize,
                              padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding,
                              ),
                            ),
                          ),
                          SizedBox(height: context.responsiveSpacing(10)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      // Button alag container mein bottom pe
      bottomNavigationBar: Container(
        color: AppColors.backgroundPink,
        padding: EdgeInsets.only(
          left: context.widthPct(14),
          right: context.widthPct(14),
          top: context.responsiveSpacing(2),
          bottom: MediaQuery.of(context).padding.bottom + context.responsiveSpacing(30),
        ),
        child: GetStartedCtaButton(
          width: buttonWidth,
          height: buttonHeight,
          fontSize: buttonFontSize,
          label: AppStrings.getStarted,
          onPressed: viewModel.onGetStartedClick,
        ),
      ),
    );
  }
}