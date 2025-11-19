import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SmoothNavigator {
  SmoothNavigator._();

  static const Duration _defaultDuration = Duration(milliseconds: 440);
  static const Duration _slowDuration = Duration(milliseconds: 520);
  static const Duration _extraSlowDuration = Duration(milliseconds: 750);
  static const Curve _defaultCurve = Curves.easeInOutCubicEmphasized;
  static const Curve _smoothCurve = Curves.easeInOut;

  static Duration get defaultDuration => _defaultDuration;
  static Duration get slowDuration => _slowDuration;
  static Duration get extraSlowDuration => _extraSlowDuration;
  static Curve get defaultCurve => _defaultCurve;
  static Curve get smoothCurve => _smoothCurve;

  static Future<T?> to<T>(
    Widget Function() page, {
    Transition transition = Transition.rightToLeftWithFade,
    Duration? duration,
    Curve? curve,
    bool fullscreenDialog = false,
    bool preventDuplicates = true,
  }) async {
    return Get.to<T>(
      page,
      transition: transition,
      duration: duration ?? _defaultDuration,
      curve: curve ?? _defaultCurve,
      fullscreenDialog: fullscreenDialog,
      preventDuplicates: preventDuplicates,
    );
  }

  static Future<T?> off<T>(
    Widget Function() page, {
    Transition transition = Transition.rightToLeftWithFade,
    Duration? duration,
    Curve? curve,
  }) async {
    return Get.off<T>(
      page,
      transition: transition,
      duration: duration ?? _defaultDuration,
      curve: curve ?? _defaultCurve,
    );
  }

  static Future<T?> offAll<T>(
    Widget Function() page, {
    Transition transition = Transition.fadeIn,
    Duration? duration,
    Curve? curve,
  }) async {
    return Get.offAll<T>(
      page,
      transition: transition,
      duration: duration ?? _slowDuration,
      curve: curve ?? _defaultCurve,
    );
  }

  /// Navigate back with smooth transition
  /// This ensures the reverse transition matches the forward transition settings
  static void back<T>({
    T? result,
    bool closeOverlays = false,
    bool canPop = true,
  }) {
    Get.back<T>(
      result: result,
      closeOverlays: closeOverlays,
      canPop: canPop,
    );
  }
}

/// Custom page transition used by the Material [ThemeData] so that
/// even non-Get navigations (e.g. system dialogs) feel consistent.
class SmoothPageTransitionsBuilder extends PageTransitionsBuilder {
  const SmoothPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final fadeCurve = CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOutCubicEmphasized,
      reverseCurve: Curves.easeInOut,
    );

    final slideCurve = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    final slideAnimation = Tween<Offset>(
      begin: const Offset(0.05, 0),
      end: Offset.zero,
    ).animate(slideCurve);

    return FadeTransition(
      opacity: fadeCurve,
      child: SlideTransition(
        position: slideAnimation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.98, end: 1).animate(fadeCurve),
          child: child,
        ),
      ),
    );
  }
}
