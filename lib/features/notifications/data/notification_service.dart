import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:logger/logger.dart';

/// Service for managing local notifications
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final Logger _logger = Logger('NotificationService');
  bool _initialized = false;

  NotificationService();

  /// Initializes the notification service (idempotent)
  Future<void> init() async {
    if (_initialized) return;

    try {
      tz.initializeTimeZones();

      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ios = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      await _plugin.initialize(
        const InitializationSettings(android: android, iOS: ios),
      );

      _initialized = true;
      _logger.i('Notification service initialized');
    } catch (e, s) {
      _logger.e('Failed to initialize notifications', error: e, stackTrace: s);
    }
  }

  /// Schedules a notification using NotificationDetails
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required NotificationDetails notificationDetails,
  }) async {
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledTime.toLocal(), tz.local),
        notificationDetails,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      _logger.i('Notification scheduled for $id at $scheduledTime');
    } catch (e, s) {
      _logger.e('Failed to schedule notification', error: e, stackTrace: s);
    }
  }

  /// Cancels a specific notification by ID
  Future<void> cancelNotification(int id) async {
    try {
      await _plugin.cancel(id);
      _logger.i('Notification cancelled: $id');
    } catch (e, s) {
      _logger.e('Failed to cancel notification', error: e, stackTrace: s);
    }
  }

  /// Cancels all notifications
  Future<void> cancelAll() async {
    try {
      await _plugin.cancelAll();
      _logger.i('All notifications cancelled');
    } catch (e, s) {
      _logger.e('Failed to cancel all notifications', error: e, stackTrace: s);
    }
  }
}
