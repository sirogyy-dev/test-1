import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._internal();

  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
        macOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: (response) {},
    );

    await _configureLocalTimeZone();
    _initialized = true;
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    try {
      final localTimeZone = await FlutterNativeTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTimeZone));
    } catch (_) {
      tz.setLocalLocation(tz.local);
    }
  }

  Future<bool> requestPermission() async {
    await initialize();

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final iosPlugin = _plugin.resolvePlatformSpecificImplementation<DarwinFlutterLocalNotificationsPlugin>();

    final androidGranted = await androidPlugin?.requestPermission() ?? true;
    final iosGranted = await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true) ?? true;

    return androidGranted && iosGranted;
  }

  Future<void> scheduleDailyReminder({TimeOfDay reminderTime = const TimeOfDay(hour: 9, minute: 0)}) async {
    await initialize();

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      reminderTime.hour,
      reminderTime.minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      0,
      'Daily task reminder',
      'Review your tasks and stay on track today.',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder_channel',
          'Daily reminders',
          channelDescription: 'Daily reminders to review tasks',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      ),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleDueDateReminder({
    required String taskId,
    required String taskTitle,
    required DateTime dueDate,
  }) async {
    await initialize();

    final scheduled = tz.TZDateTime.from(dueDate.subtract(const Duration(hours: 1)), tz.local);
    final now = tz.TZDateTime.now(tz.local);
    if (scheduled.isBefore(now)) {
      if (dueDate.isBefore(now)) {
        return;
      }
    }

    final scheduledTime = scheduled.isBefore(now) ? now.add(const Duration(seconds: 5)) : scheduled;

    await _plugin.zonedSchedule(
      _taskNotificationId(taskId),
      'Task due soon',
      'Your task "${taskTitle.trim()}" is due at ${DateFormat.jm().format(dueDate)}.',
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'due_date_channel',
          'Task due reminders',
          channelDescription: 'Reminders for upcoming tasks',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      ),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
    );
  }

  Future<void> cancelTaskReminder(String taskId) async {
    await initialize();
    await _plugin.cancel(_taskNotificationId(taskId));
  }

  int _taskNotificationId(String taskId) {
    return taskId.hashCode.abs();
  }
}
