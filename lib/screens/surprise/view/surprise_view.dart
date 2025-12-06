import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/core/utils/media_query_extensions.dart';
import 'package:love_connect/screens/surprise/view/widgets/date_wheel_widget.dart';
import 'package:love_connect/screens/surprise/view/widgets/scratch_card_widget.dart';
import 'package:love_connect/screens/surprise/view_model/surprise_view_model.dart';

class SurpriseView extends StatelessWidget {
  const SurpriseView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SurpriseViewModel());

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
                        'Surprise Hub',
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
                        title: '🎡 Spin for a Plan',
                        subtitle: 'Can\'t decide? Let the wheel pick your next date!',
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFE1BEE7), // Light Purple
                            Color(0xFFF8BBD0), // Light Pink
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        icon: Icons.casino_rounded,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          DateWheelWidget.show(context);
                        },
                      ),
                      SizedBox(height: context.responsiveSpacing(24)),
                      _buildOptionCard(
                        context,
                        title: '💌 Lucky Love Coupon',
                        subtitle: 'Feeling lucky? Scratch to reveal a treat!',
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFFCCBC), // Peach
                            Color(0xFFEF5350), // Red
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        icon: Icons.card_giftcard_rounded,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ScratchCardWidget.show(context);
                        },
                      ),
                    ],
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
    required IconData icon,
    required VoidCallback onTap,
  }) {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(context.responsiveSpacing(12)),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: AppColors.white,
                      size: context.responsiveImage(32),
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
            ],
          ),
        ),
      ),
    );
  }
}

