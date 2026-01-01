import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';

/// Handles initialization and scheduling of local notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  static const String _channelId = 'plans_channel';
  static const String _channelName = 'Plan Reminders';
  static const String _channelDescription = 'Reminders for your romantic plans';

  Future<void> init() async {
    if (_initialized) return;

    // Timezone setup (once per app launch)
    tz.initializeTimeZones();
    // Get the actual local timezone from the device
    final TimezoneInfo timeZoneInfo = await FlutterTimezone.getLocalTimezone();
    final String timeZoneName = timeZoneInfo.identifier;
    try {
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      // Fallback to UTC if timezone is invalid
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize with callback handler
    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android (required for Android 8.0+)
    await _createNotificationChannel();

    // Request notification permissions from the system (Android 13+ and iOS)
    await _requestPermissions();

    _initialized = true;
  }

  /// Open battery optimization settings to request exemption
  Future<void> openBatteryOptimizationSettings() async {
    if (!kIsWeb && Platform.isAndroid) {
      try {
        // Request to disable battery optimization
        const platform = MethodChannel('battery_optimization');
        await platform.invokeMethod('openSettings');
      } catch (e) {
        // Silently handle error
      }
    }
  }

  /// Handle notification tap events
  void _onNotificationTapped(NotificationResponse response) {
    // You can add navigation logic here if needed
  }

  /// Create notification channel for Android (required for Android 8.0+)
  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.max,
      enableVibration: true,
      playSound: true,
      showBadge: true,
      // CRITICAL: Allow notifications to bypass Do Not Disturb
      // This is especially important for Samsung devices
      enableLights: true,
      ledColor: Colors.red,
    );

    final androidPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.createNotificationChannel(channel);
  }

  Future<void> _requestPermissions() async {
    final androidPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();

      final canScheduleExactAlarms =
      await androidPlugin.canScheduleExactNotifications();

      if (canScheduleExactAlarms == null || !canScheduleExactAlarms) {
        await androidPlugin.requestExactAlarmsPermission();
      }
    }

    final iosPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    if (iosPlugin != null) {
      await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
        critical: true,
      );
    }
  }  /// Ensure notification service is initialized and permissions are granted
  /// Call this before scheduling any notifications
  Future<bool> ensureInitializedWithPermissions() async {
    if (!_initialized) {
      await init();
    }

    // Check if we have exact alarm permission (critical for scheduled notifications)
    final androidPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      final canScheduleExactAlarms = await androidPlugin
          .canScheduleExactNotifications();

      if (canScheduleExactAlarms == null || !canScheduleExactAlarms) {
        await androidPlugin.requestExactAlarmsPermission();

        // Check again after requesting
        final canScheduleAfterRequest = await androidPlugin
            .canScheduleExactNotifications();
        return canScheduleAfterRequest ?? false;
      }
      return canScheduleExactAlarms;
    }

    // For iOS, assume permissions are granted if initialized
    return true;
  }

  /// Check if notifications are enabled/permitted
  Future<bool> areNotificationsEnabled() async {
    if (!_initialized) {
      await init();
    }

    final androidPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }

    // For iOS, assume granted if initialized successfully
    return true;
  }

  /// Schedule a notification for a specific [scheduledTime].
  /// If [scheduledTime] is in the past, nothing is scheduled.
  Future<void> schedulePlanNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    // Ensure initialized and permissions are granted
    final hasPermission = await ensureInitializedWithPermissions();
    if (!hasPermission) {
      return;
    }

    // Don't schedule notifications in the past
    if (scheduledTime.isBefore(DateTime.now())) {
      return;
    }

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.max,
          priority: Priority.high,
          enableVibration: true,
          playSound: true,
          showWhen: true,
          category: AndroidNotificationCategory.alarm,
          visibility: NotificationVisibility.public,
          fullScreenIntent: true,
          autoCancel: true,
          ongoing: false,
          when: null,
          usesChronometer: false,
          channelShowBadge: true,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final tz.TZDateTime tzTime = tz.TZDateTime.from(scheduledTime, tz.local);

    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzTime,
        notificationDetails,
        // Use exact alarm for precise timing (10 minutes before plan)
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: null,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Show an immediate test notification.
  /// Useful while developing to verify that notifications are working.
  Future<void> showTestNotification() async {
    if (!_initialized) {
      await init();
    }

    // Check if permissions are granted
    final hasPermission = await areNotificationsEnabled();
    if (!hasPermission) {
      return;
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.max,
          priority: Priority.high,
          enableVibration: true,
          playSound: true,
          showWhen: false,
          icon: '@mipmap/ic_launcher',
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      9999,
      'Test Notification',
      'If you see this, local notifications are working! 🎉',
      notificationDetails,
      payload: 'test_notification',
    );
  }


  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> cancelAllPlanNotifications() async {
    final pendingNotifications = await _flutterLocalNotificationsPlugin
        .pendingNotificationRequests();

    for (var notification in pendingNotifications) {
      if (notification.id != 9999) {
        await _flutterLocalNotificationsPlugin.cancel(notification.id);
      }
    }
  }

  Future<List<int>> getPendingNotificationIds() async {
    final pendingNotifications = await _flutterLocalNotificationsPlugin
        .pendingNotificationRequests();
    return pendingNotifications.map((n) => n.id).toList();
  }


  @Deprecated('Use showTestNotification() instead')
  Future<void> scheduleTestNotification() async {
    await showTestNotification();
  }
}
