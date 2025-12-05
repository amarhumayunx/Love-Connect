import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

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
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    try {
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      // Fallback to UTC if timezone is invalid
      if (kDebugMode) {
        debugPrint('Failed to set local timezone: $e');
      }
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
    
    if (kDebugMode) {
      debugPrint('NotificationService initialized with timezone: $timeZoneName');
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
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

  /// Handle notification tap events
  void _onNotificationTapped(NotificationResponse response) {
    if (kDebugMode) {
      debugPrint('Notification tapped: ${response.payload}');
    }
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
    );

    final androidPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    await androidPlugin?.createNotificationChannel(channel);
  }

  Future<void> _requestPermissions() async {
    // Android 13+ runtime permission
    final androidPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
    
    // Request exact alarm permission for Android 12+ (API 31+)
    final canScheduleExactAlarms = await androidPlugin?.canScheduleExactNotifications();
    if (canScheduleExactAlarms != null && !canScheduleExactAlarms) {
      await androidPlugin?.requestExactAlarmsPermission();
      if (kDebugMode) {
        debugPrint('Requested exact alarm permission');
      }
    }

    // iOS permission (alert/sound/badge)
    final iosPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// Check if notifications are enabled/permitted
  Future<bool> areNotificationsEnabled() async {
    if (!_initialized) {
      await init();
    }

    final androidPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
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
    if (!_initialized) {
      await init();
    }

    // Don't schedule notifications in the past
    if (scheduledTime.isBefore(DateTime.now())) {
      return;
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
      showWhen: true,
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

    final tz.TZDateTime tzTime =
        tz.TZDateTime.from(scheduledTime, tz.local);

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
    
    if (kDebugMode) {
      debugPrint('Scheduled notification ID $id for ${tzTime.toString()}');
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
    if (!hasPermission && kDebugMode) {
      debugPrint('Notification permission not granted. Please grant permission in settings.');
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
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

    // Use show() for immediate notification instead of scheduling
    await _flutterLocalNotificationsPlugin.show(
      9999, // Use a fixed ID for test notifications
      'Test Notification',
      'If you see this, local notifications are working! 🎉',
      notificationDetails,
      payload: 'test_notification',
    );
  }

  /// Cancel a specific notification by ID
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Cancel all plan notifications (keeps test notifications)
  Future<void> cancelAllPlanNotifications() async {
    // Get all pending notifications
    final pendingNotifications = await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
    
    // Cancel all except test notification (ID 9999)
    for (var notification in pendingNotifications) {
      if (notification.id != 9999) {
        await _flutterLocalNotificationsPlugin.cancel(notification.id);
      }
    }
  }

  /// Get all pending notification IDs
  Future<List<int>> getPendingNotificationIds() async {
    final pendingNotifications = await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
    return pendingNotifications.map((n) => n.id).toList();
  }

  /// Legacy method name for backward compatibility
  /// Now shows immediate notification instead of scheduling
  @Deprecated('Use showTestNotification() instead')
  Future<void> scheduleTestNotification() async {
    await showTestNotification();
  }
}


