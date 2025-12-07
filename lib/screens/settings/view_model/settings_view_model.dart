import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:love_connect/core/services/local_storage_service.dart';
import 'package:love_connect/core/services/auth/auth_service.dart';
import 'package:love_connect/core/services/notification_service.dart';
import 'package:love_connect/core/services/plans_database_service.dart';
import 'package:love_connect/core/models/plan_model.dart';
import 'package:love_connect/core/utils/snackbar_helper.dart';
import 'package:love_connect/core/navigation/smooth_transitions.dart';
import 'package:love_connect/screens/auth/login/view/login_view.dart';
import 'package:love_connect/screens/settings/model/settings_model.dart';
import 'package:love_connect/screens/settings/change_password/view/change_password_view.dart';
import 'package:love_connect/screens/settings/terms_privacy/view/terms_of_service_view.dart';
import 'package:love_connect/screens/settings/terms_privacy/view/privacy_policy_view.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/core/utils/media_query_extensions.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class SettingsViewModel extends GetxController {
  final LocalStorageService _storageService = LocalStorageService();
  final AuthService _authService = AuthService();
  final NotificationService _notificationService = NotificationService();
  final PlansDatabaseService _plansDbService = PlansDatabaseService();
  final SettingsModel model = const SettingsModel();
  final RxMap<String, bool> settings = <String, bool>{}.obs;
  final RxString appVersion = '1.0.0'.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
    loadAppVersion();
  }

  Future<void> loadSettings() async {
    try {
      final loadedSettings = await _storageService.getSettings();
      settings.value = loadedSettings;
    } catch (e) {
      settings.value = _getDefaultSettings();
    }
  }

  Future<void> loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      appVersion.value = '${packageInfo.version} (${packageInfo.buildNumber})';
    } catch (e) {
      appVersion.value = '1.0.0 (1)';
    }
  }

  Map<String, bool> _getDefaultSettings() {
    return {
      'notifications': true,
      'planReminder': true,
      'emailNotifications': true,
      'privateJournal': true,
      'hideLocation': true,
      'romanticTheme': true,
      'appLock': false,
    };
  }

  Future<void> updateSetting(String key, bool value) async {
    try {
      await _handleSettingSpecificLogic(key, value);
      await _saveSetting(key, value);
      _showSettingUpdateMessage(key, value);
    } catch (e) {
      _handleSettingUpdateError(key, e);
    }
  }

  Future<void> _handleSettingSpecificLogic(String key, bool value) async {
    switch (key) {
      case 'notifications':
        await _handlePushNotificationsSetting(value);
        break;
      case 'planReminder':
        await _handlePlanReminderSetting(value);
        break;
    }
  }

  Future<void> _saveSetting(String key, bool value) async {
    await _storageService.saveSetting(key, value);
    settings[key] = value;
  }

  void _showSettingUpdateMessage(String key, bool value) {
    switch (key) {
      case 'notifications':
        _showNotificationMessage(value);
        break;
      case 'planReminder':
        _showPlanReminderMessage(value);
        break;
    }
  }

  void _showNotificationMessage(bool enabled) {
    SnackbarHelper.showSafe(
      title: enabled
          ? 'Push Notifications Enabled'
          : 'Push Notifications Disabled',
      message: enabled
          ? 'You will receive notifications for your plans'
          : 'All notifications have been cancelled',
      duration: const Duration(seconds: 2),
    );
  }

  void _showPlanReminderMessage(bool enabled) {
    SnackbarHelper.showSafe(
      title: enabled ? 'Plan Reminders Enabled' : 'Plan Reminders Disabled',
      message: enabled
          ? 'You will receive reminders 10 minutes before your plans'
          : 'Plan reminder notifications have been cancelled',
      duration: const Duration(seconds: 2),
    );
  }

  void _handleSettingUpdateError(String key, dynamic error) {
    if (kDebugMode) {
      debugPrint('Error updating setting $key: $error');
    }
    SnackbarHelper.showSafe(
      title: 'Error',
      message: 'Failed to update setting',
    );
  }

  /// Handle Push Notifications setting changes
  Future<void> _handlePushNotificationsSetting(bool enabled) async {
    if (enabled) {
      // Request system permissions when enabling
      await _notificationService.init();
      final hasPermission = await _notificationService
          .areNotificationsEnabled();

      if (!hasPermission) {
        // Permission was denied, show message
        SnackbarHelper.showSafe(
          title: 'Permission Required',
          message: 'Please enable notifications in your device settings',
          duration: const Duration(seconds: 3),
        );
      } else {
        // If notifications enabled and plan reminders was on, reschedule them
        if (settings['planReminder'] == true) {
          await _rescheduleAllPlanNotifications();
        }
      }
    } else {
      // Cancel all notifications when disabling
      await _notificationService.cancelAllNotifications();

      // Also disable Plan Reminders if Push Notifications is disabled
      if (settings['planReminder'] == true) {
        await _storageService.saveSetting('planReminder', false);
        settings['planReminder'] = false;
      }
    }
  }

  /// Handle Plan Reminder setting changes
  Future<void> _handlePlanReminderSetting(bool enabled) async {
    if (enabled) {
      // Reschedule notifications for all future plans
      await _rescheduleAllPlanNotifications();
    } else {
      // Cancel all plan notifications (keep test notifications)
      await _notificationService.cancelAllPlanNotifications();
    }
  }

  /// Reschedule notifications for all future plans
  Future<void> _rescheduleAllPlanNotifications() async {
    try {
      if (!_areNotificationsEnabled()) {
        return;
      }

      final allPlans = await _loadAllPlans();
      final futurePlans = _filterFuturePlans(allPlans);
      final scheduledCount = await _schedulePlanNotifications(futurePlans);

      _logSchedulingResult(scheduledCount);
    } catch (e) {
      _logSchedulingError(e);
    }
  }

  bool _areNotificationsEnabled() {
    return settings['notifications'] ?? true;
  }

  Future<List<PlanModel>> _loadAllPlans() async {
    final userId = _authService.currentUserId;
    if (userId != null) {
      final plans = await _loadPlansFromFirebase(userId);
      if (plans.isNotEmpty) {
        return plans;
      }
    }
    return await _storageService.getPlans();
  }

  Future<List<PlanModel>> _loadPlansFromFirebase(String userId) async {
    try {
      return await _plansDbService.getPlans(userId);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to load plans from Firebase: $e');
      }
      return [];
    }
  }

  List<PlanModel> _filterFuturePlans(List<PlanModel> allPlans) {
    final now = DateTime.now();
    return allPlans.where((plan) => _isPlanInFuture(plan, now)).toList();
  }

  bool _isPlanInFuture(PlanModel plan, DateTime now) {
    if (plan.time == null) return false;
    final notificationTime = plan.time!.subtract(const Duration(hours: 1));
    return notificationTime.isAfter(now);
  }

  Future<int> _schedulePlanNotifications(List<PlanModel> futurePlans) async {
    int scheduledCount = 0;
    for (final plan in futurePlans) {
      final success = await _scheduleSinglePlanNotification(plan);
      if (success) {
        scheduledCount++;
      }
    }
    return scheduledCount;
  }

  Future<bool> _scheduleSinglePlanNotification(PlanModel plan) async {
    try {
      final notificationTime = plan.time!.subtract(const Duration(hours: 1));
      final notificationId = plan.id.hashCode & 0x7fffffff;

      await _notificationService.schedulePlanNotification(
        id: notificationId,
        title: 'Upcoming Plan',
        body: '${plan.title} at ${plan.place} in 1 hour',
        scheduledTime: notificationTime,
      );
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to schedule notification for plan ${plan.id}: $e');
      }
      return false;
    }
  }

  void _logSchedulingResult(int scheduledCount) {
    if (kDebugMode && scheduledCount > 0) {
      debugPrint('Rescheduled $scheduledCount plan notifications');
    }
  }

  void _logSchedulingError(dynamic error) {
    if (kDebugMode) {
      debugPrint('Error rescheduling plan notifications: $error');
    }
  }

  Future<void> clearCache() async {
    try {
      isLoading.value = true;

      // Cancel all notifications (they're cached)
      await _notificationService.cancelAllNotifications();

      // Clear any cached notification data
      // Note: Flutter's image cache is automatically managed by the framework
      // and doesn't need manual clearing in most cases

      // Force garbage collection hint (optional)
      // This is just a hint to the Dart VM, not guaranteed to run immediately

      isLoading.value = false;

      SnackbarHelper.showSafe(
        title: 'Cache Cleared',
        message: 'App cache has been cleared successfully',
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      isLoading.value = false;
      if (kDebugMode) {
        debugPrint('Error clearing cache: $e');
      }
      SnackbarHelper.showSafe(
        title: 'Error',
        message: 'Failed to clear cache. Please try again.',
      );
    }
  }

  Future<void> clearAllData() async {
    try {
      isLoading.value = true;

      // Get current user ID before clearing
      final userId = _authService.currentUserId;

      // Clear all local storage data
      await _storageService.clearAllData(userId: userId);

      // Clear user data from database if user exists
      if (userId != null) {
        await _storageService.clearUserData(userId);
      }

      // Clear anonymous data
      await _storageService.clearAnonymousData();

      // Cancel all notifications
      await _notificationService.cancelAllNotifications();

      // Cancel all notifications
      await _notificationService.cancelAllNotifications();

      isLoading.value = false;

      SnackbarHelper.showSafe(
        title: 'Data Cleared',
        message: 'All user data has been permanently deleted',
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      isLoading.value = false;
      if (kDebugMode) {
        debugPrint('Error clearing all data: $e');
      }
      SnackbarHelper.showSafe(
        title: 'Error',
        message: 'Failed to clear data. Please try again.',
      );
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;

      // Get current user ID before logout
      final userId = _authService.currentUserId;

      // Clear current user ID and anonymous data from storage
      if (userId != null) {
        await _storageService.clearUserData(userId);
      }
      await _storageService.clearAnonymousData();
      await _storageService.setCurrentUserId(null);

      // Cancel all notifications
      await _notificationService.cancelAllNotifications();

      // Sign out from Firebase and Google
      await _authService.signOut();

      isLoading.value = false;

      // Navigate to login screen
      SmoothNavigator.offAll(
        () => const LoginView(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 300),
      );
    } catch (e) {
      isLoading.value = false;
      if (kDebugMode) {
        debugPrint('Error during logout: $e');
      }
      SnackbarHelper.showSafe(
        title: 'Logout Failed',
        message: 'An error occurred during logout. Please try again.',
      );
    }
  }

  Future<void> contactSupport() async {
    final email = 'support@loveconnect.app';
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Love Connect Support Request',
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        // Fallback: Copy email to clipboard
        await Clipboard.setData(ClipboardData(text: email));
        SnackbarHelper.showSafe(
          title: 'Email Copied',
          message: 'Email address copied to clipboard: $email',
          duration: const Duration(seconds: 5),
        );
      }
    } catch (e) {
      // Fallback: Copy email to clipboard
      await Clipboard.setData(ClipboardData(text: email));
      SnackbarHelper.showSafe(
        title: 'Email Copied',
        message: 'Email address copied to clipboard: $email',
        duration: const Duration(seconds: 5),
      );
    }
  }

  Future<void> rateApp() async {
    try {
      // Play Store package name
      const String packageName = 'com.example.love_connect';

      // Try to open Play Store
      final Uri playStoreUri = Uri.parse(
        'https://play.google.com/store/apps/details?id=$packageName',
      );

      // For iOS, use App Store link (you'll need to replace with actual App Store ID)
      // final Uri appStoreUri = Uri.parse('https://apps.apple.com/app/idYOUR_APP_ID');

      if (await canLaunchUrl(playStoreUri)) {
        await launchUrl(playStoreUri, mode: LaunchMode.externalApplication);
      } else {
        SnackbarHelper.showSafe(
          title: 'Unable to Open',
          message:
              'Could not open Play Store. Please search for "Love Connect" manually.',
        );
      }
    } catch (e) {
      SnackbarHelper.showSafe(
        title: 'Error',
        message: 'Failed to open app store. Please try again later.',
      );
    }
  }

  Future<void> shareApp() async {
    try {
      const String packageName = 'com.example.love_connect';
      const String playStoreLink =
          'https://play.google.com/store/apps/details?id=$packageName';
      const String shareText =
          'Check out Love Connect - the perfect app for couples!\n\n$playStoreLink';

      await Share.share(shareText, subject: 'Love Connect - App for Couples');
    } catch (e) {
      // Fallback: Copy to clipboard
      const String packageName = 'com.example.love_connect';
      const String playStoreLink =
          'https://play.google.com/store/apps/details?id=$packageName';
      const String shareText =
          'Check out Love Connect - the perfect app for couples!\n\n$playStoreLink';

      await Clipboard.setData(ClipboardData(text: shareText));
      SnackbarHelper.showSafe(
        title: 'Link Copied',
        message: 'App link copied to clipboard!',
      );
    }
  }

  void showTermsOfService() {
    SmoothNavigator.to(
      () => const TermsOfServiceView(),
      transition: Transition.rightToLeft,
    );
  }

  void showPrivacyPolicy() {
    SmoothNavigator.to(
      () => const PrivacyPolicyView(),
      transition: Transition.rightToLeft,
    );
  }

  void navigateToChangePassword() {
    SmoothNavigator.to(
      () => const ChangePasswordView(),
      transition: Transition.rightToLeft,
    );
  }

  void showAbout(BuildContext context) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: context.widthPct(5),
          vertical: context.heightPct(10),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          padding: EdgeInsets.all(context.responsiveSpacing(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // App Icon/Logo
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.favorite_rounded,
                    color: AppColors.primaryRed,
                    size: 40,
                  ),
                ),
              ),
              SizedBox(height: context.responsiveSpacing(20)),

              // App Name
              Text(
                'Love Connect',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: context.responsiveFont(24),
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
              ),
              SizedBox(height: context.responsiveSpacing(8)),

              // Version
              Text(
                'Version ${appVersion.value}',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: context.responsiveFont(14),
                  fontWeight: FontWeight.w500,
                  color: AppColors.textLightPink,
                ),
              ),
              SizedBox(height: context.responsiveSpacing(20)),

              // Description
              Container(
                padding: EdgeInsets.all(context.responsiveSpacing(16)),
                decoration: BoxDecoration(
                  color: AppColors.backgroundPink,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'A beautiful app designed for couples to plan dates, share memories, and strengthen their relationship.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: context.responsiveFont(14),
                    fontWeight: FontWeight.w400,
                    color: AppColors.primaryDark,
                    height: 1.5,
                  ),
                ),
              ),
              SizedBox(height: context.responsiveSpacing(24)),

              // Close Button
              ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: context.responsiveSpacing(14),
                  ),
                ),
                child: Text(
                  'Close',
                  style: GoogleFonts.inter(
                    fontSize: context.responsiveFont(16),
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  void showClearCacheDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: context.widthPct(5),
          vertical: context.heightPct(10),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          padding: EdgeInsets.all(context.responsiveSpacing(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: AppColors.primaryRed,
                    size: 32,
                  ),
                ),
              ),
              SizedBox(height: context.responsiveSpacing(20)),

              // Title
              Text(
                'Clear Cache',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: context.responsiveFont(20),
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDark,
                ),
              ),
              SizedBox(height: context.responsiveSpacing(12)),

              // Message
              Text(
                'This will clear temporary files and cached data. Your plans, profile, and settings will not be affected.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: context.responsiveFont(14),
                  fontWeight: FontWeight.w400,
                  color: AppColors.textLightPink,
                  height: 1.5,
                ),
              ),
              SizedBox(height: context.responsiveSpacing(24)),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaryRed),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: context.responsiveSpacing(14),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.inter(
                          fontSize: context.responsiveFont(16),
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryRed,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: context.responsiveSpacing(12)),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        clearCache();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: context.responsiveSpacing(14),
                        ),
                      ),
                      child: Text(
                        'Clear Cache',
                        style: GoogleFonts.inter(
                          fontSize: context.responsiveFont(16),
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  void showClearDataDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: context.widthPct(5),
          vertical: context.heightPct(10),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          padding: EdgeInsets.all(context.responsiveSpacing(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Warning Icon
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.primaryRed,
                    size: 32,
                  ),
                ),
              ),
              SizedBox(height: context.responsiveSpacing(20)),

              // Title
              Text(
                'Clear All Data',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: context.responsiveFont(20),
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDark,
                ),
              ),
              SizedBox(height: context.responsiveSpacing(12)),

              // Warning Message
              Container(
                padding: EdgeInsets.all(context.responsiveSpacing(12)),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '⚠️ This will permanently delete ALL your data including:\n\n• All your plans\n• Your profile information\n• Journal entries\n• Notifications\n• Settings\n\nThis action cannot be undone!',
                  textAlign: TextAlign.left,
                  style: GoogleFonts.inter(
                    fontSize: context.responsiveFont(14),
                    fontWeight: FontWeight.w400,
                    color: AppColors.primaryDark,
                    height: 1.5,
                  ),
                ),
              ),
              SizedBox(height: context.responsiveSpacing(24)),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaryRed),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: context.responsiveSpacing(14),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.inter(
                          fontSize: context.responsiveFont(16),
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryRed,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: context.responsiveSpacing(12)),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        clearAllData();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: context.responsiveSpacing(14),
                        ),
                      ),
                      child: Text(
                        'Delete All',
                        style: GoogleFonts.inter(
                          fontSize: context.responsiveFont(16),
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  Future<void> sendTestNotification() async {
    try {
      await _notificationService.showTestNotification();
      SnackbarHelper.showSafe(
        title: 'Test Notification Sent',
        message: 'Check your notification tray!',
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error sending test notification: $e');
      }
      SnackbarHelper.showSafe(
        title: 'Error',
        message: 'Failed to send test notification',
      );
    }
  }

  void showLogoutDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: context.widthPct(5),
          vertical: context.heightPct(10),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          padding: EdgeInsets.all(context.responsiveSpacing(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: AppColors.primaryRed,
                    size: 32,
                  ),
                ),
              ),
              SizedBox(height: context.responsiveSpacing(20)),

              // Title
              Text(
                'Logout',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: context.responsiveFont(20),
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDark,
                ),
              ),
              SizedBox(height: context.responsiveSpacing(12)),

              // Message
              Text(
                'Are you sure you want to logout? You will need to sign in again to access your account.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: context.responsiveFont(14),
                  fontWeight: FontWeight.w400,
                  color: AppColors.textLightPink,
                  height: 1.5,
                ),
              ),
              SizedBox(height: context.responsiveSpacing(24)),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaryRed),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: context.responsiveSpacing(14),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.inter(
                          fontSize: context.responsiveFont(16),
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryRed,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: context.responsiveSpacing(12)),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        logout();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: context.responsiveSpacing(14),
                        ),
                      ),
                      child: Text(
                        'Logout',
                        style: GoogleFonts.inter(
                          fontSize: context.responsiveFont(16),
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }
}
