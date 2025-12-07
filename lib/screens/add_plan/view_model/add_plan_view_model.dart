import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_connect/core/models/plan_model.dart';
import 'package:love_connect/core/models/notification_model.dart';
import 'package:love_connect/core/services/local_storage_service.dart';
import 'package:love_connect/core/services/plans_database_service.dart';
import 'package:love_connect/core/services/auth/auth_service.dart';
import 'package:love_connect/core/services/notification_service.dart';
import 'package:love_connect/core/utils/snackbar_helper.dart';
import 'package:love_connect/screens/add_plan/model/add_plan_model.dart';
import 'package:love_connect/screens/home/view_model/home_view_model.dart';
import 'package:uuid/uuid.dart';

class AddPlanViewModel extends GetxController {
  final LocalStorageService _storageService = LocalStorageService();
  final PlansDatabaseService _plansDbService = PlansDatabaseService();
  final AuthService _authService = AuthService();
  final NotificationService _notificationService = NotificationService();
  final Rx<AddPlanModel> model = AddPlanModel().obs;
  final RxBool isSaving = false.obs;
  final String? planId; // If editing
  VoidCallback? onCloseCallback; // Optional callback for overlay mode

  AddPlanViewModel({this.planId, this.onCloseCallback});

  @override
  void onInit() {
    super.onInit();
    if (planId != null) {
      _loadPlan();
    }
  }

  Future<void> _loadPlan() async {
    try {
      final userId = _authService.currentUserId;

      if (userId == null) {
        // No user authenticated - can't load plan
        return;
      }

      // Try to load from Firebase first
      final plans = await _plansDbService.getPlans(userId);
      final plan = plans.firstWhereOrNull((p) => p.id == planId);
      if (plan != null) {
        model.value = AddPlanModel(
          title: plan.title,
          date: plan.date,
          time: plan.time,
          place: plan.place,
          type: plan.type.displayName,
        );
        return;
      }

      // Fallback to user-specific local storage
      final localPlans = await _storageService.getPlans(userId: userId);
      final localPlan = localPlans.firstWhereOrNull((p) => p.id == planId);
      if (localPlan != null) {
        model.value = AddPlanModel(
          title: localPlan.title,
          date: localPlan.date,
          time: localPlan.time,
          place: localPlan.place,
          type: localPlan.type.displayName,
        );
      }
    } catch (e) {
      // If Firebase fails, try user-specific local storage
      final userId = _authService.currentUserId;
      if (userId != null) {
        try {
          final plans = await _storageService.getPlans(userId: userId);
          final plan = plans.firstWhereOrNull((p) => p.id == planId);
          if (plan != null) {
            model.value = AddPlanModel(
              title: plan.title,
              date: plan.date,
              time: plan.time,
              place: plan.place,
              type: plan.type.displayName,
            );
          }
        } catch (_) {
          // Ignore errors
        }
      }
    }
  }

  void updateTitle(String value) {
    model.value = model.value.copyWith(title: value);
  }

  void updateDate(DateTime value) {
    model.value = model.value.copyWith(date: value);
  }

  void updateTime(TimeOfDay? value) {
    if (value != null) {
      final now = model.value.date;
      final dateTime = DateTime(
        now.year,
        now.month,
        now.day,
        value.hour,
        value.minute,
      );
      model.value = model.value.copyWith(time: dateTime);
    } else {
      model.value = model.value.copyWith(time: null);
    }
  }

  void updatePlace(String value) {
    model.value = model.value.copyWith(place: value);
  }

  void updateType(String value) {
    model.value = model.value.copyWith(type: value);
  }

  bool get isValid {
    return model.value.title.isNotEmpty &&
        model.value.place.isNotEmpty &&
        model.value.type.isNotEmpty;
  }

