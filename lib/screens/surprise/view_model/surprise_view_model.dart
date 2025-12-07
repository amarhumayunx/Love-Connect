import 'dart:math';
import 'package:get/get.dart';
import 'package:love_connect/core/models/idea_model.dart';
import 'package:love_connect/core/models/plan_model.dart';
import 'package:love_connect/core/models/journal_entry_model.dart';
import 'package:love_connect/core/models/notification_model.dart';
import 'package:love_connect/core/services/quotes_service.dart';
import 'package:love_connect/core/services/auth/auth_service.dart';
import 'package:love_connect/core/services/local_storage_service.dart';
import 'package:love_connect/core/services/plans_database_service.dart';
import 'package:love_connect/core/services/journal_database_service.dart';
import 'package:love_connect/core/services/notification_service.dart';
import 'package:love_connect/screens/surprise/model/surprise_model.dart';
import 'package:love_connect/screens/home/view_model/home_view_model.dart';
import 'package:love_connect/core/utils/snackbar_helper.dart';
import 'package:uuid/uuid.dart';

class SurpriseViewModel extends GetxController {
  final SurpriseModel model = const SurpriseModel();
  final QuotesService _quotesService = QuotesService();
  final Random _random = Random();
  final LocalStorageService _storageService = LocalStorageService();
  final PlansDatabaseService _plansDbService = PlansDatabaseService();
  final JournalDatabaseService _journalDbService = JournalDatabaseService();
  final AuthService _authService = AuthService();
  final NotificationService _notificationService = NotificationService();

  final RxList<IdeaModel> allIdeas = <IdeaModel>[].obs;
  final Rx<IdeaModel?> selectedIdea = Rx<IdeaModel?>(null);
  final RxBool isWheelSpinning = false.obs;
  final RxBool isSavingPlan = false.obs;
  final RxBool isSavingJournal = false.obs;
  final RxBool isLoadingIdeas = false.obs;
  final RxString errorMessage = ''.obs;

  // Love coupons for scratch card
  final List<String> loveCoupons = [
    'Good for one 30-minute massage',
    'I\'ll do the dishes tonight',
    'Winner of a big hug',
    'Breakfast in bed',
    'You choose the movie tonight',
    'A romantic candlelit dinner',
    'I\'ll make your favorite dessert',
    'A surprise date planned by me',
    'Back rub on demand',
    'You get to sleep in tomorrow',
    'A handwritten love letter',
    'Dance together in the living room',
    'A cozy night with no phones',
    'I\'ll cook your favorite meal',
    'A walk together holding hands',
    'A night of your choice activities',
  ];

  @override
  void onInit() {
    super.onInit();
    loadIdeas();
  }

  void loadIdeas() {
    isLoadingIdeas.value = true;
    errorMessage.value = '';
    
    try {
      final ideas = _quotesService.getAllIdeas();
      allIdeas.value = ideas;
      
      if (ideas.isEmpty) {
        errorMessage.value = 'No ideas available. Please try again later.';
      }
    } catch (e) {
      errorMessage.value = 'Failed to load ideas. Please try again.';
      allIdeas.clear();
    } finally {
      isLoadingIdeas.value = false;
    }
  }

  IdeaModel? spinWheel() {
    if (allIdeas.isEmpty) {
      loadIdeas();
    }
    if (allIdeas.isEmpty) {
      return null;
    }
    final randomIndex = _random.nextInt(allIdeas.length);
    return allIdeas[randomIndex];
  }

