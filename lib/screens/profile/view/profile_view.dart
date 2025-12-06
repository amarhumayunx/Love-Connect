import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/core/utils/media_query_extensions.dart';
import 'package:love_connect/screens/home/view/widgets/home_layout_metrics.dart';
import 'package:love_connect/screens/home/view_model/home_view_model.dart';
import 'package:love_connect/screens/profile/view_model/profile_view_model.dart';
import 'package:love_connect/screens/settings/view_model/settings_view_model.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late final ProfileViewModel viewModel;
  late final SettingsViewModel settingsViewModel;
  HomeViewModel? homeViewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Get.put(ProfileViewModel());
    settingsViewModel = Get.put(SettingsViewModel());
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
    Get.delete<SettingsViewModel>();
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
                  // Show back arrow only if navigated from quick actions
                  homeViewModel != null
                      ? Obx(
                          () => homeViewModel!.isFromNavbar('profile')
                              ? const SizedBox.shrink() // Hide back arrow if from navbar
                              : IconButton(
                                  icon: Icon(
                                    Icons.arrow_back_ios,
                                    color: AppColors.primaryDark,
                                    size: metrics.iconSize,
                                  ),
                                  onPressed: () => Get.back(),
                                ),
                        )
                      : IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: AppColors.primaryDark,
                            size: metrics.iconSize,
                          ),
                          onPressed: () => Get.back(),
                        ),
                  Text(
                    viewModel.model.title,
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
                ),
                child: Obx(
                  () => Column(
                    children: [
                      // Profile Picture and Info
                      Container(
                        margin: EdgeInsets.only(bottom: metrics.sectionSpacing),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey[200],
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      'assets/images/profile.jpg',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: metrics.sectionSpacing * 0.5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  viewModel.userProfile.value.name,
                                  style: GoogleFonts.inter(
                                    fontSize: context.responsiveFont(18),
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                                SizedBox(width: 8),
                                IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: AppColors.primaryRed,
                                    size: 20,
                                  ),
                                  onPressed: viewModel.showEditProfileModal,
                                ),
                              ],
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

                      // Account Section
                      _buildSection(
                        'Account',
                        [
                          _buildSettingTile(
                            'Edit Profile',
                            Icons.person_outline,
                            onTap: () {
                              viewModel.showEditProfileModal();
                            },
                            metrics: metrics,
                            context: context,
                          ),
                          _buildDivider(),
                          _buildSettingTile(
                            'Change Password',
                            Icons.lock_outline,
                            onTap: () {
                              settingsViewModel.navigateToChangePassword();
                            },
                            metrics: metrics,
                            context: context,
                          ),
                        ],
                        metrics,
                      ),

                      SizedBox(height: metrics.sectionSpacing),

                      // Notifications Section
                      _buildSection(
                        'Notifications',
                        [
                          _buildToggleTile(
                            'Push Notifications',
                            'notifications',
                            Icons.notifications_outlined,
                            settingsViewModel,
                            metrics,
                            context,
                          ),
                          _buildDivider(),
                          _buildToggleTile(
                            'Plan Reminders',
                            'planReminder',
                            Icons.calendar_today_outlined,
                            settingsViewModel,
                            metrics,
                            context,
                          ),
                        ],
                        metrics,
                      ),

                      SizedBox(height: metrics.sectionSpacing),

                      // Support & About Section
                      _buildSection(
                        'Support & About',
                        [
                          _buildSettingTile(
                            'Help & Support',
                            Icons.help_outline,
                            onTap: settingsViewModel.contactSupport,
                            metrics: metrics,
                            context: context,
                          ),
                          _buildDivider(),
                          _buildSettingTile(
                            'Rate App',
                            Icons.star_outline,
                            onTap: settingsViewModel.rateApp,
                            metrics: metrics,
                            context: context,
                          ),
                          _buildDivider(),
                          _buildSettingTile(
                            'Share App',
                            Icons.share_outlined,
                            onTap: settingsViewModel.shareApp,
                            metrics: metrics,
                            context: context,
                          ),
                          _buildDivider(),
                          _buildSettingTile(
                            'Terms of Service',
                            Icons.description_outlined,
                            onTap: settingsViewModel.showTermsOfService,
                            metrics: metrics,
                            context: context,
                          ),
                          _buildDivider(),
                          _buildSettingTile(
                            'Privacy Policy',
                            Icons.privacy_tip_outlined,
                            onTap: settingsViewModel.showPrivacyPolicy,
                            metrics: metrics,
                            context: context,
                          ),
                          _buildDivider(),
                          _buildSettingTile(
                            'About',
                            Icons.info_outline,
                            subtitle: 'Version ${settingsViewModel.appVersion.value}',
                            onTap: () => settingsViewModel.showAbout(context),
                            metrics: metrics,
                            context: context,
                          ),
                        ],
                        metrics,
                      ),

                      SizedBox(height: metrics.sectionSpacing),

                      // Data Management Section
                      _buildSection(
                        'Data Management',
                        [
                          _buildSettingTile(
                            'Clear Cache',
                            Icons.delete_outline,
                            onTap: () => settingsViewModel.showClearCacheDialog(context),
                            metrics: metrics,
                            context: context,
                          ),
                          _buildDivider(),
                          _buildSettingTile(
                            'Clear All Data',
                            Icons.delete_forever_outlined,
                            onTap: () => settingsViewModel.showClearDataDialog(context),
                            metrics: metrics,
                            context: context,
                            isDestructive: true,
                          ),
                        ],
                        metrics,
                      ),

                      SizedBox(height: metrics.sectionSpacing),

                      // Logout Button
                      Container(
                        margin: EdgeInsets.only(bottom: metrics.sectionSpacing),
                        child: Obx(
                          () => ElevatedButton(
                            onPressed: settingsViewModel.isLoading.value
                                ? null
                                : () => settingsViewModel.showLogoutDialog(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryRed,
                              foregroundColor: AppColors.white,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(
                                vertical: context.responsiveSpacing(16),
                                horizontal: metrics.cardPadding,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              disabledBackgroundColor:
                                  AppColors.primaryRed.withOpacity(0.6),
                            ),
                            child: settingsViewModel.isLoading.value
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.white,
                                      ),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.logout_rounded,
                                        size: 20,
                                        color: AppColors.white,
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

  Widget _buildSection(String title, List<Widget> children, HomeLayoutMetrics metrics) {
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
    IconData icon, {
    String? subtitle,
    required VoidCallback? onTap,
    required HomeLayoutMetrics metrics,
    required BuildContext context,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppColors.primaryRed : AppColors.primaryDark,
        size: 24,
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
      trailing: Icon(
        Icons.chevron_right,
        color: AppColors.textLightPink,
      ),
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
    IconData icon,
    SettingsViewModel viewModel,
    HomeLayoutMetrics metrics,
    BuildContext context,
  ) {
    return Obx(
      () {
        // Disable Plan Reminders if Push Notifications is disabled
        final bool isPlanReminder = key == 'planReminder';
        final bool notificationsEnabled = viewModel.settings['notifications'] ?? true;
        final bool shouldEnable = isPlanReminder ? notificationsEnabled : true;
        final bool currentValue = viewModel.settings[key] ?? false;
        
        return ListTile(
          leading: Icon(
            icon,
            color: shouldEnable ? AppColors.primaryDark : AppColors.textLightPink,
            size: 24,
          ),
          title: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: context.responsiveFont(16),
              fontWeight: FontWeight.w500,
              color: shouldEnable ? AppColors.primaryDark : AppColors.textLightPink,
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
      },
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 60,
      color: AppColors.textLightPink.withOpacity(0.2),
    );
  }
}

