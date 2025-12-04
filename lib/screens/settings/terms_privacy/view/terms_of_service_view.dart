import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/core/utils/media_query_extensions.dart';
import 'package:love_connect/screens/home/view/widgets/home_layout_metrics.dart';

class TermsOfServiceView extends StatelessWidget {
  const TermsOfServiceView({super.key});

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
                    'Terms of Service',
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
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: metrics.cardPadding,
                  vertical: metrics.sectionSpacing,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Last Updated: ${DateTime.now().toString().split(' ')[0]}',
                      style: GoogleFonts.inter(
                        fontSize: context.responsiveFont(12),
                        fontWeight: FontWeight.w400,
                        color: AppColors.textLightPink,
                      ),
                    ),
                    SizedBox(height: metrics.sectionSpacing),
                    _buildSection(
                      '1. Acceptance of Terms',
                      'By accessing and using Love Connect, you accept and agree to be bound by the terms and provision of this agreement.',
                      context,
                    ),
                    SizedBox(height: metrics.sectionSpacing),
                    _buildSection(
                      '2. Use License',
                      'Permission is granted to temporarily download one copy of Love Connect for personal, non-commercial transitory viewing only.',
                      context,
                    ),
                    SizedBox(height: metrics.sectionSpacing),
                    _buildSection(
                      '3. User Account',
                      'You are responsible for maintaining the confidentiality of your account and password. You agree to accept responsibility for all activities that occur under your account.',
                      context,
                    ),
                    SizedBox(height: metrics.sectionSpacing),
                    _buildSection(
                      '4. Privacy',
                      'Your use of Love Connect is also governed by our Privacy Policy. Please review our Privacy Policy to understand our practices.',
                      context,
                    ),
                    SizedBox(height: metrics.sectionSpacing),
                    _buildSection(
                      '5. Prohibited Uses',
                      'You may not use Love Connect in any way that causes, or may cause, damage to the app or impairment of the availability or accessibility of the app.',
                      context,
                    ),
                    SizedBox(height: metrics.sectionSpacing),
                    _buildSection(
                      '6. Disclaimer',
                      'The materials on Love Connect are provided on an \'as is\' basis. Love Connect makes no warranties, expressed or implied, and hereby disclaims and negates all other warranties.',
                      context,
                    ),
                    SizedBox(height: metrics.sectionSpacing),
                    _buildSection(
                      '7. Limitations',
                      'In no event shall Love Connect or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit) arising out of the use or inability to use the app.',
                      context,
                    ),
                    SizedBox(height: metrics.sectionSpacing),
                    _buildSection(
                      '8. Revisions',
                      'Love Connect may revise these terms of service at any time without notice. By using this app you are agreeing to be bound by the then current version of these terms of service.',
                      context,
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

  Widget _buildSection(String title, String content, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: context.responsiveFont(18),
            fontWeight: FontWeight.w600,
            color: AppColors.primaryDark,
          ),
        ),
        SizedBox(height: 8),
        Text(
          content,
          style: GoogleFonts.inter(
            fontSize: context.responsiveFont(14),
            fontWeight: FontWeight.w400,
            color: AppColors.textLightPink,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

