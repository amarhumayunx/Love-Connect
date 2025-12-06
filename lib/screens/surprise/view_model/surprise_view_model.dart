import 'dart:math';
import 'package:get/get.dart';
import 'package:love_connect/core/models/idea_model.dart';
import 'package:love_connect/core/models/plan_model.dart';
import 'package:love_connect/core/models/journal_entry_model.dart';
import 'package:love_connect/core/services/quotes_service.dart';
import 'package:love_connect/core/services/auth/auth_service.dart';
import 'package:love_connect/core/services/local_storage_service.dart';
import 'package:love_connect/core/services/plans_database_service.dart';
import 'package:love_connect/core/services/journal_database_service.dart';
import 'package:love_connect/core/services/notification_service.dart';
import 'package:love_connect/screens/surprise/model/surprise_model.dart';
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
    allIdeas.value = _quotesService.getAllIdeas();
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
      SnackbarHelper.showSafe(
        title: 'Error',
        message: 'Failed to save plan',
      );
      return false;
    } finally {
      isSavingPlan.value = false;
    }
  }

  void _schedulePlanNotification(PlanModel plan) {
    final DateTime? planTime = plan.time;
    if (planTime == null) return;

    // Schedule notification asynchronously in background
    Future<void> schedule() async {
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
    }

    schedule().catchError((_) {
      // Notification scheduling errors are handled silently
    });
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
      _journalDbService.saveJournalEntry(userId: userId, entry: entry).catchError((_) {
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

