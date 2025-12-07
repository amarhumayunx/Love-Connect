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
                      'Privacy Policy',
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
                      Icons.info_outline,
                      'Introduction',
                      'At Love Connect, we take your privacy seriously. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application. Please read this privacy policy carefully.',
                    ),

                    SizedBox(height: metrics.sectionSpacing * 0.75),

                    // Information We Collect
                    _buildSectionCard(
                      context,
                      metrics,
                      Icons.collections_bookmark_outlined,
                      '1. Information We Collect',
                      'We collect information that you provide directly to us:\n\n• Account Information: Name, email address, profile picture\n• Content: Plans, journal entries, photos, and messages\n• Device Information: Device type, operating system, unique device identifiers\n• Usage Data: How you interact with the app, features used, time spent\n• Location Data: If you enable location services for planning dates',
                    ),

                    SizedBox(height: metrics.sectionSpacing * 0.75),

                    // How We Use Your Information
                    _buildSectionCard(
                      context,
                      metrics,
                      Icons.settings_outlined,
                      '2. How We Use Your Information',
                      'We use the information we collect to:\n\n• Provide, maintain, and improve our services\n• Process transactions and send related information\n• Send you technical notices and support messages\n• Respond to your comments, questions, and requests\n• Monitor and analyze trends and usage\n• Personalize and improve your experience\n• Send you promotional communications (with your consent)',
                    ),

                    SizedBox(height: metrics.sectionSpacing * 0.75),

                    // Information Sharing
                    _buildSectionCard(
                      context,
                      metrics,
                      Icons.share_outlined,
                      '3. Information Sharing and Disclosure',
                      'We do not sell, trade, or rent your personal information to third parties. We may share your information only in the following circumstances:\n\n• With your explicit consent\n• To comply with legal obligations\n• To protect our rights and safety\n• With service providers who assist us in operating the app\n• In connection with a business transfer or merger',
                    ),

                    SizedBox(height: metrics.sectionSpacing * 0.75),

                    // Data Security
                    _buildSectionCard(
                      context,
                      metrics,
                      Icons.security,
                      '4. Data Security',
                      'We implement appropriate technical and organizational security measures to protect your personal information:\n\n• Encryption of data in transit and at rest\n• Secure authentication and authorization\n• Regular security assessments\n• Access controls and monitoring\n• However, no method of transmission over the internet is 100% secure',
                    ),

                    SizedBox(height: metrics.sectionSpacing * 0.75),

                    // Your Rights
                    _buildSectionCard(
                      context,
                      metrics,
                      Icons.account_circle_outlined,
                      '5. Your Rights and Choices',
                      'You have the right to:\n\n• Access your personal information\n• Update or correct your information\n• Delete your account and data\n• Opt-out of promotional communications\n• Request a copy of your data\n• Object to certain processing activities\n\nYou can exercise these rights through the app settings or by contacting us.',
                    ),

                    SizedBox(height: metrics.sectionSpacing * 0.75),

                    // Data Retention
                    _buildSectionCard(
                      context,
                      metrics,
                      Icons.schedule_outlined,
                      '6. Data Retention',
                      'We retain your personal information for as long as necessary to provide you with our services and fulfill the purposes described in this policy. When you delete your account, we will delete or anonymize your personal information, except where we are required to retain it for legal purposes.',
                    ),

                    SizedBox(height: metrics.sectionSpacing * 0.75),

                    // Third-Party Services
                    _buildSectionCard(
                      context,
                      metrics,
                      Icons.link_outlined,
                      '7. Third-Party Services',
                      'Our app may contain links to third-party websites or services. We are not responsible for the privacy practices of these third parties. We encourage you to read the privacy policies of any third-party services you access through our app.',
                    ),

                    SizedBox(height: metrics.sectionSpacing * 0.75),

                    // Children's Privacy
                    _buildSectionCard(
                      context,
                      metrics,
                      Icons.child_care_outlined,
                      '8. Children\'s Privacy',
                      'Our service is not intended for children under the age of 13. We do not knowingly collect personal information from children under 13. If you are a parent or guardian and believe your child has provided us with personal information, please contact us immediately.',
                    ),

                    SizedBox(height: metrics.sectionSpacing * 0.75),

                    // International Users
                    _buildSectionCard(
                      context,
                      metrics,
                      Icons.public_outlined,
                      '9. International Data Transfers',
                      'Your information may be transferred to and maintained on computers located outside of your state, province, country, or other governmental jurisdiction where data protection laws may differ. By using our service, you consent to the transfer of your information to these facilities.',
                    ),

                    SizedBox(height: metrics.sectionSpacing * 0.75),

                    // Changes to Policy
                    _buildSectionCard(
                      context,
                      metrics,
                      Icons.update_outlined,
                      '10. Changes to This Privacy Policy',
                      'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last Updated" date. You are advised to review this Privacy Policy periodically for any changes.',
                    ),

                    SizedBox(height: metrics.sectionSpacing * 0.75),

                    // Contact Us
                    _buildSectionCard(
                      context,
                      metrics,
                      Icons.contact_support_outlined,
                      '11. Contact Us',
                      'If you have any questions about this Privacy Policy or our privacy practices, please contact us at:\n\nEmail: support@loveconnect.app\n\nWe will respond to your inquiry within a reasonable timeframe.',
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
