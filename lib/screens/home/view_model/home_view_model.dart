import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:love_connect/core/strings/home_strings.dart';
import 'package:love_connect/core/utils/snackbar_helper.dart';
import 'package:love_connect/screens/home/model/home_model.dart';

class HomeViewModel extends GetxController {
  final HomeModel model = const HomeModel();
  final RxInt selectedBottomNavIndex = 0.obs;
  final RxInt notificationCount = 1.obs;

  @override
  void onInit() {
    super.onInit();
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
        SnackbarHelper.showSafe(
          title: HomeStrings.settingsNav,
          message: 'Settings feature coming soon!',
        );
        break;
    }
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

