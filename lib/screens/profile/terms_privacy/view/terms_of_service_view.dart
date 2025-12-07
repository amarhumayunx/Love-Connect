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
    final lastUpdated = DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.backgroundPink,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: metrics.headerHorizontalPadding,
                vertical: metrics.sectionSpacing * 0.5,
              ),
              decoration: BoxDecoration(color: AppColors.backgroundPink),
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
                  Expanded(
                    child: Text(
                      'Terms of Service',
                      style: GoogleFonts.inter(
                        fontSize: context.responsiveFont(20),
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark,
                      ),
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
                    // Introduction
                    _buildSectionCard(
                      context,
                      metrics,
                      Icons.description_rounded,
                      'Introduction',
                      'Welcome to Love Connect. By accessing or using our app, you agree to be bound by these Terms of Service. If you disagree with any part of these terms, you may not access the service.',
                    ),

                    SizedBox(height: metrics.sectionSpacing * 0.75),

                    // Acceptance of Terms
                    _buildSectionCard(
                      context,
                      metrics,
                      Icons.check_circle_outline,
                      '1. Acceptance of Terms',
                      'By accessing and using Love Connect, you accept and agree to be bound by the terms and provisions of this agreement. If you do not agree to abide by the above, please do not use this service.',
                    ),

                    SizedBox(height: metrics.sectionSpacing * 0.75),

                    // Use License
                    _buildSectionCard(
                      context,
                      metrics,
                      Icons.verified_user_outlined,
                      '2. Use License',
                      'Permission is granted to use Love Connect for personal, non-commercial purposes. This license does not include:\n\n• Any resale or commercial use of the app\n• Copying or modifying the app\n• Using the app for any illegal purpose\n• Removing any copyright or proprietary notations',
                    ),

                    SizedBox(height: metrics.sectionSpacing * 0.75),

                    // User Account
                    _buildSectionCard(
                      context,
                      metrics,
                      Icons.person_outline,
                      '3. User Account',
                      'You are responsible for:\n\n• Maintaining the confidentiality of your account and password\n• All activities that occur under your account\n• Notifying us immediately of any unauthorized use\n• Ensuring that your account information is accurate and up-to-date',
                    ),

                    SizedBox(height: metrics.sectionSpacing * 0.75),

                    // Privacy
                    _buildSectionCard(
                      context,
                      metrics,
                      Icons.privacy_tip_outlined,
                      '4. Privacy',
                      'Your use of Love Connect is also governed by our Privacy Policy. Please review our Privacy Policy, which also governs your use of the service, to understand our practices regarding the collection and use of your personal information.',
                    ),

                    SizedBox(height: metrics.sectionSpacing * 0.75),

                    // Prohibited Uses
                    _buildSectionCard(
                      context,
                      metrics,
                      Icons.block,
                      '5. Prohibited Uses',
                      'You may not use Love Connect:\n\n• In any way that violates any applicable law or regulation\n• To transmit any malicious code or viruses\n• To impersonate or attempt to impersonate another user\n• To engage in any automated use of the system\n• To interfere with or disrupt the service or servers',
                    ),

                    SizedBox(height: metrics.sectionSpacing * 0.75),

                    // Content and Conduct
                    _buildSectionCard(
                      context,
                      metrics,
                      Icons.content_copy_outlined,
                      '6. Content and Conduct',
                      'You are responsible for all content you post or share through Love Connect. You agree not to post content that:\n\n• Is illegal, harmful, or violates any rights\n• Contains spam or unsolicited messages\n• Infringes on intellectual property rights\n• Is defamatory, obscene, or offensive',
                    ),

                    SizedBox(height: metrics.sectionSpacing * 0.75),

                    // Disclaimer
                    _buildSectionCard(
                      context,
                      metrics,
                      Icons.info_outline,
                      '7. Disclaimer',
                      'The materials on Love Connect are provided on an "as is" basis. Love Connect makes no warranties, expressed or implied, and hereby disclaims and negates all other warranties including, without limitation, implied warranties or conditions of merchantability, fitness for a particular purpose, or non-infringement of intellectual property.',
                    ),

                    SizedBox(height: metrics.sectionSpacing * 0.75),

                    // Limitations
                    _buildSectionCard(
                      context,
                      metrics,
                      Icons.warning_amber_rounded,
                      '8. Limitations',
                      'In no event shall Love Connect or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out of the use or inability to use the app, even if Love Connect has been notified orally or in writing of the possibility of such damage.',
                    ),

                    SizedBox(height: metrics.sectionSpacing * 0.75),

                    // Revisions
                    _buildSectionCard(
                      context,
                      metrics,
                      Icons.update_outlined,
                      '9. Revisions and Errata',
                      'Love Connect may revise these terms of service at any time without notice. By using this app, you are agreeing to be bound by the then current version of these terms of service. We encourage you to review these terms periodically.',
                    ),

                    SizedBox(height: metrics.sectionSpacing * 0.75),

                    // Termination
                    _buildSectionCard(
                      context,
                      metrics,
                      Icons.cancel_outlined,
                      '10. Termination',
                      'We may terminate or suspend your account and access to the service immediately, without prior notice or liability, for any reason whatsoever, including without limitation if you breach the Terms. Upon termination, your right to use the service will immediately cease.',
                    ),

                    SizedBox(height: metrics.sectionSpacing * 0.75),

                    // Contact Information
                    _buildSectionCard(
                      context,
                      metrics,
                      Icons.contact_support_outlined,
                      '11. Contact Information',
                      'If you have any questions about these Terms of Service, please contact us at:\n\nEmail: support@loveconnect.app',
                    ),

                    SizedBox(height: metrics.sectionSpacing * 2),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context,
    HomeLayoutMetrics metrics,
    IconData icon,
    String title,
    String content,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(metrics.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryRed.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primaryRed, size: 20),
              ),
              SizedBox(width: context.responsiveSpacing(12)),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: context.responsiveFont(16),
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.responsiveSpacing(12)),
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: context.responsiveFont(14),
              fontWeight: FontWeight.w400,
              color: AppColors.textLightPink,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}
