import 'dart:async';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:love_connect/core/strings/home_strings.dart';
import 'package:love_connect/core/utils/snackbar_helper.dart';
import 'package:love_connect/core/services/auth/auth_service.dart';
import 'package:love_connect/core/services/local_storage_service.dart';
import 'package:love_connect/core/services/user_database_service.dart';
import 'package:love_connect/core/services/plans_database_service.dart';
import 'package:love_connect/core/services/notification_service.dart';
import 'package:love_connect/core/models/plan_model.dart';
import 'package:love_connect/core/models/notification_model.dart';
import 'package:love_connect/core/widgets/quote_modal.dart';
import 'package:love_connect/core/navigation/smooth_transitions.dart';
import 'package:love_connect/screens/auth/login/view/login_view.dart';
import 'package:love_connect/screens/add_plan/view/add_plan_view.dart';
import 'package:love_connect/screens/all_plans/view/all_plans_view.dart';
import 'package:love_connect/screens/journal/view/journal_view.dart';
import 'package:love_connect/screens/ideas/view/ideas_view.dart';
import 'package:love_connect/screens/notifications/view/notifications_view.dart';
import 'package:love_connect/screens/surprise/view/surprise_view.dart';
import 'package:love_connect/screens/home/model/home_model.dart';
import 'package:uuid/uuid.dart';

class HomeViewModel extends GetxController {
  final HomeModel model = const HomeModel();
  final RxInt selectedBottomNavIndex = 0.obs;
  final RxInt currentScreenIndex = 0.obs; // For IndexedStack navigation
  final RxInt notificationCount = 1.obs;
  final AuthService _authService = AuthService();
  final LocalStorageService _storageService = LocalStorageService();
  final UserDatabaseService _userDbService = UserDatabaseService();
  final PlansDatabaseService _plansDbService = PlansDatabaseService();
  final NotificationService _notificationService = NotificationService();
  final RxBool isLoggingOut = false.obs;
  final RxBool isLoadingPlans = false.obs;
  final RxList<PlanModel> plans = <PlanModel>[].obs;

  // Track navigation source: true = from navbar, false = from quick actions
  final RxMap<String, bool> navigationSource = <String, bool>{}.obs;

  // Track if Add Plan is open from navbar (to show as overlay)
  final RxBool isAddPlanOpenFromNavbar = false.obs;

  // Reactive user name and tagline
  final RxString userName = HomeStrings.userName.obs;
  final RxString userTagline = HomeStrings.userTagline.obs;
  final RxString profilePictureUrl = ''.obs;

  // Timer for periodic notification refresh
  Timer? _notificationRefreshTimer;

  @override
  void onInit() {
    super.onInit();
    loadUserInfo();
    _initializeUserData();
    loadPlans();
    loadNotifications();
    _startNotificationRefreshTimer();
  }

  @override
  void onClose() {
    _notificationRefreshTimer?.cancel();
    super.onClose();
  }

