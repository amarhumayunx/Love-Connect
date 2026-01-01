import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:love_connect/core/utils/media_query_extensions.dart';
import 'package:love_connect/core/widgets/banner_ad_widget.dart';
import 'package:love_connect/core/services/admob_service.dart';
import 'package:love_connect/screens/home/view/widgets/home_layout_metrics.dart';
import 'package:love_connect/screens/home/view_model/home_view_model.dart';
import 'package:love_connect/screens/profile/view_model/profile_view_model.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late final ProfileViewModel viewModel;
  HomeViewModel? homeViewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Get.put(ProfileViewModel());
    // Try to find HomeViewModel, but don't fail if it doesn't exist
    try {
      homeViewModel = Get.find<HomeViewModel>();
      // Note: navigationSource will be set by onBottomNavTap (true) or onQuickActionTap (false)
      // The isFromNavbar method now defaults to true for profile screen
    } catch (e) {
      // HomeViewModel not found, likely navigated via Get.to() from outside MainNavigationView
      homeViewModel = null;
    }
  }

  @override
  void dispose() {
    Get.delete<ProfileViewModel>();
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
                horizontal: metrics.headerHorizontalPadding,
                vertical: metrics.sectionSpacing * 0.5,
              ),
              child: Row(
                children: [
                  // Show back arrow only if navigated from quick actions or profile pic tap
                  homeViewModel != null
                      ? Obx(
                          () => homeViewModel!.isFromNavbar('profile')
                              ? const SizedBox.shrink() // Hide back arrow if from navbar
                              : GestureDetector(
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
                        )
                      : GestureDetector(
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
                      viewModel.model.title,
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
                padding: EdgeInsets.symmetric(horizontal: metrics.cardPadding),
                child: Obx(
                  () => Column(
                    children: [
                      // Profile Picture and Info
                      Container(
                        margin: EdgeInsets.only(bottom: metrics.sectionSpacing),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: viewModel.showEditProfileModal,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey[200],
                                ),
                                child: ClipOval(
                                  child: _buildProfileImage(
                                    viewModel
                                        .userProfile
                                        .value
                                        .profilePictureUrl,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: metrics.sectionSpacing * 0.5),
                            Text(
                              viewModel.userProfile.value.name,
                              style: GoogleFonts.inter(
                                fontSize: context.responsiveFont(18),
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryDark,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              viewModel.userProfile.value.about,
                              style: GoogleFonts.inter(
                                fontSize: context.responsiveFont(14),
                                fontWeight: FontWeight.w400,
                                color: AppColors.textLightPink,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Banner Ad
                      Builder(
                        builder: (context) {
                          final adUnitId = AdMobService.instance.settingsBannerAdUnitId;
                          if (kDebugMode) {
                            print('📱 PROFILE: Using banner ad unit ID: $adUnitId');
                          }
                          return Center(
                            child: BannerAdWidget(
                              adUnitId: adUnitId,
                              margin: EdgeInsets.symmetric(
                                vertical: metrics.sectionSpacing * 0.5,
                              ),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: metrics.sectionSpacing),

                      // Account Section
                      _buildSection('Account', [
                        _buildSettingTile(
                          'Edit Profile',
                          'assets/svg/new_svg/pencil.svg',
                          onTap: () {
                            viewModel.showEditProfileModal();
                          },
                          metrics: metrics,
                          context: context,
                        ),
                        _buildDivider(),
                        _buildSettingTile(
                          'Change Password',
                          'assets/svg/new_svg/password.svg',
                          onTap: () {
                            viewModel.navigateToChangePassword();
                          },
                          metrics: metrics,
                          context: context,
                        ),
                      ], metrics),

                      SizedBox(height: metrics.sectionSpacing),

                      // Notifications Section
                      _buildSection('Notifications', [
                        _buildToggleTile(
                          'Push Notifications',
                          'notifications',
                          'assets/svg/new_svg/notification_svg.svg',
                          viewModel,
                          metrics,
                          context,
                        ),
                        _buildDivider(),
                        _buildToggleTile(
                          'Plan Reminders',
                          'planReminder',
                          'assets/svg/new_svg/reminder.svg',
                          viewModel,
                          metrics,
                          context,
                        ),
                      ], metrics),

                      SizedBox(height: metrics.sectionSpacing),

                      // Support & About Section
                      _buildSection('Support & About', [
                        _buildSettingTile(
                          'Help & Support',
                          'assets/svg/new_svg/help.svg',
                          onTap: viewModel.contactSupport,
                          metrics: metrics,
                          context: context,
                        ),
                        _buildDivider(),
                        _buildSettingTile(
                          'Rate App',
                          'assets/svg/new_svg/rate.svg',
                          onTap: viewModel.rateApp,
                          metrics: metrics,
                          context: context,
                        ),
                        _buildDivider(),
                        _buildSettingTile(
                          'Share App',
                          'assets/svg/new_svg/share.svg',
                          onTap: viewModel.shareApp,
                          metrics: metrics,
                          context: context,
                        ),
                        _buildDivider(),
                        _buildSettingTile(
                          'Terms of Service',
                          'assets/svg/new_svg/license.svg',
                          onTap: viewModel.showTermsOfService,
                          metrics: metrics,
                          context: context,
                        ),
                        _buildDivider(),
                        _buildSettingTile(
                          'Privacy Policy',
                          'assets/svg/new_svg/privacy.svg',
                          onTap: viewModel.showPrivacyPolicy,
                          metrics: metrics,
                          context: context,
                        ),
                        _buildDivider(),
                        _buildSettingTile(
                          'About',
                          'assets/svg/new_svg/about.svg',
                          subtitle: 'Version ${viewModel.appVersion.value}',
                          onTap: () => viewModel.showAbout(context),
                          metrics: metrics,
                          context: context,
                        ),
                      ], metrics),

                      SizedBox(height: metrics.sectionSpacing),

                      // Data Management Section
                      _buildSection('Data Management', [
                        _buildSettingTile(
                          'Export Data to PDF',
                          'assets/svg/new_svg/pdf.svg',
                          onTap: () => viewModel.showExportDataDialog(context),
                          metrics: metrics,
                          context: context,
                        ),
                        _buildDivider(),
                        _buildSettingTile(
                          'Clear Cache',
                          'assets/svg/new_svg/cache.svg',
                          onTap: () => viewModel.showClearCacheDialog(context),
                          metrics: metrics,
                          context: context,
                        ),
                        _buildDivider(),
                        _buildSettingTile(
                          'Clear All Data',
                          'assets/svg/new_svg/data.svg',
                          onTap: () => viewModel.showClearDataDialog(context),
                          metrics: metrics,
                          context: context,
                          isDestructive: true,
                        ),
                        _buildDivider(),
                        _buildSettingTile(
                          'Delete Account',
                          'assets/svg/new_svg/delete_user.svg',
                          onTap: () => viewModel.showDeleteAccountDialog(context),
                          metrics: metrics,
                          context: context,
                          isDestructive: true,
                        ),
                      ], metrics),

                      SizedBox(height: metrics.sectionSpacing),

                      // Logout Button
                      Container(
                        margin: EdgeInsets.only(bottom: metrics.sectionSpacing),
                        child: Obx(
                          () => ElevatedButton(
                            onPressed: viewModel.isLoading.value
                                ? null
                                : () => viewModel.showLogoutDialog(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryRed,
                              foregroundColor: AppColors.white,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(
                                vertical: context.responsiveSpacing(16),
                                horizontal: metrics.cardPadding,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                              disabledBackgroundColor: AppColors.primaryRed
                                  .withOpacity(0.6),
                            ),
                            child: viewModel.isLoading.value
                                ? SizedBox(
                              height: 20,
                              width: 20,
                              child: LoadingAnimationWidget.horizontalRotatingDots(
                                color: AppColors.white,
                                size: 20,
                              ),
                            )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/svg/new_svg/logout.svg',
                                        width: 20,
                                        height: 20,
                                        colorFilter: const ColorFilter.mode(
                                          AppColors.white,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                      SizedBox(
                                        width: context.responsiveSpacing(8),
                                      ),
                                      Text(
                                        'Logout',
                                        style: GoogleFonts.inter(
                                          fontSize: context.responsiveFont(16),
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),

                      SizedBox(height: metrics.sectionSpacing * 2),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    String title,
    List<Widget> children,
    HomeLayoutMetrics metrics,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(metrics.cardPadding),
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textLightPink,
                letterSpacing: 0.5,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    String title,
    String iconPath, {
    String? subtitle,
    required VoidCallback? onTap,
    required HomeLayoutMetrics metrics,
    required BuildContext context,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: SvgPicture.asset(
        iconPath,
        width: 24,
        height: 24,
        colorFilter: ColorFilter.mode(
          isDestructive ? AppColors.primaryRed : AppColors.primaryDark,
          BlendMode.srcIn,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: context.responsiveFont(16),
          fontWeight: FontWeight.w500,
          color: isDestructive ? AppColors.primaryRed : AppColors.primaryDark,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: context.responsiveFont(12),
                color: AppColors.textLightPink,
              ),
            )
          : null,
      trailing: Icon(Icons.chevron_right, color: AppColors.textLightPink),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(
        horizontal: metrics.cardPadding,
        vertical: 4,
      ),
    );
  }

  Widget _buildToggleTile(
    String title,
    String key,
    String iconPath,
    ProfileViewModel viewModel,
    HomeLayoutMetrics metrics,
    BuildContext context,
  ) {
    return Obx(() {
      // Disable Plan Reminders if Push Notifications is disabled
      final bool isPlanReminder = key == 'planReminder';
      final bool notificationsEnabled =
          viewModel.settings['notifications'] ?? true;
      final bool shouldEnable = isPlanReminder ? notificationsEnabled : true;
      final bool currentValue = viewModel.settings[key] ?? false;

      return ListTile(
        leading: SvgPicture.asset(
          iconPath,
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(
            shouldEnable ? AppColors.primaryDark : AppColors.textLightPink,
            BlendMode.srcIn,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: context.responsiveFont(16),
            fontWeight: FontWeight.w500,
            color: shouldEnable
                ? AppColors.primaryDark
                : AppColors.textLightPink,
          ),
        ),
        subtitle: isPlanReminder && !notificationsEnabled
            ? Text(
                'Enable Push Notifications first',
                style: GoogleFonts.inter(
                  fontSize: context.responsiveFont(12),
                  color: AppColors.textLightPink,
                ),
              )
            : null,
        trailing: Switch(
          value: currentValue,
          onChanged: shouldEnable
              ? (value) => viewModel.updateSetting(key, value)
              : null,
          activeThumbColor: AppColors.primaryRed,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: metrics.cardPadding,
          vertical: 4,
        ),
      );
    });
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 40,
      endIndent: 40,
      color: AppColors.textLightPink.withOpacity(0.2),
    );
  }

  Widget _buildProfileImage(String? profilePictureUrl) {
    if (profilePictureUrl != null && profilePictureUrl.isNotEmpty) {
      // Check if it's a local file path (starts with "file://")
      if (profilePictureUrl.startsWith('file://')) {
        // Remove "file://" prefix to get the actual file path
        final String filePath = profilePictureUrl.substring(7);
        // Use ValueKey to force rebuild when path changes
        return Image.file(
          File(filePath),
          key: ValueKey(filePath), // Force rebuild when path changes
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset('assets/images/profile.jpg', fit: BoxFit.cover);
          },
        );
      } else {
        // It's a network URL (Firebase)
        return Image.network(
          profilePictureUrl,
          key: ValueKey(profilePictureUrl), // Force rebuild when URL changes
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset('assets/images/profile.jpg', fit: BoxFit.cover);
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
                child: LoadingAnimationWidget.horizontalRotatingDots(
                  color: AppColors.primaryRed,
                  size: 20, // jitna chaho set kar lo
                ),
            );
          },
        );
      }
    }
    return Image.asset('assets/images/profile.jpg', fit: BoxFit.cover);
  }
}
