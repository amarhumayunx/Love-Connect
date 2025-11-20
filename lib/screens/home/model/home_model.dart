import 'package:love_connect/core/strings/home_strings.dart';

class QuickActionModel {
  final String title;
  final String iconPath;

  const QuickActionModel({
    required this.title,
    required this.iconPath,
  });
}

class BottomNavItem {
  final String label;
  final String iconPath;
  final int index;

  const BottomNavItem({
    required this.label,
    required this.iconPath,
    required this.index,
  });
}

class HomeModel {
  final String userName;
  final String userTagline;
  final String upcomingPlansTitle;
  final String quickActionsTitle;
  final String noPlansMessage;
  final String addPlanButtonText;
  final List<QuickActionModel> quickActions;
  final List<BottomNavItem> bottomNavItems;

  const HomeModel({
    this.userName = HomeStrings.userName,
    this.userTagline = HomeStrings.userTagline,
    this.upcomingPlansTitle = HomeStrings.upcomingPlans,
    this.quickActionsTitle = HomeStrings.quickActions,
    this.noPlansMessage = HomeStrings.noPlansMessage,
    this.addPlanButtonText = HomeStrings.addPlan,
    this.quickActions = const [],
    this.bottomNavItems = const [],
  });
}

