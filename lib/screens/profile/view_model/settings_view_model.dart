import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_connect/core/services/local_storage_service.dart';
import 'package:love_connect/core/services/auth/auth_service.dart';
import 'package:love_connect/core/utils/snackbar_helper.dart';
import 'package:love_connect/core/navigation/smooth_transitions.dart';
import 'package:love_connect/screens/auth/login/view/login_view.dart';
import 'package:love_connect/screens/profile/model/settings_model.dart';
import 'package:flutter/services.dart';

class SettingsViewModel extends GetxController {
  final LocalStorageService _storageService = LocalStorageService();
  final AuthService _authService = AuthService();
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
    // App version from pubspec.yaml - version: 1.0.0+1
    appVersion.value = '1.0.0 (1)';
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
      await _storageService.saveSetting(key, value);
      settings[key] = value;
    } catch (e) {
      SnackbarHelper.showSafe(
        title: 'Error',
        message: 'Failed to update setting',
      );
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
    SnackbarHelper.showSafe(
      title: 'Contact Support',
      message: 'Email: $email',
      duration: const Duration(seconds: 5),
    );
  }

  Future<void> rateApp() async {
    SnackbarHelper.showSafe(
      title: 'Rate App',
      message: 'Thank you for using Love Connect! Rating feature coming soon.',
    );
  }

  Future<void> shareApp() async {
    final text = 'Check out Love Connect - the perfect app for couples!';
    await Clipboard.setData(ClipboardData(text: text));
    SnackbarHelper.showSafe(
      title: 'Copied to Clipboard',
      message: 'Share link copied!',
    );
  }

  void showTermsOfService() {
    SnackbarHelper.showSafe(
      title: 'Terms of Service',
      message: 'Terms of Service will be available soon.',
    );
  }

  void showPrivacyPolicy() {
    SnackbarHelper.showSafe(
      title: 'Privacy Policy',
      message: 'Privacy Policy will be available soon.',
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

