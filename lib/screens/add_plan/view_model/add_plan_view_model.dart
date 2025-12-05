import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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
      
      // Try to load from Firebase first if user is authenticated
      if (userId != null) {
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
      }
      
      // Fallback to local storage
      final plans = await _storageService.getPlans();
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
    } catch (e) {
      // If Firebase fails, try local storage
      final plans = await _storageService.getPlans();
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
      final planType = _getPlanTypeFromString(model.value.type);
      final plan = PlanModel(
        id: planId ?? const Uuid().v4(),
        title: model.value.title,
        date: model.value.date,
        time: model.value.time,
        place: model.value.place,
        type: planType,
      );

      final userId = _authService.currentUserId;

      // Save to local storage first (faster, immediate feedback)
      bool savedLocally = false;
      try {
        await _storageService.savePlan(plan);
        savedLocally = true;
      } catch (e) {
        print('Failed to save plan to local storage: $e');
      }

      // Save to Firebase in parallel (non-blocking)
      Future<bool>? firebaseFuture;
      if (userId != null) {
        firebaseFuture = _plansDbService.savePlan(
          userId: userId,
          plan: plan,
        );
        // Don't await - let it run in background
        firebaseFuture.then((success) {
          if (success && kDebugMode) {
            debugPrint('Plan saved to Firebase successfully');
          }
        }).catchError((e) {
          if (kDebugMode) {
            debugPrint('Firebase save error (non-blocking): $e');
          }
        });
      }

      // Schedule notification (non-blocking)
      _schedulePlanNotification(plan).catchError((e) {
        if (kDebugMode) {
          debugPrint('Notification scheduling error: $e');
        }
      });

      // Close immediately after local save (fast user feedback)
      if (savedLocally) {
        if (onCloseCallback != null) {
          onCloseCallback!();
        } else {
          Get.back(result: true);
        }

        // Show success message
        final String titleText =
            planId != null ? 'Plan Updated' : 'Plan Saved';
        SnackbarHelper.showSafe(
          title: titleText,
          message: userId != null
              ? 'Your plan has been saved. Syncing to cloud...'
              : 'Your plan has been saved successfully',
          duration: const Duration(seconds: 2),
        );
      } else {
        // Local save failed - try Firebase as fallback
        if (userId != null && firebaseFuture != null) {
          final savedToFirebase = await firebaseFuture;
          if (savedToFirebase) {
            if (onCloseCallback != null) {
              onCloseCallback!();
            } else {
              Get.back(result: true);
            }
            SnackbarHelper.showSafe(
              title: planId != null ? 'Plan Updated' : 'Plan Saved',
              message: 'Your plan has been saved successfully',
            );
          } else {
            SnackbarHelper.showSafe(
              title: 'Error',
              message: 'Failed to save plan. Please check your connection and try again.',
            );
          }
        } else {
          SnackbarHelper.showSafe(
            title: 'Error',
            message: 'Failed to save plan. Please try again.',
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error saving plan: $e');
      }
      SnackbarHelper.showSafe(
        title: 'Error',
        message: 'Failed to save plan. Please try again.',
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> _schedulePlanNotification(PlanModel plan) async {
    // Only schedule if we have a specific time
    final DateTime? planTime = plan.time;
    if (planTime == null) {
      return;
    }

    // Check user settings for notifications and plan reminders
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

    // Schedule notification 10 minutes before the plan time
    final DateTime notificationTime = planTime.subtract(const Duration(minutes: 10));

    // Only schedule if notification time is in the future
    if (notificationTime.isBefore(DateTime.now())) {
      return;
    }

    // Use a stable int ID derived from the plan id hashCode
    final int notificationId = plan.id.hashCode & 0x7fffffff;

    await _notificationService.schedulePlanNotification(
      id: notificationId,
      title: 'Upcoming Plan',
      body: '${plan.title} at ${plan.place} in 10 minutes',
      scheduledTime: notificationTime,
    );

    // Also store a local notification entry for the in-app notifications screen
    try {
      final notification = NotificationModel(
        id: const Uuid().v4(),
        title: 'Upcoming Plan',
        message: '${plan.title} at ${plan.place}',
        date: planTime,
        type: NotificationType.reminder,
      );
      await _storageService.saveNotification(notification);
    } catch (e) {
      // Ignore errors when saving notification locally
      print('Failed to save notification locally: $e');
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

