import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/core/models/user_profile_model.dart';
import 'package:love_connect/core/services/local_storage_service.dart';
import 'package:love_connect/core/services/plans_database_service.dart';
import 'package:love_connect/core/services/journal_database_service.dart';
import 'package:love_connect/core/services/pdf_export_service.dart';
import 'package:love_connect/core/services/auth/auth_service.dart';
import 'package:love_connect/core/utils/media_query_extensions.dart';
import 'package:love_connect/core/utils/snackbar_helper.dart';
import 'package:love_connect/core/navigation/smooth_transitions.dart';
import 'package:love_connect/screens/profile/model/profile_model.dart';
import 'package:love_connect/screens/profile/view/widgets/edit_profile_modal.dart';
import 'package:love_connect/screens/profile/change_password/view/change_password_view.dart';
import 'package:love_connect/screens/profile/terms_privacy/view/terms_of_service_view.dart';
import 'package:love_connect/screens/profile/terms_privacy/view/privacy_policy_view.dart';
import 'package:love_connect/screens/profile/view_model/services/profile_service.dart';
import 'package:love_connect/screens/profile/view_model/services/settings_manager.dart';
import 'package:love_connect/screens/profile/view_model/services/notification_manager.dart';
import 'package:love_connect/screens/profile/view_model/services/account_manager.dart';
import 'package:love_connect/screens/profile/view_model/services/support_manager.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

class ProfileViewModel extends GetxController {
  final ProfileService _profileService = ProfileService();
  final SettingsManager _settingsManager = SettingsManager();
  final NotificationManager _notificationManager = NotificationManager();
  final AccountManager _accountManager = AccountManager();
  final SupportManager _supportManager = SupportManager();
  final LocalStorageService _storageService = LocalStorageService();
  final PlansDatabaseService _plansDbService = PlansDatabaseService();
  final JournalDatabaseService _journalDbService = JournalDatabaseService();
  final PdfExportService _pdfExportService = PdfExportService();
  final AuthService _authService = AuthService();