  /// Start periodic timer to refresh notification count
  void _startNotificationRefreshTimer() {
    // Refresh every 30 seconds to keep count updated
    _notificationRefreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => loadNotifications(),
    );
  }

  /// Initialize user data - set current user ID and clear old user data
  Future<void> _initializeUserData() async {
    final currentUserId = _authService.currentUserId;

    if (currentUserId != null) {
      // Get previous user ID (if any) BEFORE setting new one
      final previousUserId = await _storageService.getCurrentUserId();

      // If this is a different user, clear previous user's local data
      if (previousUserId != null && previousUserId != currentUserId) {
        print('');
        print('═══════════════════════════════════════════════════════════');
        print(
          '🔄 HOME: Different user detected - clearing previous user data...',
        );
        print('   Previous user: $previousUserId');
        print('   Current user: $currentUserId');
        await _storageService.clearUserData(previousUserId);
        await _storageService.clearAnonymousData();
        print('✅ HOME: Previous user data cleared');
        print('═══════════════════════════════════════════════════════════');
        print('');
      }

      // Clear anonymous data for any unauthenticated plans
      await _storageService.clearAnonymousData();

      // Set current user ID in local storage
      await _storageService.setCurrentUserId(currentUserId);
      print('✅ HOME: Current user ID set: $currentUserId');
    } else {
      // No user authenticated - clear any stored user ID and anonymous data
      await _storageService.setCurrentUserId(null);
      await _storageService.clearAnonymousData();
    }
  }

  Future<void> loadPlans() async {
    isLoadingPlans.value = true;
    try {
      final userId = _authService.currentUserId;
      print('');
      print('═══════════════════════════════════════════════════════════');
      print('📱 HOME: Loading plans...');
      print('👤 User ID: ${userId ?? "NOT AUTHENTICATED"}');

      List<PlanModel> loadedPlans = [];

      // CRITICAL: Only load plans if user is authenticated
      if (userId != null) {
        // Set current user ID in storage
        await _storageService.setCurrentUserId(userId);

        try {
          print('🔄 HOME: Loading plans from Firebase for user: $userId');
          loadedPlans = await _plansDbService.getPlans(userId);

          if (loadedPlans.isNotEmpty) {
            print('✅ HOME: Loaded ${loadedPlans.length} plan(s) from Firebase');

            // Sync ALL plans to user-specific local storage for offline access (before filtering)
            try {
              print(
                '💾 HOME: Syncing Firebase plans to user-specific local storage...',
              );
              for (var plan in loadedPlans) {
                await _storageService.savePlan(plan, userId: userId);
              }
              print('✅ HOME: Successfully synced to local storage');
            } catch (e) {
              print('⚠️ HOME: Failed to sync to local storage: $e');
              // Continue - this is not critical
            }

            // Filter to show only future plans (date >= today) for home page display
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);
            final futurePlans = loadedPlans.where((plan) {
              final planDate = DateTime(
                plan.date.year,
                plan.date.month,
                plan.date.day,
              );
              return planDate.isAfter(today) ||
                  planDate.isAtSameMomentAs(today);
            }).toList();
            // Sort by date, upcoming first
            futurePlans.sort((a, b) => a.date.compareTo(b.date));
            plans.value = futurePlans;

            // Schedule notifications for all upcoming plans
            _scheduleNotificationsForPlans(futurePlans);

            print(
              '═══════════════════════════════════════════════════════════',
            );
            print('');
            return;
          } else {
            print('📭 HOME: No plans found in Firebase for user: $userId');

            // Check for user-specific local plans (only for this user)
            final localPlans = await _storageService.getPlans(userId: userId);
            if (localPlans.isNotEmpty) {
              print(
                '📦 HOME: Found ${localPlans.length} local plan(s) for this user - migrating to Firebase...',
              );

              // Migrate local plans to Firebase (one-time migration)
              for (var plan in localPlans) {
                final saved = await _plansDbService.savePlan(
                  userId: userId,
                  plan: plan,
                );
                if (saved) {
                  print('✅ HOME: Migrated plan: ${plan.title}');
                } else {
                  print('❌ HOME: Failed to migrate plan: ${plan.title}');
                }
              }

              // Reload from Firebase after migration
              loadedPlans = await _plansDbService.getPlans(userId);
            }

            // Filter to show only future plans (date >= today)
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);
            loadedPlans = loadedPlans.where((plan) {
              final planDate = DateTime(
                plan.date.year,
                plan.date.month,
                plan.date.day,
              );
              return planDate.isAfter(today) ||
                  planDate.isAtSameMomentAs(today);
            }).toList();
            // Sort by date, upcoming first
            loadedPlans.sort((a, b) => a.date.compareTo(b.date));
            plans.value = loadedPlans;

            // Schedule notifications for all upcoming plans
            _scheduleNotificationsForPlans(loadedPlans);

            if (loadedPlans.isEmpty) {
              print('📭 HOME: No plans found for this user');
            }
          }
        } catch (e) {
          print('❌ HOME: Error loading from Firebase: $e');

          // Fallback to user-specific local storage only
          print('🔄 HOME: Falling back to user-specific local storage...');
          try {
            final localPlans = await _storageService.getPlans(userId: userId);
            // Filter to show only future plans (date >= today)
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);
            final filteredPlans = localPlans.where((plan) {
              final planDate = DateTime(
                plan.date.year,
                plan.date.month,
                plan.date.day,
              );
              return planDate.isAfter(today) ||
                  planDate.isAtSameMomentAs(today);
            }).toList();
            filteredPlans.sort((a, b) => a.date.compareTo(b.date));
            plans.value = filteredPlans;

            // Schedule notifications for all upcoming plans
            _scheduleNotificationsForPlans(filteredPlans);

            print(
              '✅ HOME: Loaded ${localPlans.length} plan(s) from user-specific local storage',
            );
          } catch (localError) {
            print('❌ HOME: Failed to load from local storage: $localError');
            plans.value = [];
          }
        }
      } else {
        // No user authenticated - show empty plans (don't load from local storage)
        print('⚠️ HOME: No user authenticated - showing empty plans');
        plans.value = [];
        await _storageService.setCurrentUserId(null);
      }

      print('═══════════════════════════════════════════════════════════');
      print('');
    } catch (e) {
      print('❌ HOME: Critical error in loadPlans: $e');
      print('═══════════════════════════════════════════════════════════');
      print('');

      // Set empty plans on error
      plans.value = [];
    } finally {
      isLoadingPlans.value = false;
    }
  }

  /// Schedule notifications for all upcoming plans
  Future<void> _scheduleNotificationsForPlans(List<PlanModel> plansList) async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null || userId.isEmpty) {
        print('⚠️ HOME: Cannot create notifications - userId is null or empty');
        return;
      }

      // Check if notifications are enabled
      bool notificationsEnabled = true;
      bool planReminderEnabled = true;
      try {
        final settings = await _storageService.getSettings();
        notificationsEnabled = settings['notifications'] ?? true;
        planReminderEnabled = settings['planReminder'] ?? true;
      } catch (_) {
        // If settings can't be loaded, default to allowing notifications
      }

      // Initialize notification service if notifications are enabled
      if (notificationsEnabled && planReminderEnabled) {
        await _notificationService.ensureInitializedWithPermissions();
      }

      // Get existing notifications to avoid duplicates
      final existingNotifications = await _storageService.getNotifications(
        userId: userId,
      );
      final existingNotificationKeys = existingNotifications
          .where((n) => n.type == NotificationType.reminder)
          .map((n) => '${n.message}_${n.date.toIso8601String()}')
          .toSet();

      final now = DateTime.now();
      int scheduledCount = 0;
      int savedCount = 0;

      for (final plan in plansList) {
        if (plan.time == null) continue;

        // Only process plans that are in the future
        if (plan.time!.isBefore(now)) {
          continue;
        }

        // Always save notification model for upcoming plans
        final notificationMessage = '${plan.title} at ${plan.place}';
        final notificationKey =
            '${notificationMessage}_${plan.time!.toIso8601String()}';

        if (!existingNotificationKeys.contains(notificationKey)) {
          try {
            final notification = NotificationModel(
              id: const Uuid().v4(),
              title: 'Upcoming Plan',
              message: notificationMessage,
              date: plan.time!,
              type: NotificationType.reminder,
            );

            await _storageService.saveNotification(
              notification,
              userId: userId,
            );
            savedCount++;
            print('💾 HOME: Created notification for plan: ${plan.title}');
          } catch (e) {
            print('❌ HOME: Error saving notification for plan ${plan.id}: $e');
          }
        }

        // Schedule multiple notifications if enabled
        if (notificationsEnabled && planReminderEnabled) {
          final scheduled = await _scheduleMultipleNotificationsForPlan(
            plan,
            plan.time!,
            now,
          );
          scheduledCount += scheduled;
        }
      }

      if (scheduledCount > 0 || savedCount > 0) {
        print(
          '✅ HOME: Scheduled $scheduledCount notification(s), saved $savedCount notification(s) to storage',
        );
        // Update notification count
        await loadNotifications();
      }
    } catch (e) {
      // Handle errors silently - notifications are not critical
      print('❌ HOME: Error scheduling plan notifications: $e');
    }
  }

  /// Schedule multiple notifications at different intervals before the plan
  /// Dynamically determines which intervals to use based on time remaining until plan
  Future<int> _scheduleMultipleNotificationsForPlan(
    PlanModel plan,
    DateTime planTime,
    DateTime now,
  ) async {
    final baseNotificationId = plan.id.hashCode & 0x7fffffff;
    int scheduledCount = 0;

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
          scheduledCount++;
          print(
            '✅ HOME: Scheduled notification for plan ${plan.id} at ${notificationTime.toString()} (${allMessages[intervalIndex]})',
          );
        } catch (e) {
          print(
            '❌ HOME: Error scheduling notification for plan ${plan.id}: $e',
          );
        }
      }
    }

    return scheduledCount;
  }

  /// Load and update notification count
  /// This method can be called from anywhere to refresh the notification count
  Future<void> loadNotifications() async {
    try {
      final userId = _authService.currentUserId;
      final notifications = await _storageService.getNotifications(
        userId: userId,
      );
      final unreadCount = notifications.where((n) => !n.isRead).length;
      notificationCount.value = unreadCount;
    } catch (e) {
      // Handle error silently
    }
  }

  /// Load user information from Firebase Auth and user profile
  Future<void> loadUserInfo() async {
    final user = _authService.currentUser;
    if (user == null) return;

    await _reloadUserData();

    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    final userId = currentUser.uid;
    final name = _extractUserName(currentUser);
    userName.value = name.isNotEmpty ? name : HomeStrings.userName;

    // Load user profile from Firebase first, then local storage
    try {
      final firebaseProfile = await _userDbService.getUserProfile(userId);

      if (firebaseProfile != null) {
        userTagline.value =
            firebaseProfile['about'] as String? ?? HomeStrings.userTagline;
        profilePictureUrl.value =
            firebaseProfile['profilePictureUrl'] as String? ??
            currentUser.photoURL ??
            '';
      } else {
        // Fallback to local storage
        final profile = await _storageService.getUserProfile();
        userTagline.value = profile.about.isNotEmpty
            ? profile.about
            : HomeStrings.userTagline;
        profilePictureUrl.value =
            profile.profilePictureUrl ?? currentUser.photoURL ?? '';
      }

      // If still no profile picture, use Google photo URL
      if (profilePictureUrl.value.isEmpty) {
        profilePictureUrl.value = currentUser.photoURL ?? '';
      }
    } catch (e) {
      // If profile loading fails, use default tagline and Google photo
      userTagline.value = HomeStrings.userTagline;
      profilePictureUrl.value = currentUser.photoURL ?? '';
    }
  }

  /// Reload user data to ensure we have the latest information
  Future<void> _reloadUserData() async {
    try {
      await _authService.reloadUser();
    } catch (e) {
      // If reload fails, continue with current user data
    }
  }

  /// Extract user name from Firebase user
  String _extractUserName(User user) {
    final displayName = user.displayName ?? '';
    if (displayName.isNotEmpty) return displayName;

    if (user.email == null) return '';

    return _formatEmailName(user.email!);
  }

  /// Format email name by extracting and capitalizing
  String _formatEmailName(String email) {
    final emailName = email.split('@')[0];
    final normalized = emailName
        .replaceAll('.', ' ')
        .replaceAll('_', ' ')
        .replaceAll('-', ' ');

    if (normalized.isEmpty) return '';

    final words = normalized.split(' ').map(_capitalizeWord).toList();
    return words.join(' ');
  }

  /// Capitalize first letter of a word
  String _capitalizeWord(String word) {
    if (word.isEmpty) return word;
    if (word.length == 1) return word.toUpperCase();
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }

  /// Logout user and navigate to login screen
  /// After logout, user goes to login (not get started) since they've already seen it
  Future<void> logout() async {
    if (isLoggingOut.value) return;

    isLoggingOut.value = true;
    HapticFeedback.lightImpact();

    try {
      final currentUserId = _authService.currentUserId;

      // Clear current user ID and anonymous data from storage
      if (currentUserId != null) {
        await _storageService.clearUserData(currentUserId);
      }
      await _storageService.clearAnonymousData();
      await _storageService.setCurrentUserId(null);

      // Sign out from Firebase and Google
      await _authService.signOut();

      // After logout, always go to login screen (not get started)
      // because user has already seen get started screen before
      await SmoothNavigator.offAll(
        () => const LoginView(),
        transition: Transition.fadeIn,
        duration: SmoothNavigator.slowDuration,
      );
    } catch (e) {
      SnackbarHelper.showSafe(
        title: 'Logout Failed',
        message: 'An error occurred during logout. Please try again.',
      );
    } finally {
      isLoggingOut.value = false;
    }
  }

  void onQuickActionTap(QuickActionModel action) {
    HapticFeedback.lightImpact();
    switch (action.title) {
      case HomeStrings.newPlan:
        // Navigate with Get.to() to show back arrow and hide bottom navbar
        navigationSource['addPlan'] = false; // from quick actions
        Get.to(() => const AddPlanView())?.then((result) {
          if (result == true) {
            loadPlans();
          }
        });
        break;
      case HomeStrings.journal:
        // Navigate with Get.to() to show back arrow and hide bottom navbar
        navigationSource['journal'] = false; // from quick actions
        Get.to(() => const JournalView());
        break;
      case HomeStrings.ideas:
        Get.to(() => const IdeasView());
        break;
      case HomeStrings.surprise:
        // Navigate to Surprise Hub screen
        Get.to(() => const SurpriseView())?.then((_) {
          // Reload plans when returning from surprise screen
          loadPlans();
        });
        break;
      case HomeStrings.quote:
        QuoteModal.show();
        break;
      case HomeStrings.viewAllPlans:
        // Navigate to All Plans screen
        onViewAllPlansTap();
        break;
      default:
        SnackbarHelper.showSafe(
          title: action.title,
          message: 'Feature coming soon!',
        );
    }
  }

  void onAddPlanTap({bool fromNavbar = false}) {
    HapticFeedback.lightImpact();
    if (fromNavbar) {
      // From navbar: show as modal overlay to keep bottom navbar visible
      navigationSource['addPlan'] = true; // from navbar
      Get.to(() => const AddPlanView())?.then((result) {
        if (result == true) {
          loadPlans();
        }
      });
    } else {
      // From quick actions or other places: normal navigation
      navigationSource['addPlan'] = false;
      Get.to(() => const AddPlanView())?.then((result) {
        if (result == true) {
          loadPlans();
        }
      });
    }
  }

  void onViewAllPlansTap() {
    HapticFeedback.lightImpact();
    Get.to(() => const AllPlansView())?.then((_) {
      // Reload plans when returning from All Plans screen
      loadPlans();
    });
  }

  void editPlan(PlanModel plan) {
    HapticFeedback.lightImpact();
    Get.to(() => AddPlanView(planId: plan.id))?.then((result) {
      if (result == true) {
        loadPlans();
      }
    });
  }

  Future<void> deletePlan(String planId) async {
    HapticFeedback.lightImpact();
    try {
      final userId = _authService.currentUserId;

      if (userId == null) {
        SnackbarHelper.showSafe(
          title: 'Error',
          message: 'User not authenticated',
        );
        return;
      }

      // Delete from Firebase
      await _plansDbService.deletePlan(userId: userId, planId: planId);

      // Also delete from user-specific local storage
      try {
        await _storageService.deletePlan(planId, userId: userId);
      } catch (e) {
        print('Failed to delete plan from local storage: $e');
      }

      // Reload plans
      await loadPlans();

      SnackbarHelper.showSafe(
        title: 'Plan Deleted',
        message: 'Plan has been deleted successfully',
      );
    } catch (e) {
      SnackbarHelper.showSafe(title: 'Error', message: 'Failed to delete plan');
    }
  }

  void onSearchTap() {
    HapticFeedback.lightImpact();
    SnackbarHelper.showSafe(
      title: HomeStrings.search,
      message: 'Search feature coming soon!',
    );
  }

  void onNotificationTap() {
    HapticFeedback.lightImpact();
    Get.to(() => const NotificationsView())?.then((_) {
      // Reload notifications when returning from notifications screen
      loadNotifications();
    });
  }

  void onProfileTap() {
    HapticFeedback.lightImpact();
    // Navigate to profile screen via navbar
    navigationSource['profile'] = true;
    selectedBottomNavIndex.value = 3;
    currentScreenIndex.value = 2; // Profile is index 2 in IndexedStack
  }

  void onBottomNavTap(int index) {
    HapticFeedback.lightImpact();

    // Handle navigation based on index
    switch (index) {
      case 0:
        // Home screen
        // If already on home and Add Plan is not open, do nothing
        if (selectedBottomNavIndex.value == index &&
            currentScreenIndex.value == 0 &&
            !isAddPlanOpenFromNavbar.value) {
          return;
        }
        // Close Add Plan overlay if open
        if (isAddPlanOpenFromNavbar.value) {
          isAddPlanOpenFromNavbar.value = false;
        }
        selectedBottomNavIndex.value = index;
        currentScreenIndex.value = 0;
        // Reload plans and user info when switching back to home
        loadPlans();
        loadUserInfo(); // Reload user info to get updated tagline
        break;
      case 1:
        // Add Plan - show as overlay to keep bottom navbar visible
        // Toggle overlay if already open, otherwise open it
        if (isAddPlanOpenFromNavbar.value) {
          // If already open, close it and return to home
          isAddPlanOpenFromNavbar.value = false;
          selectedBottomNavIndex.value = 0; // Return to home selection
        } else {
          // Close any other overlays and open Add Plan
          navigationSource['addPlan'] = true;
          isAddPlanOpenFromNavbar.value = true;
          selectedBottomNavIndex.value = index; // Highlight the add plan icon
        }
        break;
      case 2:
        // Journal screen - navigate via IndexedStack
        // If already on journal, do nothing
        if (selectedBottomNavIndex.value == index &&
            currentScreenIndex.value == 1 &&
            !isAddPlanOpenFromNavbar.value) {
          return;
        }
        // Close Add Plan overlay if open
        if (isAddPlanOpenFromNavbar.value) {
          isAddPlanOpenFromNavbar.value = false;
        }
        navigationSource['journal'] = true; // from navbar
        selectedBottomNavIndex.value = index;
        currentScreenIndex.value = 1; // Journal is index 1 in IndexedStack
        break;
      case 3:
        // Profile/Settings screen - navigate via IndexedStack
        // If already on profile, do nothing
        if (selectedBottomNavIndex.value == index &&
            currentScreenIndex.value == 2 &&
            !isAddPlanOpenFromNavbar.value) {
          return;
        }
        // Close Add Plan overlay if open
        if (isAddPlanOpenFromNavbar.value) {
          isAddPlanOpenFromNavbar.value = false;
        }
        navigationSource['profile'] = true; // from navbar
        selectedBottomNavIndex.value = index;
        currentScreenIndex.value = 2; // Profile is index 2 in IndexedStack
        break;
    }
  }

  // Check if navigation came from navbar (true) or quick actions (false)
  // For screens in IndexedStack (profile, journal), default to true (navbar)
  // For other screens (addPlan), default to false (not from navbar)
  bool isFromNavbar(String screen) {
    if (navigationSource.containsKey(screen)) {
      return navigationSource[screen]!;
    }
    // Default behavior: screens in IndexedStack (profile, journal) are from navbar
    // Other screens (addPlan) are not from navbar by default
    return screen == 'profile' || screen == 'journal';
  }

  List<QuickActionModel> get quickActions => [
    const QuickActionModel(
      title: HomeStrings.newPlan,
      iconPath: 'assets/svg/newplan.svg',
    ),
    const QuickActionModel(
      title: HomeStrings.journal,
      iconPath: 'assets/svg/journal.svg',
    ),
    const QuickActionModel(
      title: HomeStrings.ideas,
      iconPath: 'assets/svg/ideas.svg',
    ),
    const QuickActionModel(
      title: HomeStrings.surprise,
      iconPath: 'assets/svg/surprise.svg',
    ),
    const QuickActionModel(
      title: HomeStrings.quote,
      iconPath: 'assets/svg/quote.svg',
    ),
    const QuickActionModel(
      title: HomeStrings.viewAllPlans,
      iconPath: 'assets/svg/newplan.svg',
    ),
  ];

  List<BottomNavItem> get bottomNavItems => [
    const BottomNavItem(
      label: HomeStrings.home,
      iconPath: 'assets/svg/home.svg',
      index: 0,
    ),
    const BottomNavItem(
      label: HomeStrings.addPlanNav,
      iconPath: 'assets/svg/newplan.svg',
      index: 1,
    ),
    const BottomNavItem(
      label: HomeStrings.journalNav,
      iconPath: 'assets/svg/journal.svg',
      index: 2,
    ),
    const BottomNavItem(
      label: HomeStrings.profileNav,
      iconPath: 'assets/svg/profile_set.svg',
      index: 3,
    ),
  ];
}
