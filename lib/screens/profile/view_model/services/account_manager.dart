import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:love_connect/core/services/auth/auth_service.dart';
import 'package:love_connect/core/services/journal_database_service.dart';
import 'package:love_connect/core/services/local_storage_service.dart';
import 'package:love_connect/core/services/notification_service.dart';
import 'package:love_connect/core/services/plans_database_service.dart';
import 'package:love_connect/core/services/user_database_service.dart';
import 'package:love_connect/core/navigation/smooth_transitions.dart';
import 'package:love_connect/core/utils/snackbar_helper.dart';
import 'package:love_connect/screens/auth/login/view/login_view.dart';

class AccountManager {
  final AuthService _authService = AuthService();
  final LocalStorageService _storageService = LocalStorageService();
  final NotificationService _notificationService = NotificationService();
  final PlansDatabaseService _plansDbService = PlansDatabaseService();
  final UserDatabaseService _userDbService = UserDatabaseService();

  Future<void> logout() async {
    try {
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

      // Navigate to login screen
      SmoothNavigator.offAll(
        () => const LoginView(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 300),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error during logout: $e');
      }
      SnackbarHelper.showSafe(
        title: 'Logout Failed',
        message: 'An error occurred during logout. Please try again.',
      );
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    try {
      // Get current user ID before deletion
      final userId = _authService.currentUserId;

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Delete all user data from Firebase Realtime Database
      // 1. Delete all plans
      await _plansDbService.deleteAllPlans(userId);

      // 2. Delete all journal entries
      final JournalDatabaseService journalDbService = JournalDatabaseService();
      await journalDbService.deleteAllJournalEntries(userId);

      // 3. Delete user profile data
      await _userDbService.deleteUserData(userId);

      // Clear all local storage data
      await _storageService.clearAllData(userId: userId);
      await _storageService.clearAnonymousData();

      // Cancel all notifications
      await _notificationService.cancelAllNotifications();

      // Delete user from Firebase Authentication
      final deleteResult = await _authService.deleteUser();
      if (!deleteResult.success) {
        throw Exception(deleteResult.errorMessage ?? 'Failed to delete account');
      }

      // Navigate to login screen
      SmoothNavigator.offAll(
        () => const LoginView(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 300),
      );

      SnackbarHelper.showSafe(
        title: 'Account Deleted',
        message: 'Your account has been permanently deleted',
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error deleting account: $e');
      }
      SnackbarHelper.showSafe(
        title: 'Error',
        message: 'Failed to delete account. Please try again.',
      );
      rethrow;
    }
  }

  Future<void> clearCache() async {
    try {
      // Cancel all notifications (they're cached)
      await _notificationService.cancelAllNotifications();

      SnackbarHelper.showSafe(
        title: 'Cache Cleared',
        message: 'App cache has been cleared successfully',
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error clearing cache: $e');
      }
      SnackbarHelper.showSafe(
        title: 'Error',
        message: 'Failed to clear cache. Please try again.',
      );
      rethrow;
    }
  }

  Future<void> clearAllData() async {
    try {
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

      SnackbarHelper.showSafe(
        title: 'Data Cleared',
        message: 'All user data has been permanently deleted',
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error clearing all data: $e');
      }
      SnackbarHelper.showSafe(
        title: 'Error',
        message: 'Failed to clear data. Please try again.',
      );
      rethrow;
    }
  }
}