  Future<void> savePlan() async {
    if (!isValid) {
      SnackbarHelper.showSafe(
        title: 'Validation Error',
        message: 'Please fill in all required fields',
      );
      return;
    }

    isSaving.value = true;
    try {
      final plan = _createPlanFromModel();
      final userId = _authService.currentUserId;

      if (userId == null) {
        _handleAuthenticationError();
        return;
      }

      final savedLocally = await _saveToLocalStorage(plan, userId);
      _initiateBackgroundSave(plan, userId);
      _scheduleNotification(plan);

      if (savedLocally) {
        _handleLocalSaveSuccess();
      } else {
        await _handleLocalSaveFailure(plan, userId);
      }
    } catch (e) {
      _handleSaveError();
    } finally {
      isSaving.value = false;
    }
  }

  PlanModel _createPlanFromModel() {
    final planType = _getPlanTypeFromString(model.value.type);
    return PlanModel(
      id: planId ?? const Uuid().v4(),
      title: model.value.title,
      date: model.value.date,
      time: model.value.time,
      place: model.value.place,
      type: planType,
    );
  }

  void _handleAuthenticationError() {
    SnackbarHelper.showSafe(
      title: 'Error',
      message: 'Please login to save plans',
    );
    isSaving.value = false;
  }

  Future<bool> _saveToLocalStorage(PlanModel plan, String userId) async {
    try {
      await _storageService.savePlan(plan, userId: userId);
      return true;
    } catch (_) {
      return false;
    }
  }

  void _initiateBackgroundSave(PlanModel plan, String userId) {
    _plansDbService
        .savePlan(userId: userId, plan: plan)
        .then(
          (_) {},
          onError: (_) {
            // Background save errors are handled silently
          },
        );
  }

  void _scheduleNotification(PlanModel plan) {
    _schedulePlanNotification(plan).catchError((_) {
      // Notification scheduling errors are handled silently
    });
  }

