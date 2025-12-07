import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/screens/add_plan/view/add_plan_view.dart';
import 'package:love_connect/screens/home/view/home_view.dart';
import 'package:love_connect/screens/home/view/widgets/home_bottom_nav.dart';
import 'package:love_connect/screens/home/view/widgets/home_layout_metrics.dart';
import 'package:love_connect/screens/home/view_model/home_view_model.dart';
import 'package:love_connect/screens/journal/view/journal_view.dart';
import 'package:love_connect/screens/profile/view/profile_view.dart';

class MainNavigationView extends StatelessWidget {
  const MainNavigationView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Get.put(HomeViewModel());
    final metrics = HomeLayoutMetrics.fromContext(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppColors.backgroundPink,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        // Main content
        body: SafeArea(
          child: Stack(
            children: [
              Obx(
                () => IndexedStack(
                  index: viewModel.currentScreenIndex.value,
                  children: const [HomeView(), JournalView(), ProfileView()],
                ),
              ),

              // Add Plan overlay above everything
              Obx(
                () => viewModel.isAddPlanOpenFromNavbar.value
                    ? Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: PopScope(
                          canPop: false,
                          onPopInvokedWithResult: (didPop, result) {
                            if (!didPop) {
                              viewModel.isAddPlanOpenFromNavbar.value = false;
                            }
                          },
                          child: Container(
                            color: AppColors.backgroundPink,
                            child: SafeArea(
                              bottom: true,
                              child: AddPlanView(
                                key: const ValueKey('addPlanOverlay'),
                                onClose: () {
                                  viewModel.isAddPlanOpenFromNavbar.value =
                                      false;
                                  viewModel.selectedBottomNavIndex.value =
                                      0; // Return to home selection
                                  viewModel.loadPlans();
                                },
                              ),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),

        // Bottom Navigation
        bottomNavigationBar: HomeBottomNav(
          viewModel: viewModel,
          metrics: metrics,
        ),
      ),
    );
  }
}
