import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/core/models/user_profile_model.dart';
import 'package:love_connect/core/models/plan_model.dart';
import 'package:love_connect/core/services/local_storage_service.dart';
import 'package:love_connect/core/services/auth/auth_service.dart';
import 'package:love_connect/core/services/user_database_service.dart';
import 'package:love_connect/core/services/storage_service.dart';
import 'package:love_connect/core/services/notification_service.dart';
import 'package:love_connect/core/services/plans_database_service.dart';
import 'package:love_connect/core/utils/media_query_extensions.dart';
import 'package:love_connect/core/utils/snackbar_helper.dart';
import 'package:love_connect/core/navigation/smooth_transitions.dart';
import 'package:love_connect/screens/auth/login/view/login_view.dart';
import 'package:love_connect/screens/profile/model/profile_model.dart';
import 'package:love_connect/screens/profile/change_password/view/change_password_view.dart';
import 'package:love_connect/screens/profile/terms_privacy/view/terms_of_service_view.dart';
import 'package:love_connect/screens/profile/terms_privacy/view/privacy_policy_view.dart';
import 'package:love_connect/screens/home/view_model/home_view_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class ProfileViewModel extends GetxController {
  final LocalStorageService _storageService = LocalStorageService();
  final AuthService _authService = AuthService();
  final UserDatabaseService _userDbService = UserDatabaseService();
  final StorageService _storageServiceFirebase = StorageService();
  final NotificationService _notificationService = NotificationService();
  final PlansDatabaseService _plansDbService = PlansDatabaseService();
  final ProfileModel model = const ProfileModel();
  final Rx<UserProfileModel> userProfile = UserProfileModel(
    name: 'User',
    about: 'Keeping the love story alive.',
  ).obs;
  final RxMap<String, bool> settings = <String, bool>{}.obs;
  final RxString appVersion = '1.0.0'.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
    loadSettings();
    loadAppVersion();
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    try {
      final userId = _authService.currentUserId;
      final user = _authService.currentUser;

      if (userId == null) {
        // Fallback to local storage
        final profile = await _storageService.getUserProfile();
        userProfile.value = profile;
        isLoading.value = false;
        return;
      }

      // Try to load from Firebase first
      final firebaseProfile = await _userDbService.getUserProfile(userId);

      if (firebaseProfile != null) {
        userProfile.value = UserProfileModel(
          name: firebaseProfile['name'] as String? ?? 'User',
          about:
              firebaseProfile['about'] as String? ??
              'Keeping the love story alive.',
          profilePictureUrl: firebaseProfile['profilePictureUrl'] as String?,
          email: user?.email ?? firebaseProfile['email'] as String?,
          gender: firebaseProfile['gender'] as String?,
        );
      } else {
        // Load from local storage and migrate to Firebase
        final localProfile = await _storageService.getUserProfile();
        final googlePhotoUrl = user?.photoURL;

        userProfile.value = localProfile.copyWith(
          email: user?.email,
          profilePictureUrl: googlePhotoUrl,
        );

        // Save to Firebase
        await _userDbService.saveUserProfile(
          userId: userId,
          name: userProfile.value.name,
          about: userProfile.value.about,
          profilePictureUrl: userProfile.value.profilePictureUrl,
          email: userProfile.value.email,
          gender: userProfile.value.gender,
        );
      }

      // Update name from Firebase Auth if available
      if (user != null &&
          user.displayName != null &&
          userProfile.value.name == 'User') {
        userProfile.value = userProfile.value.copyWith(name: user.displayName!);
      }

      // Update email if not set
      if (userProfile.value.email == null && user?.email != null) {
        userProfile.value = userProfile.value.copyWith(email: user!.email);
      }

      // Update Google photo URL if not set
      if (userProfile.value.profilePictureUrl == null &&
          user?.photoURL != null) {
        userProfile.value = userProfile.value.copyWith(
          profilePictureUrl: user!.photoURL,
        );
      }
    } catch (e) {
      // Fallback to local storage
      try {
        final profile = await _storageService.getUserProfile();
        final user = _authService.currentUser;
        userProfile.value = profile.copyWith(
          email: user?.email,
          profilePictureUrl: user?.photoURL,
        );
      } catch (e2) {
        SnackbarHelper.showSafe(
          title: 'Error',
          message: 'Failed to load profile',
        );
      }
    } finally {
      isLoading.value = false;
    }
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
    };
  }

  Future<void> saveProfile(UserProfileModel profile) async {
    isLoading.value = true;
    try {
      final userId = _authService.currentUserId;
      final user = _authService.currentUser;

      if (userId == null) {
        SnackbarHelper.showSafe(
          title: 'Error',
          message: 'User not authenticated',
        );
        isLoading.value = false;
        return;
      }

      // Save to Firebase Realtime Database
      await _userDbService.saveUserProfile(
        userId: userId,
        name: profile.name,
        about: profile.about,
        profilePictureUrl: profile.profilePictureUrl,
        email: profile.email ?? user?.email,
        gender: profile.gender,
      );

      // Also save to local storage for offline access
      await _storageService.saveUserProfile(profile);

      userProfile.value = profile;

      // Update home screen if available
      try {
        final homeViewModel = Get.find<HomeViewModel>();
        // Call public method to reload user info
        homeViewModel.loadUserInfo();
      } catch (e) {
        // HomeViewModel not available, ignore
      }

      Get.back();
      SnackbarHelper.showSafe(
        title: 'Profile Updated',
        message: 'Your profile has been saved',
      );
    } catch (e) {
      SnackbarHelper.showSafe(
        title: 'Error',
        message: 'Failed to save profile',
      );
    } finally {
      isLoading.value = false;
    }
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

  void showEditProfileModal() {
    Get.dialog(
      EditProfileModal(
        profile: userProfile.value,
        onSave: saveProfile,
        viewModel: this,
      ),
      barrierDismissible: true,
    );
  }

  Future<File?> pickImage() async {
    try {
      // On iOS, image_picker handles permissions automatically if Info.plist has the required keys
      // On Android, we need to explicitly request permissions
      if (Platform.isAndroid) {
        PermissionStatus status;
        if (await Permission.photos.isRestricted) {
          status = await Permission.storage.request();
        } else {
          status = await Permission.photos.request();
          if (!status.isGranted) {
            // Fallback to storage permission for older Android versions
            status = await Permission.storage.request();
          }
        }

        if (!status.isGranted) {
          SnackbarHelper.showSafe(
            title: 'Permission Denied',
            message: 'Please grant photo access permission in app settings',
          );
          return null;
        }
      }

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      SnackbarHelper.showSafe(
        title: 'Error', 
        message: 'Failed to pick image: ${e.toString()}'
      );
      return null;
    }
  }

  Future<String?> uploadProfilePicture(File imageFile) async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) return null;

      final downloadUrl = await _storageServiceFirebase.uploadProfilePicture(
        imageFile,
        userId,
      );
      return downloadUrl;
    } catch (e) {
      return null;
    }
  }
}

