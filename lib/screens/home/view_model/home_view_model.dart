import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:love_connect/core/strings/home_strings.dart';
import 'package:love_connect/core/utils/snackbar_helper.dart';
import 'package:love_connect/core/services/auth/auth_service.dart';
import 'package:love_connect/core/services/local_storage_service.dart';
import 'package:love_connect/core/services/plans_database_service.dart';
import 'package:love_connect/core/models/plan_model.dart';
import 'package:love_connect/core/widgets/quote_modal.dart';
import 'package:love_connect/core/navigation/smooth_transitions.dart';
import 'package:love_connect/screens/auth/login/view/login_view.dart';
import 'package:love_connect/screens/add_plan/view/add_plan_view.dart';
import 'package:love_connect/screens/journal/view/journal_view.dart';
import 'package:love_connect/screens/ideas/view/ideas_view.dart';
import 'package:love_connect/screens/profile/view/profile_view.dart';
import 'package:love_connect/screens/notifications/view/notifications_view.dart';
import 'package:love_connect/screens/home/model/home_model.dart';

class HomeViewModel extends GetxController {
  final HomeModel model = const HomeModel();
  final RxInt selectedBottomNavIndex = 0.obs;
  final RxInt currentScreenIndex = 0.obs; // For IndexedStack navigation
  final RxInt notificationCount = 1.obs;
  final AuthService _authService = AuthService();
  final LocalStorageService _storageService = LocalStorageService();
  final PlansDatabaseService _plansDbService = PlansDatabaseService();
  final RxBool isLoggingOut = false.obs;
  final RxList<PlanModel> plans = <PlanModel>[].obs;
  
  // Track navigation source: true = from navbar, false = from quick actions
  final RxMap<String, bool> navigationSource = <String, bool>{}.obs;
  
  // Track if Add Plan is open from navbar (to show as overlay)
  final RxBool isAddPlanOpenFromNavbar = false.obs;
  
  // Reactive user name and tagline
  final RxString userName = HomeStrings.userName.obs;
  final RxString userTagline = HomeStrings.userTagline.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserInfo();
    loadPlans();
    loadNotifications();
  }

  Future<void> loadPlans() async {
    try {
      final userId = _authService.currentUserId;
      List<PlanModel> loadedPlans = [];

      // Try to load from Firebase if user is authenticated
      if (userId != null) {
        try {
          loadedPlans = await _plansDbService.getPlans(userId);
          // If Firebase returned plans, use them
          if (loadedPlans.isNotEmpty) {
            // Sort by date, upcoming first
            loadedPlans.sort((a, b) => a.date.compareTo(b.date));
            plans.value = loadedPlans;
            return;
          }
        } catch (e) {
          print('Failed to load plans from Firebase: $e');
          // Continue to try local storage as fallback
        }

        // If no plans from Firebase, check local storage and migrate if needed
        final localPlans = await _storageService.getPlans();
        if (localPlans.isNotEmpty) {
          // Migrate local plans to Firebase
          await _migrateLocalPlansToFirebase(userId, localPlans);
          loadedPlans = localPlans;
        }
      } else {
        // No user authenticated, load from local storage
        loadedPlans = await _storageService.getPlans();
      }

      // Sort by date, upcoming first
      loadedPlans.sort((a, b) => a.date.compareTo(b.date));
      plans.value = loadedPlans;
    } catch (e) {
      print('Error loading plans: $e');
      // Handle error silently or show snackbar
      try {
        // Last resort: try local storage
        final localPlans = await _storageService.getPlans();
        localPlans.sort((a, b) => a.date.compareTo(b.date));
        plans.value = localPlans;
      } catch (localError) {
        print('Failed to load plans from local storage: $localError');
      }
    }
  }

  /// Migrate local plans to Firebase when user logs in
  Future<void> _migrateLocalPlansToFirebase(String userId, List<PlanModel> localPlans) async {
    try {
      // Check if Firebase already has plans
      final firebasePlans = await _plansDbService.getPlans(userId);
      if (firebasePlans.isEmpty) {
        // No plans in Firebase, migrate all local plans
        for (var plan in localPlans) {
          await _plansDbService.savePlan(userId: userId, plan: plan);
        }
        print('Migrated ${localPlans.length} plans from local storage to Firebase');
      }
    } catch (e) {
      print('Failed to migrate plans to Firebase: $e');
      // Don't throw - migration failure shouldn't block app usage
    }
  }

  Future<void> loadNotifications() async {
    try {
      final notifications = await _storageService.getNotifications();
      final unreadCount = notifications.where((n) => !n.isRead).length;
      notificationCount.value = unreadCount;
    } catch (e) {
      // Handle error silently
    }
  }

  /// Load user information from Firebase Auth
  Future<void> _loadUserInfo() async {
    final user = _authService.currentUser;
    if (user == null) return;
    
    await _reloadUserData();
    
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;
    
    final name = _extractUserName(currentUser);
    userName.value = name.isNotEmpty ? name : HomeStrings.userName;
    userTagline.value = HomeStrings.userTagline;
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
        // Navigate with Get.to() to show back arrow and hide bottom navbar
        navigationSource['addPlan'] = false; // from quick actions
        Get.to(() => const AddPlanView())?.then((result) {
          if (result == true) {
            loadPlans();
          }
        });
        break;
      case HomeStrings.quote:
        QuoteModal.show();
        break;
      case HomeStrings.settings:
        // Navigate with Get.to() to show back arrow and hide bottom navbar
        navigationSource['profile'] = false; // from quick actions
        Get.to(() => const ProfileView());
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

      // Delete from Firebase if user is authenticated
      if (userId != null) {
        await _plansDbService.deletePlan(
          userId: userId,
          planId: planId,
        );
      }

      // Also delete from local storage
      try {
        await _storageService.deletePlan(planId);
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
      SnackbarHelper.showSafe(
        title: 'Error',
        message: 'Failed to delete plan',
      );
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
        // Reload plans when switching back to home
        loadPlans();
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
          title: HomeStrings.settings,
          iconPath: 'assets/svg/setting.svg',
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