  void _handleLocalSaveSuccess() {
    _closeView();
    final titleText = planId != null ? 'Plan Updated' : 'Plan Saved';
    SnackbarHelper.showSafe(
      title: titleText,
      message: 'Your plan has been saved. Syncing to cloud...',
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> _handleLocalSaveFailure(PlanModel plan, String userId) async {
    try {
      final savedToFirebase = await _plansDbService.savePlan(
        userId: userId,
        plan: plan,
      );
      if (savedToFirebase) {
        _closeView();
        final titleText = planId != null ? 'Plan Updated' : 'Plan Saved';
        SnackbarHelper.showSafe(
          title: titleText,
          message: 'Your plan has been saved successfully',
        );
      } else {
        _showSaveError();
      }
    } catch (_) {
      _showSaveError();
    }
  }

  void _closeView() {
    if (onCloseCallback != null) {
      onCloseCallback!();
    } else {
      Get.back(result: true);
    }
  }

  void _showSaveError() {
    SnackbarHelper.showSafe(
      title: 'Error',
      message:
          'Failed to save plan. Please check your connection and try again.',
    );
  }

  void _handleSaveError() {
    SnackbarHelper.showSafe(
      title: 'Error',
      message: 'Failed to save plan. Please try again.',
    );
  }

  Future<void> _schedulePlanNotification(PlanModel plan) async {
    final DateTime? planTime = plan.time;
    if (planTime == null) {
      return;
    }

    // Check if plan is in the future
    if (planTime.isBefore(DateTime.now())) {
      return;
    }

    await _notificationService.ensureInitializedWithPermissions();

    bool notificationsEnabled = true;
    bool planReminderEnabled = true;
    try {
      final settings = await _storageService.getSettings();
      notificationsEnabled = settings['notifications'] ?? true;
      planReminderEnabled = settings['planReminder'] ?? true;
    } catch (_) {
      // If settings can't be loaded, default to allowing notifications
    }

    // Always save notification model for upcoming plans
    await _saveNotificationModel(plan, planTime);

    // Schedule multiple notifications if enabled
    if (notificationsEnabled && planReminderEnabled) {
      await _scheduleMultipleNotifications(plan, planTime);
    }
  }

  /// Schedule multiple notifications at different intervals before the plan
  Future<void> _scheduleMultipleNotifications(
    PlanModel plan,
    DateTime planTime,
  ) async {
    final now = DateTime.now();
    final baseNotificationId = plan.id.hashCode & 0x7fffffff;

    // Define notification intervals: 1 hour, 30 minutes, 15 minutes, 7 minutes, and on-time
    final intervals = [
      const Duration(hours: 1),
      const Duration(minutes: 30),
      const Duration(minutes: 15),
      const Duration(minutes: 7),
      Duration.zero, // On time
    ];

    final messages = [
      '${plan.title} at ${plan.place} in 1 hour',
      '${plan.title} at ${plan.place} in 30 minutes',
      '${plan.title} at ${plan.place} in 15 minutes',
      '${plan.title} at ${plan.place} in 7 minutes',
      '${plan.title} at ${plan.place} is starting now!',
    ];

    for (int i = 0; i < intervals.length; i++) {
      final interval = intervals[i];
      final notificationTime = planTime.subtract(interval);

      // Only schedule if notification time is in the future
      if (notificationTime.isAfter(now)) {
        // Use different notification IDs for each interval
        final notificationId = baseNotificationId + i;

        try {
          await _notificationService.schedulePlanNotification(
            id: notificationId,
            title: 'Upcoming Plan',
            body: messages[i],
            scheduledTime: notificationTime,
          );
          print(
            '✅ ADD_PLAN: Scheduled notification ${i + 1} for plan ${plan.id} at ${notificationTime.toString()}',
          );
        } catch (e) {
          print(
            '❌ ADD_PLAN: Error scheduling notification ${i + 1} for plan ${plan.id}: $e',
          );
        }
      }
    }
  }

  /// Save notification model to storage
  Future<void> _saveNotificationModel(PlanModel plan, DateTime planTime) async {
    try {
      final userId = _authService.currentUserId;
      if (userId != null && userId.isNotEmpty) {
        // Check if notification already exists to avoid duplicates
        final existingNotifications = await _storageService.getNotifications(
          userId: userId,
        );
        final notificationMessage = '${plan.title} at ${plan.place}';
        final alreadyExists = existingNotifications.any(
          (n) =>
              n.type == NotificationType.reminder &&
              n.message == notificationMessage &&
              n.date.isAtSameMomentAs(planTime),
        );

        if (!alreadyExists) {
          final notification = NotificationModel(
            id: const Uuid().v4(),
            title: 'Upcoming Plan',
            message: notificationMessage,
            date: planTime,
            type: NotificationType.reminder,
          );

          print(
            '💾 ADD_PLAN: Saving notification for plan ${plan.id}, userId: $userId',
          );
          await _storageService.saveNotification(notification, userId: userId);
          print('✅ ADD_PLAN: Notification saved successfully');

          // Update home screen notification count
          _updateHomeNotificationCount();
        } else {
          print('ℹ️ ADD_PLAN: Notification already exists for plan ${plan.id}');
        }
      } else {
        print(
          '⚠️ ADD_PLAN: Cannot save notification - userId is null or empty',
        );
      }
    } catch (e) {
      // Log error for debugging but don't block the main flow
      print('❌ ADD_PLAN: Error saving notification for plan ${plan.id}: $e');
    }
  }

  /// Update home screen notification count after saving a notification
  void _updateHomeNotificationCount() {
    try {
      final homeViewModel = Get.find<HomeViewModel>();
      homeViewModel.loadNotifications();
    } catch (e) {
      // HomeViewModel not found, ignore (might not be initialized yet)
    }
  }

  PlanType _getPlanTypeFromString(String type) {
    switch (type.toUpperCase()) {
      case 'DINNER':
        return PlanType.dinner;
      case 'MOVIE':
        return PlanType.movie;
      case 'SURPRISE':
        return PlanType.surprise;
      case 'WALK':
        return PlanType.walk;
      case 'TRIP':
        return PlanType.trip;
      default:
        return PlanType.other;
    }
  }

  List<String> get planTypes => [
    'Surprise',
    'Dinner',
    'Movie',
    'Walk',
    'Trip',
    'Other',
  ];
}
