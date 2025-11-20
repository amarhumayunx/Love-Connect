import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:love_connect/core/strings/home_strings.dart';
import 'package:love_connect/core/utils/snackbar_helper.dart';
import 'package:love_connect/core/services/auth/auth_service.dart';
import 'package:love_connect/core/services/app_preferences_service.dart';
import 'package:love_connect/core/navigation/smooth_transitions.dart';
import 'package:love_connect/screens/auth/login/view/login_view.dart';
import 'package:love_connect/screens/home/model/home_model.dart';

class HomeViewModel extends GetxController {
  final HomeModel model = const HomeModel();
  final RxInt selectedBottomNavIndex = 0.obs;
  final RxInt notificationCount = 1.obs;
  final AuthService _authService = AuthService();
  final AppPreferencesService _prefsService = AppPreferencesService();
  final RxBool isLoggingOut = false.obs;
  
  // Reactive user name and tagline
  final RxString userName = HomeStrings.userName.obs;
  final RxString userTagline = HomeStrings.userTagline.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserInfo();
  }

  /// Load user information from Firebase Auth
  Future<void> _loadUserInfo() async {
    final user = _authService.currentUser;
    if (user != null) {
      // Reload user data to ensure we have the latest information
      try {
        await _authService.reloadUser();
      } catch (e) {
        // If reload fails, continue with current user data
      }
      
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        // Get display name, or fallback to email username, or default
        String name = currentUser.displayName ?? '';
        
        if (name.isEmpty && currentUser.email != null) {
          // Extract name from email (part before @)
          String emailName = currentUser.email!.split('@')[0];
          
          // Remove dots and replace with spaces, then capitalize each word
          emailName = emailName.replaceAll('.', ' ');
          emailName = emailName.replaceAll('_', ' ');
          emailName = emailName.replaceAll('-', ' ');
          
          // Capitalize first letter of each word
          if (emailName.isNotEmpty) {
            List<String> words = emailName.split(' ');
            words = words.map((word) {
              if (word.isEmpty) return word;
              return word[0].toUpperCase() + 
                     (word.length > 1 ? word.substring(1).toLowerCase() : '');
            }).toList();
            name = words.join(' ');
          }
        }
        
        // If still empty, use default
        if (name.isEmpty) {
          name = HomeStrings.userName;
        }
        
        userName.value = name;
        
        // Keep the tagline as default for now, or you can customize it
        userTagline.value = HomeStrings.userTagline;
      }
    }
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
    SnackbarHelper.showSafe(
      title: action.title,
      message: 'Feature coming soon!',
    );
  }

  void onAddPlanTap() {
    HapticFeedback.lightImpact();
    SnackbarHelper.showSafe(
      title: HomeStrings.addPlan,
      message: 'Add plan feature coming soon!',
    );
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
    notificationCount.value = 0;
    SnackbarHelper.showSafe(
      title: HomeStrings.notifications,
      message: 'No new notifications',
    );
  }

  void onBottomNavTap(int index) {
    if (selectedBottomNavIndex.value == index) return;
    HapticFeedback.lightImpact();
    selectedBottomNavIndex.value = index;
    
    // Handle navigation based on index
    switch (index) {
      case 0:
        // Already on home
        break;
      case 1:
        onAddPlanTap();
        break;
      case 2:
        SnackbarHelper.showSafe(
          title: HomeStrings.journalNav,
          message: 'Journal feature coming soon!',
        );
        break;
      case 3:
        // Show logout dialog
        _showLogoutDialog();
        break;
    }
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          Obx(
            () => TextButton(
              onPressed: isLoggingOut.value ? null : logout,
              child: isLoggingOut.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Logout'),
            ),
          ),
        ],
      ),
      barrierDismissible: !isLoggingOut.value,
    );
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
          label: HomeStrings.settingsNav,
          iconPath: 'assets/svg/profile_set.svg',
          index: 3,
        ),
      ];
}

