import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/core/utils/media_query_extensions.dart';
import 'package:love_connect/core/widgets/decision_maker_widget.dart';
import 'package:love_connect/screens/surprise/view/widgets/date_wheel_widget.dart';
import 'package:love_connect/screens/surprise/view/widgets/scratch_card_widget.dart';
import 'package:love_connect/screens/surprise/view_model/surprise_view_model.dart';

class SurpriseView extends StatefulWidget {
  const SurpriseView({super.key});

  @override
  State<SurpriseView> createState() => _SurpriseViewState();
}

class _SurpriseViewState extends State<SurpriseView>
    with SingleTickerProviderStateMixin {
  late final SurpriseViewModel viewModel;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    viewModel = Get.put(SurpriseViewModel(), permanent: false);

    // Animation setup
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    Get.delete<SurpriseViewModel>(force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.backgroundPink,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
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
                        'Surprises',
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

              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.widthPct(5),
                    vertical: context.responsiveSpacing(20),
                  ),
                  child: Obx(
                    () {
                      // Check if ideas are loaded
                      if (viewModel.allIdeas.isEmpty) {
                        return _buildEmptyState(context);
                      }

                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Welcome message
                              Text(
                                'What are you in the mood for?',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: context.responsiveFont(20),
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                              SizedBox(height: context.responsiveSpacing(8)),
                              Text(
                                'Choose your surprise adventure',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: context.responsiveFont(14),
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textLightPink,
                                ),
                              ),
                              SizedBox(height: context.responsiveSpacing(40)),

                              // Option Cards
                              _buildOptionCard(
                                context,
                                title: 'Spin for a Plan',
                                subtitle: 'Can\'t decide? Let the wheel pick your next date!',
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFE1BEE7), // Light Purple
                                    Color(0xFFF8BBD0), // Light Pink
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                svgPath: 'assets/svg/new_svg/spin.svg',
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  if (viewModel.allIdeas.isNotEmpty) {
                                    DateWheelWidget.show(context);
                                  } else {
                                    _showErrorSnackbar(
                                      'No ideas available. Please try again later.',
                                    );
                                  }
                                },
                              ),
                              SizedBox(height: context.responsiveSpacing(24)),
                              _buildOptionCard(
                                context,
                                title: 'Lucky Love Coupon',
                                subtitle: 'Feeling lucky? Scratch to reveal a treat!',
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFFCCBC), // Peach
                                    Color(0xFFEF5350), // Red
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                svgPath: 'assets/svg/new_svg/coupon.svg',
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  ScratchCardWidget.show(context);
                                },
                              ),
                              SizedBox(height: context.responsiveSpacing(24)),
                              _buildOptionCard(
                                context,
                                title: 'Decision Maker',
                                subtitle: 'Can\'t decide what to eat or watch? Let the dice decide!',
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFBBDEFB), // Light Blue
                                    Color(0xFF90CAF9), // Blue
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                svgPath: 'assets/svg/new_svg/dice.svg',
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  _showDecisionMaker(context);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required Gradient gradient,
        required String svgPath, // 👈 SVG path or icon name
        required VoidCallback onTap,
      }) {
    // Check if svgPath is an icon name (starts with 'Icons.')
    final bool isIcon = svgPath.startsWith('Icons.');
    IconData? iconData;
    if (isIcon) {
      // Extract icon name and get the icon data
      final iconName = svgPath.replaceFirst('Icons.', '');
      iconData = _getIconData(iconName);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(
          minHeight: context.heightPct(18),
        ),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryRed.withOpacity(0.2),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(context.responsiveSpacing(24)),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(context.responsiveSpacing(12)),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: isIcon && iconData != null
                    ? Icon(
                        iconData,
                        size: context.responsiveImage(32),
                        color: AppColors.white,
                      )
                    : SvgPicture.asset(
                        svgPath,
                        width: context.responsiveImage(32),
                        height: context.responsiveImage(32),
                        colorFilter: const ColorFilter.mode(
                          AppColors.primaryDark,
                          BlendMode.srcIn,
                        ),
                        placeholderBuilder: (BuildContext context) => Icon(
                          Icons.image_not_supported,
                          size: context.responsiveImage(32),
                          color: AppColors.white,
                        ),
                      ),
              ),
              SizedBox(width: context.responsiveSpacing(16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: context.responsiveFont(20),
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                    SizedBox(height: context.responsiveSpacing(4)),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: context.responsiveFont(13),
                        fontWeight: FontWeight.w400,
                        color: AppColors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.white,
                size: context.responsiveImage(20),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.responsiveSpacing(40)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sentiment_dissatisfied_rounded,
              size: context.responsiveImage(80),
              color: AppColors.textLightPink,
            ),
            SizedBox(height: context.responsiveSpacing(24)),
            Text(
              'No Ideas Available',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: context.responsiveFont(20),
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark,
              ),
            ),
            SizedBox(height: context.responsiveSpacing(12)),
            Text(
              'We couldn\'t load any date ideas right now.\nPlease try again later.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: context.responsiveFont(14),
                fontWeight: FontWeight.w400,
                color: AppColors.textLightPink,
              ),
            ),
            SizedBox(height: context.responsiveSpacing(32)),
            ElevatedButton.icon(
              onPressed: () {
                viewModel.loadIdeas();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: Text(
                'Retry',
                style: GoogleFonts.inter(
                  fontSize: context.responsiveFont(16),
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: context.responsiveSpacing(24),
                  vertical: context.responsiveSpacing(14),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primaryRed.withOpacity(0.9),
      colorText: AppColors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
    );
  }

  IconData? _getIconData(String iconName) {
    // Map icon names to IconData
    switch (iconName) {
      case 'casino_rounded':
        return Icons.casino_rounded;
      case 'casino':
        return Icons.casino;
      case 'dice':
        return Icons.casino_rounded;
      default:
        return Icons.casino_rounded; // Default fallback
    }
  }

  void _showDecisionMaker(BuildContext context) {
    // Pakistan-specific decision options
    final defaultOptions = [
      'Biryani',
      'Karahi',
      'Nihari',
      'Haleem',
      'BBQ',
      'Chapli Kebab',
      'Seekh Kebab',
      'Chicken Tikka',
      'Mutton Karahi',
      'Fish Fry',
      'Daal Chawal',
      'Chana Chaat',
      'Samosa',
      'Pakora',
      'Gol Gappay',
      'Dahi Bhallay',
      'Chicken Roll',
      'Shawarma',
      'Pulao',
      'Qorma',
      'Haleem',
      'Paye',
      'Nihari',
      'Chicken Handi',
      'Mutton Pulao',
      'Chicken Biryani',
      'Beef Biryani',
      'Mutton Biryani',
      'Zinger Burger',
      'Club Sandwich',
      'Chicken Wings',
      'Pasta',
      'Pizza',
      'Chinese',
      'Thai',
      'Italian',
    ];

    DecisionMakerWidget.show(context, defaultOptions);
  }
}

