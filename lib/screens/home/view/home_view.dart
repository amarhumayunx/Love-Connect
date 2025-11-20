import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/core/utils/snackbar_helper.dart';
import 'package:love_connect/screens/home/view/widgets/home_bottom_nav.dart';
import 'package:love_connect/screens/home/view/widgets/home_header.dart';
import 'package:love_connect/screens/home/view/widgets/home_layout_metrics.dart';
import 'package:love_connect/screens/home/view/widgets/quick_action_card.dart';
import 'package:love_connect/screens/home/view/widgets/upcoming_plans_card.dart';
import 'package:love_connect/screens/home/view_model/home_view_model.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  late final HomeViewModel viewModel;
  late final AnimationController _fadeController;
  late final AnimationController _slideController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  DateTime? _lastBackPressTime;

  @override
  void initState() {
    super.initState();
    viewModel = Get.put(HomeViewModel());

    // Fade animation for overall content
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Slide animation for sections
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    Get.delete<HomeViewModel>();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      SnackbarHelper.showSafe(
        title: 'Press back again to exit',
        message: '',
        duration: const Duration(seconds: 2),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final metrics = HomeLayoutMetrics.fromContext(context);

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) return;
        _onWillPop().then((shouldPop) {
          if (shouldPop && mounted) {
            SystemNavigator.pop();
          }
        });
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundPink,
        body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [

            SizedBox(height: 8,),
            // Header
            Obx(
              () => HomeHeader(
                userName: viewModel.userName.value,
                userTagline: viewModel.userTagline.value,
                onSearchTap: viewModel.onSearchTap,
                onNotificationTap: viewModel.onNotificationTap,
                notificationCount: viewModel.notificationCount.value,
                metrics: metrics,
              ),
            ),
            SizedBox(height: 4,),

            Center(
              child: Container(
                width: 290,         // Divider width
                height: 1,          // Thickness
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      AppColors.accentPeach,
                      AppColors.primaryRed,
                      AppColors.accentPeach,
                    ],
                    stops: [0.0, 0.5, 1.0], // midpoint darkest
                  ),
                ),
              ),
            ),

            SizedBox(height: 4,),

            // Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Upcoming Plans Section
                      Padding(
                        padding: EdgeInsets.only(
                          left: metrics.cardPadding,
                          right: metrics.cardPadding,
                          top: metrics.sectionSpacing * 0.5,
                          bottom: metrics.sectionSpacing * 0.2,
                        ),
                        child: Text(
                          viewModel.model.upcomingPlansTitle,
                          style: GoogleFonts.inter(
                            fontSize: metrics.sectionTitleFontSize,
                            fontWeight: FontWeight.normal,
                            color: AppColors.textDarkPink,
                          ),
                        ),
                      ),
                      UpcomingPlansCard(
                        message: viewModel.model.noPlansMessage,
                        buttonText: viewModel.model.addPlanButtonText,
                        onAddTap: viewModel.onAddPlanTap,
                        metrics: metrics,
                      ),

                      // Quick Actions Section
                      Padding(
                        padding: EdgeInsets.only(
                          left: metrics.cardPadding,
                          right: metrics.cardPadding,
                          top: metrics.sectionSpacing,
                        ),
                        child: Text(
                          viewModel.model.quickActionsTitle,
                          style: GoogleFonts.inter(
                            fontSize: metrics.sectionTitleFontSize,
                            fontWeight: FontWeight.normal,
                            color: AppColors.textDarkPink,
                          ),
                        ),
                      ),

                      // Quick Actions Grid
                      Padding(
                        padding: EdgeInsets.only(
                          left: metrics.cardPadding,
                          right: metrics.cardPadding,
                          top: 0,
                        ),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: metrics.quickActionGridSpacing,
                            mainAxisSpacing: metrics.quickActionGridSpacing,
                            childAspectRatio: 100 / 92,
                          ),
                          itemCount: viewModel.quickActions.length,
                          itemBuilder: (context, index) {
                            final action = viewModel.quickActions[index];
                            return TweenAnimationBuilder<double>(
                              duration: Duration(
                                milliseconds: 400 + (index * 100),
                              ),
                              tween: Tween(begin: 0.0, end: 1.0),
                              curve: Curves.easeOutBack,
                              builder: (context, value, child) {
                                // Clamp opacity to valid range [0.0, 1.0]
                                final clampedOpacity = value.clamp(0.0, 1.0);
                                return Transform.scale(
                                  scale: value,
                                  child: Opacity(
                                    opacity: clampedOpacity,
                                    child: child,
                                  ),
                                );
                              },
                              child: QuickActionCard(
                                title: action.title,
                                iconPath: action.iconPath,
                                onTap: () =>
                                    viewModel.onQuickActionTap(action),
                                metrics: metrics,
                              ),
                            );
                          },
                        ),
                      ),

                      // Bottom spacing
                      SizedBox(height: metrics.contentBottomSpacing),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Navigation
            HomeBottomNav(
              viewModel: viewModel,
              metrics: metrics,
            ),
          ],
        ),
      ),
      ),
    );
  }
}

