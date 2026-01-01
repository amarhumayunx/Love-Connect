import 'package:flutter/foundation.dart';
import 'package:love_connect/core/services/local_storage_service.dart';
import 'package:love_connect/core/utils/snackbar_helper.dart';

class SettingsManager {
  final LocalStorageService _storageService = LocalStorageService();

  Map<String, bool> getDefaultSettings() {
    return {
      'notifications': true,
      'planReminder': true,
      'emailNotifications': true,
      'privateJournal': true,
      'hideLocation': true,
    };
  }

  Future<Map<String, bool>> loadSettings() async {
    try {
      return await _storageService.getSettings();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading settings: $e');
      }
      return getDefaultSettings();
    }
  }

  Future<void> saveSetting(String key, bool value) async {
    try {
      await _storageService.saveSetting(key, value);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error saving setting $key: $e');
      }
      rethrow;
    }
  }

  void showNotificationMessage(bool enabled) {
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

  void showPlanReminderMessage(bool enabled) {
    SnackbarHelper.showSafe(
      title: enabled ? 'Plan Reminders Enabled' : 'Plan Reminders Disabled',
      message: enabled
          ? 'You will receive reminders 10 minutes before your plans'
          : 'Plan reminder notifications have been cancelled',
      duration: const Duration(seconds: 2),
    );
  }

  void showSettingUpdateMessage(String key, bool value) {
    switch (key) {
      case 'notifications':
        showNotificationMessage(value);
        break;
      case 'planReminder':
        showPlanReminderMessage(value);
        break;
    }
  }

  void handleSettingUpdateError(String key, dynamic error) {
    if (kDebugMode) {
      debugPrint('Error updating setting $key: $error');
    }
    SnackbarHelper.showSafe(
      title: 'Error',
      message: 'Failed to update setting',
    );
  }
}
