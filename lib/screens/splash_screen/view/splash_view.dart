import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/core/utils/media_query_extensions.dart';
import 'package:love_connect/screens/splash_screen/view/widgets/splash_logo.dart';
import '../view_model/splash_viewmodel.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    Get.put(SplashViewModel());

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );


    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.5,
          end: 1.1,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.1,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_animationController);


    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );


    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );


    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SplashViewModel controller = Get.find<SplashViewModel>();

    return Scaffold(
      backgroundColor: AppColors.backgroundPink,
      body: SafeArea(
        child: Obx(
              () => AnimatedOpacity(
            opacity: controller.isFadingOut.value ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            child: LayoutBuilder(
              builder: (context, constraints)
              {

                final logoSize = context.responsiveImage(220);
                final loadingSize = context.responsiveImage(50);

                return Column(
                  children: [
                    SizedBox(height: context.responsiveSpacing(80)),
                    Expanded(
                      child: Center(
                        child: SizedBox(
                          width: logoSize * 1.25,
                          height: logoSize * 0.89,
                          child: AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale:
                                _scaleAnimation.value *
                                    _bounceAnimation.value,
                                child: Opacity(
                                  opacity: _fadeAnimation.value,
                                  child: SplashLogo(size: logoSize),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: context.responsiveSpacing(50)),
                      child: SizedBox(
                        height: loadingSize,
                        child: Visibility(
                          visible: controller.isLoading.value,
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: LoadingAnimationWidget.horizontalRotatingDots(
                                color: AppColors.primaryRed,
                                size: 50
                            )
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}