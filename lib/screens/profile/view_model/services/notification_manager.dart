import 'package:flutter/foundation.dart';
import 'package:love_connect/core/models/plan_model.dart';
import 'package:love_connect/core/services/auth/auth_service.dart';
import 'package:love_connect/core/services/local_storage_service.dart';
import 'package:love_connect/core/services/notification_service.dart';
import 'package:love_connect/core/services/plans_database_service.dart';
import 'package:love_connect/core/utils/snackbar_helper.dart';

class NotificationManager {
  final NotificationService _notificationService = NotificationService();
  final AuthService _authService = AuthService();
  final LocalStorageService _storageService = LocalStorageService();
  final PlansDatabaseService _plansDbService = PlansDatabaseService();

  /// Handle Push Notifications setting changes
  Future<void> handlePushNotificationsSetting(
    bool enabled,
    Map<String, bool> settings,
  ) async {
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
          await rescheduleAllPlanNotifications(settings);
        }
      }
    } else {
      // Cancel all notifications when disabling
      await _notificationService.cancelAllNotifications();
    }
  }

  /// Handle Plan Reminder setting changes
  Future<void> handlePlanReminderSetting(
    bool enabled,
    Map<String, bool> settings,
  ) async {
    if (enabled) {
      // Reschedule notifications for all future plans
      await rescheduleAllPlanNotifications(settings);
    } else {
      // Cancel all plan notifications
      await _notificationService.cancelAllPlanNotifications();
    }
  }

  /// Reschedule notifications for all future plans
  Future<void> rescheduleAllPlanNotifications(
    Map<String, bool> settings,
  ) async {
    try {
      if (!(settings['notifications'] ?? true)) {
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

  Future<void> cancelAllNotifications() async {
    await _notificationService.cancelAllNotifications();
  }
}
