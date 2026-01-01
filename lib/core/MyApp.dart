import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:love_connect/core/colors/app_colors.dart';
import 'package:love_connect/core/navigation/smooth_transitions.dart';
import 'package:love_connect/core/services/app_session_tracker.dart';
import 'package:love_connect/screens/splash_screen/view/splash_view.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Start tracking app session time
    AppSessionTracker.instance.startTracking();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AppSessionTracker.instance.stopTracking();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        // App came to foreground - resume tracking
        AppSessionTracker.instance.resumeTracking();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        // App went to background - pause tracking
        AppSessionTracker.instance.pauseTracking();
        break;
      case AppLifecycleState.hidden:
        // App is hidden - pause tracking
        AppSessionTracker.instance.pauseTracking();
        break;
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaryRed,
      brightness: Brightness.light,
    );

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.rightToLeftWithFade,
      transitionDuration: SmoothNavigator.defaultDuration,
      themeMode: ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: AppColors.backgroundGradientStart,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: colorScheme.inverseSurface,
          contentTextStyle: TextStyle(
            color: colorScheme.onInverseSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: SmoothPageTransitionsBuilder(),
            TargetPlatform.iOS: SmoothPageTransitionsBuilder(),
          },
        ),
      ),
      home: const SplashView(),
    );
  }
}