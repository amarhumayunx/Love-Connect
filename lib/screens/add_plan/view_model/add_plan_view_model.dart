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
    _plansDbService.savePlan(userId: userId, plan: plan).catchError((_) {
      // Background save errors are handled silently
    });
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

  Future<void> _handleLocalSaveFailure(
    PlanModel plan,
    String userId,
  ) async {
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
      message: 'Failed to save plan. Please check your connection and try again.',
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

    await _notificationService.ensureInitializedWithPermissions();

    try {
      final settings = await _storageService.getSettings();
      final bool notificationsEnabled = settings['notifications'] ?? true;
      final bool planReminderEnabled = settings['planReminder'] ?? true;

      if (!notificationsEnabled || !planReminderEnabled) {
        return;
      }
    } catch (_) {
      // If settings can't be loaded, default to allowing notifications
    }

    final DateTime notificationTime = planTime.subtract(
      const Duration(minutes: 10),
    );

    if (notificationTime.isBefore(DateTime.now())) {
      return;
    }

    final int notificationId = plan.id.hashCode & 0x7fffffff;

    await _notificationService.schedulePlanNotification(
      id: notificationId,
      title: 'Upcoming Plan',
      body: '${plan.title} at ${plan.place} in 10 minutes',
      scheduledTime: notificationTime,
    );

    try {
      final userId = _authService.currentUserId;
      if (userId != null) {
        final notification = NotificationModel(
          id: const Uuid().v4(),
          title: 'Upcoming Plan',
          message: '${plan.title} at ${plan.place}',
          date: planTime,
          type: NotificationType.reminder,
        );
        await _storageService.saveNotification(notification, userId: userId);
      }
    } catch (_) {
      // Ignore errors when saving notification locally
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
