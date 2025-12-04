import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/core/utils/media_query_extensions.dart';
import 'package:love_connect/screens/home/view/widgets/home_layout_metrics.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

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
                    'Privacy Policy',
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
                      '1. Information We Collect',
                      'We collect information that you provide directly to us, such as when you create an account, update your profile, or contact us for support.',
                      context,
                    ),
                    SizedBox(height: metrics.sectionSpacing),
                    _buildSection(
                      '2. How We Use Your Information',
                      'We use the information we collect to provide, maintain, and improve our services, process transactions, send you technical notices, and respond to your comments and questions.',
                      context,
                    ),
                    SizedBox(height: metrics.sectionSpacing),
                    _buildSection(
                      '3. Information Sharing',
                      'We do not sell, trade, or otherwise transfer your personal information to third parties without your consent, except as described in this policy.',
                      context,
                    ),
                    SizedBox(height: metrics.sectionSpacing),
                    _buildSection(
                      '4. Data Security',
                      'We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.',
                      context,
                    ),
                    SizedBox(height: metrics.sectionSpacing),
                    _buildSection(
                      '5. Your Rights',
                      'You have the right to access, update, or delete your personal information at any time. You can do this through the app settings or by contacting us.',
                      context,
                    ),
                    SizedBox(height: metrics.sectionSpacing),
                    _buildSection(
                      '6. Cookies and Tracking',
                      'We may use cookies and similar tracking technologies to track activity on our app and hold certain information.',
                      context,
                    ),
                    SizedBox(height: metrics.sectionSpacing),
                    _buildSection(
                      '7. Children\'s Privacy',
                      'Our service is not intended for children under the age of 13. We do not knowingly collect personal information from children under 13.',
                      context,
                    ),
                    SizedBox(height: metrics.sectionSpacing),
                    _buildSection(
                      '8. Changes to This Policy',
                      'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page.',
                      context,
                    ),
                    SizedBox(height: metrics.sectionSpacing),
                    _buildSection(
                      '9. Contact Us',
                      'If you have any questions about this Privacy Policy, please contact us at support@loveconnect.app',
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