  String getRandomCoupon() {
    return loveCoupons[_random.nextInt(loveCoupons.length)];
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

  Future<bool> savePlanFromIdea(IdeaModel idea) async {
    if (isSavingPlan.value) return false;

    isSavingPlan.value = true;
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        SnackbarHelper.showSafe(
          title: 'Error',
          message: 'Please login to save plans',
        );
        return false;
      }

      // Calculate date: 5 days from now at 12:00 AM
      final now = DateTime.now();
      final planDate = DateTime(
        now.year,
        now.month,
        now.day,
      ).add(const Duration(days: 5));

      final planTime = DateTime(
        planDate.year,
        planDate.month,
        planDate.day,
        0, // 12:00 AM (midnight)
        0,
      );

      final planType = _getPlanTypeFromString(idea.category);

      final plan = PlanModel(
        id: const Uuid().v4(),
        title: idea.title,
        date: planDate,
        time: planTime,
        place: idea.location,
        type: planType,
      );

      // Save to local storage first
      await _storageService.savePlan(plan, userId: userId);

      // Save to Firebase in background
      _plansDbService.savePlan(userId: userId, plan: plan).catchError((_) {
        // Background save errors are handled silently
        return false;
      });

      // Schedule notification in background (don't await to avoid blocking)
      _schedulePlanNotification(plan);

      return true;
    } catch (e) {
      SnackbarHelper.showSafe(title: 'Error', message: 'Failed to save plan');
      return false;
    } finally {
      isSavingPlan.value = false;
    }
  }

  void _schedulePlanNotification(PlanModel plan) {
    final DateTime? planTime = plan.time;
    if (planTime == null) return;

    // Check if plan is in the future
    if (planTime.isBefore(DateTime.now())) {
      return;
    }

    // Schedule notification asynchronously in background
    Future<void> schedule() async {
      try {
        bool notificationsEnabled = true;
        bool planReminderEnabled = true;

        try {
          final settings = await _storageService.getSettings();
          notificationsEnabled = settings['notifications'] ?? true;
          planReminderEnabled = settings['planReminder'] ?? true;
        } catch (_) {
          // If settings can't be loaded, default to allowing notifications
        }

        if (notificationsEnabled && planReminderEnabled) {
          await _notificationService.ensureInitializedWithPermissions();
        }

        // Always save notification model for upcoming plans
        await _saveNotificationModel(plan, planTime);

        // Schedule multiple notifications if enabled
        if (notificationsEnabled && planReminderEnabled) {
          await _scheduleMultipleNotifications(plan, planTime);
        }
      } catch (e) {
        // Log error for debugging but don't block the main flow
        print('Error scheduling notification for plan ${plan.id}: $e');
      }
    }

    schedule();
  }

  /// Schedule multiple notifications at different intervals before the plan
  /// Dynamically determines which intervals to use based on time remaining until plan
  Future<void> _scheduleMultipleNotifications(
    PlanModel plan,
    DateTime planTime,
  ) async {
    final now = DateTime.now();
    final baseNotificationId = plan.id.hashCode & 0x7fffffff;

    // Calculate time remaining until the plan
    final timeRemaining = planTime.difference(now);

    // Define all possible notification intervals and messages
    final allIntervals = [
      const Duration(hours: 1),
      const Duration(minutes: 30),
      const Duration(minutes: 15),
      const Duration(minutes: 7),
      Duration.zero, // On time
    ];

    final allMessages = [
      '${plan.title} at ${plan.place} in 1 hour',
      '${plan.title} at ${plan.place} in 30 minutes',
      '${plan.title} at ${plan.place} in 15 minutes',
      '${plan.title} at ${plan.place} in 7 minutes',
      '${plan.title} at ${plan.place} is starting now!',
    ];

    // Dynamically determine which intervals to schedule based on time remaining
    final intervalsToSchedule = <int>[];
    
    if (timeRemaining >= const Duration(hours: 1)) {
      // If 1 hour or more remaining, schedule all reminders
      intervalsToSchedule.addAll([0, 1, 2, 3, 4]);
    } else if (timeRemaining >= const Duration(minutes: 30)) {
      // If 30 minutes or more remaining, schedule 30min, 15min, 7min, and on-time
      intervalsToSchedule.addAll([1, 2, 3, 4]);
    } else if (timeRemaining >= const Duration(minutes: 15)) {
      // If 15 minutes or more remaining, schedule 15min, 7min, and on-time
      intervalsToSchedule.addAll([2, 3, 4]);
    } else if (timeRemaining >= const Duration(minutes: 7)) {
      // If 7 minutes or more remaining, schedule 7min and on-time
      intervalsToSchedule.addAll([3, 4]);
    } else if (timeRemaining > Duration.zero) {
      // If less than 7 minutes but still in future, schedule only on-time
      intervalsToSchedule.add(4);
    }

    // Schedule notifications for selected intervals
    for (int i = 0; i < intervalsToSchedule.length; i++) {
      final intervalIndex = intervalsToSchedule[i];
      final interval = allIntervals[intervalIndex];
      final notificationTime = planTime.subtract(interval);

      // Double-check that notification time is in the future
      if (notificationTime.isAfter(now)) {
        // Use different notification IDs for each interval
        final notificationId = baseNotificationId + intervalIndex;

        try {
          await _notificationService.schedulePlanNotification(
            id: notificationId,
            title: 'Upcoming Plan',
            body: allMessages[intervalIndex],
            scheduledTime: notificationTime,
          );
          print(
            '✅ SURPRISE: Scheduled notification for plan ${plan.id} at ${notificationTime.toString()} (${allMessages[intervalIndex]})',
          );
        } catch (e) {
          print(
            '❌ SURPRISE: Error scheduling notification for plan ${plan.id}: $e',
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
            '💾 SURPRISE: Saving notification for plan ${plan.id}, userId: $userId',
          );
          await _storageService.saveNotification(notification, userId: userId);
          print('✅ SURPRISE: Notification saved successfully');

          // Update home screen notification count
          _updateHomeNotificationCount();
        } else {
          print('ℹ️ SURPRISE: Notification already exists for plan ${plan.id}');
        }
      } else {
        print(
          '⚠️ SURPRISE: Cannot save notification - userId is null or empty',
        );
      }
    } catch (e) {
      // Log error for debugging but don't block the main flow
      print('❌ SURPRISE: Error saving notification for plan ${plan.id}: $e');
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

  Future<bool> saveCouponToJournal(String coupon) async {
    if (isSavingJournal.value) return false;

    isSavingJournal.value = true;
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        SnackbarHelper.showSafe(
          title: 'Error',
          message: 'Please login to save journal entries',
        );
        return false;
      }

      // Use current date (the day the reward was claimed)
      final now = DateTime.now();
      final entryDate = DateTime(
        now.year,
        now.month,
        now.day,
        now.hour,
        now.minute,
      );

      final entry = JournalEntryModel(
        id: const Uuid().v4(),
        date: entryDate,
        note: '🎁 Lucky Love Coupon: $coupon',
      );

      // Save to local storage first
      await _storageService.saveJournalEntry(entry, userId: userId);

      // Save to Firebase in background
      _journalDbService
          .saveJournalEntry(userId: userId, entry: entry)
          .catchError((_) {
            // Background save errors are handled silently
            return false;
          });

      return true;
    } catch (e) {
      SnackbarHelper.showSafe(
        title: 'Error',
        message: 'Failed to save journal entry',
      );
      return false;
    } finally {
      isSavingJournal.value = false;
    }
  }
}
