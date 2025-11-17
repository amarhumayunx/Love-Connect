import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_connect/core/strings/get_started_screens_app_strings.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/core/utils/responsive_helper.dart';
import '../view_model/get_started_view_model.dart';
import 'package:google_fonts/google_fonts.dart';

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
    // Initialize the controller
    Get.put(GetStartedViewModel());

    // Setup animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Fade animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    // Slide animation (from bottom)
    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // Scale animation (subtle zoom in)
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // Start animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final GetStartedViewModel viewModel = Get.find<GetStartedViewModel>();

    return Scaffold(
      backgroundColor: AppColors.backgroundPink,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Responsive values
                      final horizontalPadding = ResponsiveHelper.width(
                        context,
                        2.5,
                      );
                      final logoWidth = ResponsiveHelper.imageSize(
                        context,
                        170,
                      );
                      final logoHeight = ResponsiveHelper.imageSize(
                        context,
                        67,
                      );
                      final heartImageSize = ResponsiveHelper.imageSize(
                        context,
                        300,
                      );
                      final titleFontSize = ResponsiveHelper.fontSize(
                        context,
                        30,
                      );
                      final subtitleFontSize = ResponsiveHelper.fontSize(
                        context,
                        16,
                      );
                      final buttonWidth = ResponsiveHelper.width(context, 58);
                      final buttonHeight = ResponsiveHelper.buttonHeight(
                        context,
                      );
                      final buttonFontSize = ResponsiveHelper.fontSize(
                        context,
                        16,
                      );

                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: ResponsiveHelper.spacing(context, 20),
                                ),

                                Row(
                                  children: [
                                    Image.asset(
                                      AppStrings.app_logo_strings,
                                      width: logoWidth,
                                      height: logoHeight,
                                      fit: BoxFit.contain,
                                    ),
                                  ],
                                ),

                                SizedBox(
                                  height: ResponsiveHelper.spacing(context, 20),
                                ),

                                Center(
                                  child: Image.asset(
                                    AppStrings.heart_logo_strings,
                                    width: heartImageSize,
                                    height: heartImageSize,
                                    fit: BoxFit.contain,
                                  ),
                                ),

                                SizedBox(
                                  height: ResponsiveHelper.spacing(context, 25),
                                ),

                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: horizontalPadding,
                                    ),
                                    child: Text(
                                      viewModel.data.title,
                                      textAlign: TextAlign.left,
                                      style: GoogleFonts.inter(
                                        fontSize: titleFontSize,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FontStyle.italic,
                                        color: AppColors.textDarkPink,
                                        letterSpacing: 0,
                                        height: 1.2,
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(
                                  height: ResponsiveHelper.spacing(context, 16),
                                ),

                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: horizontalPadding,
                                    ),
                                    child: Text(
                                      viewModel.data.subtitle,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontSize: subtitleFontSize,
                                        fontFamily:
                                            GoogleFonts.inter().fontFamily,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textLightPink,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(
                                  height: ResponsiveHelper.spacing(context, 80),
                                ),

                                Center(
                                  child: SizedBox(
                                    width: buttonWidth,
                                    height: buttonHeight,
                                    child: ElevatedButton(
                                      onPressed: viewModel.onGetStartedClick,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primaryRed,
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            28,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        AppStrings.getStarted,
                                        style: TextStyle(
                                          fontSize: buttonFontSize,
                                          fontFamily:
                                              GoogleFonts.poppins().fontFamily,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textWhite,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: ResponsiveHelper.spacing(context, 40),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