// Edit Profile Modal Widget
class EditProfileModal extends StatefulWidget {
  final UserProfileModel profile;
  final Function(UserProfileModel) onSave;
  final ProfileViewModel viewModel;

  const EditProfileModal({
    super.key,
    required this.profile,
    required this.onSave,
    required this.viewModel,
  });

  @override
  State<EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends State<EditProfileModal> {
  late final TextEditingController nameController;
  late final TextEditingController aboutController;
  String? _selectedImagePath;
  String? _profilePictureUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.profile.name);
    aboutController = TextEditingController(text: widget.profile.about);
    _profilePictureUrl = widget.profile.profilePictureUrl;
  }

  @override
  void dispose() {
    nameController.dispose();
    aboutController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    final imageFile = await widget.viewModel.pickImage();
    if (imageFile == null) return;

    setState(() {
      _selectedImagePath = imageFile.path;
      _isUploading = true;
    });

    try {
      final downloadUrl = await widget.viewModel.uploadProfilePicture(
        imageFile,
      );
      if (downloadUrl != null) {
        setState(() {
          _profilePictureUrl = downloadUrl;
          _isUploading = false;
        });
      } else {
        setState(() {
          _isUploading = false;
        });
        SnackbarHelper.showSafe(
          title: 'Error',
          message: 'Failed to upload image',
        );
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      SnackbarHelper.showSafe(
        title: 'Error',
        message: 'Failed to upload image',
      );
    }
  }

  Widget _buildProfileImage() {
    if (_isUploading) {
      return Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[200],
        ),
        child: Center(
          child: LoadingAnimationWidget.horizontalRotatingDots(
            color: AppColors.primaryRed,
            size: 50,
          ),
        ),
      );
    }

    if (_selectedImagePath != null) {
      return Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[200],
        ),
        child: ClipOval(
          child: Image.file(File(_selectedImagePath!), fit: BoxFit.cover),
        ),
      );
    }

    if (_profilePictureUrl != null && _profilePictureUrl!.isNotEmpty) {
      return Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[200],
        ),
        child: ClipOval(
          child: Image.network(
            _profilePictureUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                'assets/images/profile.jpg',
                fit: BoxFit.cover,
              );
            },
          ),
        ),
      );
    }

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[200],
      ),
      child: ClipOval(
        child: Image.asset('assets/images/profile.jpg', fit: BoxFit.cover),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 20),
            // Profile Picture (with camera icon overlay)
            Stack(
              children: [
                _buildProfileImage(),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickAndUploadImage,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primaryRed,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 2),
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: AppColors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Email Display
            if (widget.profile.email != null &&
                widget.profile.email!.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Text(
                      widget.profile.email!,
                      style: GoogleFonts.inter(
                        fontSize: context.responsiveFont(14),
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryDark,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.profile.gender != null &&
                        widget.profile.gender!.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          widget.profile.gender!,
                          style: GoogleFonts.inter(
                            fontSize: context.responsiveFont(12),
                            fontWeight: FontWeight.w400,
                            color: AppColors.textLightPink,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            SizedBox(height: 24),

            // Name Field
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Name',
                    style: GoogleFonts.inter(
                      fontSize: context.responsiveFont(14),
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    style: GoogleFonts.inter(
                      fontSize: context.responsiveFont(14),
                      color: AppColors.primaryDark,
                    ),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.textLightPink,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.textLightPink,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.textLightPink,
                          width: 1,
                        ),
                      ),
                      suffixIcon: Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Icon(
                          Icons.edit,
                          color: AppColors.primaryRed,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // About Field
                  Text(
                    'About',
                    style: GoogleFonts.inter(
                      fontSize: context.responsiveFont(14),
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: aboutController,
                    maxLines: 3,
                    style: GoogleFonts.inter(
                      fontSize: context.responsiveFont(14),
                      color: AppColors.primaryDark,
                    ),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.textLightPink,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.textLightPink,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.textLightPink,
                          width: 1,
                        ),
                      ),
                      suffixIcon: Padding(
                        padding: EdgeInsets.only(right: 8, top: 8),
                        child: Icon(
                          Icons.edit,
                          color: AppColors.primaryRed,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Buttons
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: AppColors.textLightPink,
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.inter(
                          fontSize: context.responsiveFont(16),
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onSave(
                          UserProfileModel(
                            name: nameController.text.trim(),
                            about: aboutController.text.trim(),
                            profilePictureUrl: _profilePictureUrl,
                            email: widget.profile.email,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      child: Text(
                        'Save',
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
            ),
          ],
        ),
      ),
    );
  }
}
