import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> init({VoidCallback? onNotificationTapped}) async {
    if (_isInitialized) return;
    
    tz.initializeTimeZones();
    _configureLocalTimezone();
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
        
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint("Notification tapped, navigating to Today screen");
        onNotificationTapped?.call();
      },
    );

    // Check if app was launched via notification tap on cold start
    final launchDetails = await _notificationsPlugin.getNotificationAppLaunchDetails();
    if (launchDetails != null && launchDetails.didNotificationLaunchApp) {
      debugPrint("App launched from notification cold start, navigating to Today screen");
      onNotificationTapped?.call();
    }
    
    // Explicitly create notification channel with max priority, quiet mode (no vibration) and public lock screen visibility
    final androidImplementation = _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(
        const AndroidNotificationChannel(
          'daily_reminder_channel_v5',
          'Daily Ritual Reminder',
          description: 'Daily thought reminder notification',
          importance: Importance.max,
          playSound: true,
          enableVibration: false,
          showBadge: true,
        ),
      );
    }

    _isInitialized = true;
  }

  void _configureLocalTimezone() {
    final offset = DateTime.now().timeZoneOffset;
    tz.Location? matched;
    for (final loc in tz.timeZoneDatabase.locations.values) {
      if (loc.currentTimeZone.offset == offset.inMilliseconds) {
        matched = loc;
        break;
      }
    }
    if (matched != null) {
      tz.setLocalLocation(matched);
      debugPrint("Local timezone configured to: ${matched.name} (offset: ${offset.inHours}h)");
    } else {
      final customLocation = tz.Location(
        'LocalDeviceOffset',
        [tz.minTime],
        [0],
        [tz.TimeZone(offset.inMilliseconds, isDst: false, abbreviation: 'LOC')],
      );
      tz.setLocalLocation(customLocation);
      debugPrint("Local timezone configured with custom offset: ${offset.inHours}h");
    }
  }

  Future<bool> requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      final granted = await androidImplementation.requestNotificationsPermission();
      try {
        await androidImplementation.requestExactAlarmsPermission();
      } catch (_) {}
      return granted ?? false;
    }
    return false;
  }

  Future<void> scheduleDailyReminder({
    required TimeOfDay time,
    required String body,
    String? subText,
    String? title,
  }) async {
    await cancelAll();

    // Ensure local timezone is accurately aligned with current device offset
    _configureLocalTimezone();

    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    debugPrint("Scheduled daily reminder at: $scheduledDate (subText: $subText, current tz.local: $now)");

    final BigTextStyleInformation bigTextStyleInformation =
        BigTextStyleInformation(
      body,
      contentTitle: title,
      summaryText: subText,
    );

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'daily_reminder_channel_v5',
      'Daily Ritual Reminder',
      channelDescription: 'Daily thought reminder notification',
      importance: Importance.max,
      priority: Priority.max,
      visibility: NotificationVisibility.public,
      category: AndroidNotificationCategory.reminder,
      playSound: true,
      enableVibration: false,
      subText: subText,
      styleInformation: bigTextStyleInformation,
    );
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.zonedSchedule(
      0,
      title,
      body,
      scheduledDate,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }
}