  final ProfileModel model = const ProfileModel();
  final Rx<UserProfileModel> userProfile = UserProfileModel(
    name: 'User',
    about: 'Keeping the love story alive.',
  ).obs;
  final RxMap<String, bool> settings = <String, bool>{}.obs;
  final RxString appVersion = '1.0.0'.obs;
  final RxBool isLoading = false.obs;
  final RxBool isExporting = false.obs;

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
      final profile = await _profileService.loadProfile();
      final updatedProfile = _profileService.updateProfileFromAuth(profile);
      userProfile.value = updatedProfile;
    } catch (e) {
      SnackbarHelper.showSafe(
        title: 'Error',
        message: 'Failed to load profile',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadSettings() async {
    try {
      final loadedSettings = await _settingsManager.loadSettings();
      settings.value = loadedSettings;
    } catch (e) {
      settings.value = _settingsManager.getDefaultSettings();
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

  Future<void> saveProfile(UserProfileModel profile) async {
    isLoading.value = true;
    try {
      await _profileService.saveProfile(profile);
      
      // Reload profile to get the latest data including local image path
      await loadProfile();
      
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
      await _settingsManager.saveSetting(key, value);
      settings[key] = value;
      _settingsManager.showSettingUpdateMessage(key, value);
    } catch (e) {
      _settingsManager.handleSettingUpdateError(key, e);
    }
  }

  Future<void> _handleSettingSpecificLogic(String key, bool value) async {
    switch (key) {
      case 'notifications':
        await _notificationManager.handlePushNotificationsSetting(
          value,
          settings,
        );
        // Also disable Plan Reminders if Push Notifications is disabled
        if (!value && settings['planReminder'] == true) {
          await _settingsManager.saveSetting('planReminder', false);
          settings['planReminder'] = false;
        }
        break;
      case 'planReminder':
        await _notificationManager.handlePlanReminderSetting(value, settings);
        break;
    }
  }

  Future<void> clearCache() async {
    try {
      isLoading.value = true;
      await _accountManager.clearCache();
    } catch (e) {
      // Error already handled in account manager
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> clearAllData() async {
    try {
      isLoading.value = true;
      await _accountManager.clearAllData();
    } catch (e) {
      // Error already handled in account manager
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteAccount() async {
    try {
      isLoading.value = true;
      await _accountManager.deleteAccount();
    } catch (e) {
      // Error already handled in account manager
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      await _accountManager.logout();
    } catch (e) {
      // Error already handled in account manager
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> contactSupport() async {
    await _supportManager.contactSupport();
  }

  Future<void> rateApp() async {
    await _supportManager.rateApp();
  }

  Future<void> shareApp() async {
    await _supportManager.shareApp();
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
                child: SizedBox(
                width: 100,
                  height: 100,
                  child: Image.asset(
                    'assets/app_icon/app_icon.png',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.favorite_rounded,
                        color: AppColors.primaryRed,
                        size: 40,
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: context.responsiveSpacing(10)),

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
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SvgPicture.asset(
                      'assets/svg/new_svg/cache.svg',
                      width: 32,
                      height: 32,
                      colorFilter: const ColorFilter.mode(
                        AppColors.primaryRed,
                        BlendMode.srcIn,
                      ),
                    ),
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
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SvgPicture.asset(
                      'assets/svg/new_svg/data.svg',
                      width: 32,
                      height: 32,
                      colorFilter: const ColorFilter.mode(
                        AppColors.primaryRed,
                        BlendMode.srcIn,
                      ),
                    ),
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
                  'This will permanently delete ALL your data including:\n\n• All your plans\n• Your profile information\n• Journal entries\n• Notifications\n• Settings\n\nThis action cannot be undone!',
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

  void showDeleteAccountDialog(BuildContext context) {
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
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SvgPicture.asset(
                      'assets/svg/new_svg/delete_user.svg',
                      width: 32,
                      height: 32,
                      colorFilter: const ColorFilter.mode(
                        AppColors.primaryRed,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: context.responsiveSpacing(20)),

              // Title
              Text(
                'Delete Account',
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
                  'This will permanently delete your account and ALL data including:\n\n• Your account from Database\n• All your plans from Database\n• Your profile information\n• Journal entries\n• Notifications\n• Settings\n• All local storage data\n\nThis action cannot be undone!',
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
                        deleteAccount();
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
                        'Delete Account',
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
    return await _profileService.pickImage();
  }

  Future<String?> uploadProfilePicture(File imageFile) async {
    return await _profileService.uploadProfilePicture(imageFile);
  }

  Future<String?> saveProfileImageLocally(File imageFile) async {
    return await _profileService.saveProfileImageLocally(imageFile);
  }

  Future<String?> getLocalProfileImagePath() async {
    return await _profileService.getLocalProfileImagePath();
  }

  /// Export data to PDF
  Future<void> exportDataToPdf(BuildContext context) async {
    if (isExporting.value) return;

    isExporting.value = true;
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        SnackbarHelper.showSafe(
          title: 'Error',
          message: 'Please login to export data',
        );
        return;
      }

      // Load plans and journal entries
      final plans = await _plansDbService.getPlans(userId);
      final journalEntries = await _journalDbService.getJournalEntries(userId);

      // Get user profile data
      final profile = userProfile.value;

      // Generate filename with timestamp
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'love_connect_scrapbook_$timestamp';

      // Export to PDF
      final file = await _pdfExportService.exportDataToPdf(
        plans: plans,
        journalEntries: journalEntries,
        userProfile: profile,
        fileName: fileName,
      );

      if (file != null && await file.exists()) {
        // Share the file
        try {
          await Share.shareXFiles(
            [XFile(file.path)],
            text: 'My Love Connect Digital Scrapbook',
            subject: 'Love Connect - Digital Scrapbook',
          );

          SnackbarHelper.showSafe(
            title: 'Export Successful',
            message: 'Your data has been exported and shared!',
            duration: const Duration(seconds: 3),
          );
        } catch (e) {
          // Fallback to text sharing if file sharing fails
          await Share.share(
            'Love Connect Digital Scrapbook\n\nFile saved at: ${file.path}',
            subject: 'Love Connect - Digital Scrapbook',
          );
        }
      } else {
        SnackbarHelper.showSafe(
          title: 'Export Failed',
          message: 'Failed to create PDF. Please try again.',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error exporting PDF: $e');
      }
      SnackbarHelper.showSafe(
        title: 'Error',
        message: 'Failed to export data. Please try again.',
      );
    } finally {
      isExporting.value = false;
    }
  }

  /// Show PDF export dialog
  void showExportDataDialog(BuildContext context) {
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
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SvgPicture.asset(
                      'assets/svg/new_svg/pdf.svg',
                      width: 32,
                      height: 32,
                      colorFilter: const ColorFilter.mode(
                        AppColors.primaryRed,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: context.responsiveSpacing(20)),

              // Title
              Text(
                'Export Data',
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
                'Export your plans and journal entries as a PDF "Digital Scrapbook". The file will be shared so you can save it to your device.',
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
                    child: Obx(
                      () => ElevatedButton(
                        onPressed: isExporting.value
                            ? null
                            : () {
                                Get.back();
                                exportDataToPdf(context);
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
                        child: isExporting.value
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.white,
                                  ),
                                ),
                              )
                            : Text(
                                'Export',
                                style: GoogleFonts.inter(
                                  fontSize: context.responsiveFont(16),
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.white,
                                ),
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
