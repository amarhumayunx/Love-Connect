import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/core/utils/media_query_extensions.dart';
import 'package:love_connect/core/utils/snackbar_helper.dart';
import 'package:love_connect/screens/home/view/widgets/home_layout_metrics.dart';
import 'package:love_connect/screens/home/view_model/home_view_model.dart';
import 'package:love_connect/screens/settings/view_model/settings_view_model.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late final SettingsViewModel viewModel;
  HomeViewModel? homeViewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Get.put(SettingsViewModel());
    try {
      homeViewModel = Get.find<HomeViewModel>();
    } catch (e) {
      homeViewModel = null;
    }
  }

  @override
  void dispose() {
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
                  homeViewModel != null
                      ? Obx(
                          () => homeViewModel!.isFromNavbar('profile')
                              ? const SizedBox.shrink()
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
                padding: EdgeInsets.symmetric(horizontal: metrics.cardPadding),
                child: Obx(
                  () => Column(
                    children: [
                      // Account Section
                      _buildSection('Account', [
                        _buildSettingTile(
                          'Edit Profile',
                          Icons.person_outline,
                          onTap: () {
                            // Navigate to edit profile
                            SnackbarHelper.showSafe(
                              title: 'Edit Profile',
                              message: 'Profile editing coming soon',
                            );
                          },
                          metrics: metrics,
                          context: context,
                        ),
                        _buildDivider(),
                        _buildSettingTile(
                          'Change Email',
                          Icons.email_outlined,
                          onTap: () {
                            SnackbarHelper.showSafe(
                              title: 'Change Email',
                              message: 'Email change coming soon',
                            );
                          },
                          metrics: metrics,
                          context: context,
                        ),
                        _buildDivider(),
                        _buildSettingTile(
                          'Change Password',
                          Icons.lock_outline,
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
                          Icons.notifications_outlined,
                          viewModel,
                          metrics,
                          context,
                        ),
                        _buildDivider(),
                        _buildToggleTile(
                          'Plan Reminders',
                          'planReminder',
                          Icons.calendar_today_outlined,
                          viewModel,
                          metrics,
                          context,
                        ),
                        _buildDivider(),
                        _buildToggleTile(
                          'Email Notifications',
                          'emailNotifications',
                          Icons.email_outlined,
                          viewModel,
                          metrics,
                          context,
                        ),
                        _buildDivider(),
                        _buildSettingTile(
                          'Test Notification',
                          Icons.notifications_active_outlined,
                          subtitle: 'Send a test notification now',
                          onTap: viewModel.sendTestNotification,
                          metrics: metrics,
                          context: context,
                        ),
                      ], metrics),

                      SizedBox(height: metrics.sectionSpacing),

                      // Privacy & Security Section
                      _buildSection('Privacy & Security', [
                        _buildToggleTile(
                          'Private Journal',
                          'privateJournal',
                          Icons.lock_outline,
                          viewModel,
                          metrics,
                          context,
                        ),
                        _buildDivider(),
                        _buildToggleTile(
                          'Hide Location',
                          'hideLocation',
                          Icons.location_off_outlined,
                          viewModel,
                          metrics,
                          context,
                        ),
                        _buildDivider(),
                        _buildToggleTile(
                          'App Lock',
                          'appLock',
                          Icons.fingerprint_outlined,
                          viewModel,
                          metrics,
                          context,
                        ),
                      ], metrics),

                      SizedBox(height: metrics.sectionSpacing),

                      // App Preferences Section
                      _buildSection('App Preferences', [
                        _buildToggleTile(
                          'Romantic Theme',
                          'romanticTheme',
                          Icons.favorite_outline,
                          viewModel,
                          metrics,
                          context,
                        ),
                        _buildDivider(),
                        _buildSettingTile(
                          'Language',
                          Icons.language_outlined,
                          subtitle: 'English',
                          onTap: () {
                            SnackbarHelper.showSafe(
                              title: 'Language',
                              message: 'Language selection coming soon',
                            );
                          },
                          metrics: metrics,
                          context: context,
                        ),
                      ], metrics),

                      SizedBox(height: metrics.sectionSpacing),

                      // Support & About Section
                      _buildSection('Support & About', [
                        _buildSettingTile(
                          'Help & Support',
                          Icons.help_outline,
                          onTap: viewModel.contactSupport,
                          metrics: metrics,
                          context: context,
                        ),
                        _buildDivider(),
                        _buildSettingTile(
                          'Rate App',
                          Icons.star_outline,
                          onTap: viewModel.rateApp,
                          metrics: metrics,
                          context: context,
                        ),
                        _buildDivider(),
                        _buildSettingTile(
                          'Share App',
                          Icons.share_outlined,
                          onTap: viewModel.shareApp,
                          metrics: metrics,
                          context: context,
                        ),
                        _buildDivider(),
                        _buildSettingTile(
                          'Terms of Service',
                          Icons.description_outlined,
                          onTap: viewModel.showTermsOfService,
                          metrics: metrics,
                          context: context,
                        ),
                        _buildDivider(),
                        _buildSettingTile(
                          'Privacy Policy',
                          Icons.privacy_tip_outlined,
                          onTap: viewModel.showPrivacyPolicy,
                          metrics: metrics,
                          context: context,
                        ),
                        _buildDivider(),
                        _buildSettingTile(
                          'About',
                          Icons.info_outline,
                          subtitle: 'Version ${viewModel.appVersion.value}',
                          onTap: viewModel.showAbout,
                          metrics: metrics,
                          context: context,
                        ),
                      ], metrics),

                      SizedBox(height: metrics.sectionSpacing),

                      // Data Management Section
                      _buildSection('Data Management', [
                        _buildSettingTile(
                          'Clear Cache',
                          Icons.delete_outline,
                          onTap: viewModel.clearCache,
                          metrics: metrics,
                          context: context,
                        ),
                        _buildDivider(),
                        _buildSettingTile(
                          'Clear All Data',
                          Icons.delete_forever_outlined,
                          onTap: viewModel.showClearDataDialog,
                          metrics: metrics,
                          context: context,
                          isDestructive: true,
                        ),
                      ], metrics),

                      SizedBox(height: metrics.sectionSpacing),

                      // Logout Button
                      Container(
                        padding: EdgeInsets.all(metrics.cardPadding),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _buildSettingTile(
                          'Logout',
                          Icons.logout,
                          onTap: viewModel.showLogoutDialog,
                          metrics: metrics,
                          context: context,
                          isDestructive: true,
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
    IconData icon,
    SettingsViewModel viewModel,
    HomeLayoutMetrics metrics,
    BuildContext context, {
    bool? isEnabled,
  }) {
    return Obx(() {
      // Disable Plan Reminders if Push Notifications is disabled
      final bool isPlanReminder = key == 'planReminder';
      final bool notificationsEnabled =
          viewModel.settings['notifications'] ?? true;
      final bool shouldEnable =
          isEnabled ?? (isPlanReminder ? notificationsEnabled : true);
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
      indent: 60,
      color: AppColors.textLightPink.withOpacity(0.2),
    );
  }
}
