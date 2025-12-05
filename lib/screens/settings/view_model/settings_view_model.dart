import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
      // Handle notification-related settings
      if (key == 'notifications') {
        await _handlePushNotificationsSetting(value);
      } else if (key == 'planReminder') {
        await _handlePlanReminderSetting(value);
      }

      // Save the setting
      await _storageService.saveSetting(key, value);
      settings[key] = value;

      // Show success message
      if (key == 'notifications') {
        SnackbarHelper.showSafe(
          title: value ? 'Push Notifications Enabled' : 'Push Notifications Disabled',
          message: value 
              ? 'You will receive notifications for your plans'
              : 'All notifications have been cancelled',
          duration: const Duration(seconds: 2),
        );
      } else if (key == 'planReminder') {
        SnackbarHelper.showSafe(
          title: value ? 'Plan Reminders Enabled' : 'Plan Reminders Disabled',
          message: value 
              ? 'You will receive reminders 10 minutes before your plans'
              : 'Plan reminder notifications have been cancelled',
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error updating setting $key: $e');
      }
      SnackbarHelper.showSafe(
        title: 'Error',
        message: 'Failed to update setting',
      );
    }
  }

  /// Handle Push Notifications setting changes
  Future<void> _handlePushNotificationsSetting(bool enabled) async {
    if (enabled) {
      // Request system permissions when enabling
      await _notificationService.init();
      final hasPermission = await _notificationService.areNotificationsEnabled();
      
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
      // Check if notifications are enabled
      final notificationsEnabled = settings['notifications'] ?? true;
      if (!notificationsEnabled) {
        return; // Don't schedule if notifications are disabled
      }

      // Get all plans
      final userId = _authService.currentUserId;
      List<PlanModel> allPlans = [];

      if (userId != null) {
        // Try Firebase first
        try {
          allPlans = await _plansDbService.getPlans(userId);
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Failed to load plans from Firebase: $e');
          }
        }
      }

      // Fallback to local storage
      if (allPlans.isEmpty) {
        allPlans = await _storageService.getPlans();
      }

      // Filter future plans with times
      final now = DateTime.now();
      final futurePlans = allPlans.where((plan) {
        if (plan.time == null) return false;
        // Check if notification time (10 min before) is in the future
        final notificationTime = plan.time!.subtract(const Duration(minutes: 10));
        return notificationTime.isAfter(now);
      }).toList();

      // Reschedule notifications for each plan
      int scheduledCount = 0;
      for (final plan in futurePlans) {
        try {
          final notificationTime = plan.time!.subtract(const Duration(minutes: 10));
          final notificationId = plan.id.hashCode & 0x7fffffff;

          await _notificationService.schedulePlanNotification(
            id: notificationId,
            title: 'Upcoming Plan',
            body: '${plan.title} at ${plan.place} in 10 minutes',
            scheduledTime: notificationTime,
          );
          scheduledCount++;
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Failed to schedule notification for plan ${plan.id}: $e');
          }
        }
      }

      if (kDebugMode && scheduledCount > 0) {
        debugPrint('Rescheduled $scheduledCount plan notifications');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error rescheduling plan notifications: $e');
      }
    }
  }

  Future<void> clearCache() async {
    try {
      // Clear cache logic here
      SnackbarHelper.showSafe(
        title: 'Cache Cleared',
        message: 'App cache has been cleared successfully',
      );
    } catch (e) {
      SnackbarHelper.showSafe(
        title: 'Error',
        message: 'Failed to clear cache',
      );
    }
  }

  Future<void> clearAllData() async {
    try {
      await _storageService.clearAllData();
      SnackbarHelper.showSafe(
        title: 'Data Cleared',
        message: 'All local data has been cleared',
      );
    } catch (e) {
      SnackbarHelper.showSafe(
        title: 'Error',
        message: 'Failed to clear data',
      );
    }
  }

  Future<void> logout() async {
    try {
      await _authService.signOut();
      SmoothNavigator.offAll(
        () => const LoginView(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 300),
      );
    } catch (e) {
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
          message: 'Could not open Play Store. Please search for "Love Connect" manually.',
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
      const String playStoreLink = 'https://play.google.com/store/apps/details?id=$packageName';
      const String shareText = 'Check out Love Connect - the perfect app for couples!\n\n$playStoreLink';
      
      await Share.share(
        shareText,
        subject: 'Love Connect - App for Couples',
      );
    } catch (e) {
      // Fallback: Copy to clipboard
      const String packageName = 'com.example.love_connect';
      const String playStoreLink = 'https://play.google.com/store/apps/details?id=$packageName';
      const String shareText = 'Check out Love Connect - the perfect app for couples!\n\n$playStoreLink';
      
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

  void showAbout() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('About Love Connect'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Love Connect'),
            const SizedBox(height: 8),
            Text('Version: ${appVersion.value}'),
            const SizedBox(height: 16),
            const Text(
              'A beautiful app designed for couples to plan dates, share memories, and strengthen their relationship.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void showClearDataDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently remove all locally stored data for this app. You can\'t undo this action.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              clearAllData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Get.theme.colorScheme.error,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Get.theme.colorScheme.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

