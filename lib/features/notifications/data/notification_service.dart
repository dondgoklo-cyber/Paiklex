import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:logger/logger.dart';
import '../../../../core/utils/logger.dart';

/// Service for managing local notifications
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final Logger _logger = AppLogger.forService('NotificationService');
  bool _initialized = false;

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

  /// Schedules a notification
  Future<void> schedule({
    required String id,
    required String title,
    required String body,
    required DateTime triggerAtUtc,
  }) async {
    try {
      await _plugin.zonedSchedule(
        id.hashCode,
        title,
        body,
        tz.TZDateTime.from(triggerAtUtc.toUtc(), tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'monolith',
            'Monolith',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      _logger.i('Notification scheduled for $id at $triggerAtUtc');
    } catch (e, s) {
      _logger.e('Failed to schedule notification', error: e, stackTrace: s);
    }
  }

  /// Cancels a specific notification
  Future<void> cancel(String id) async {
    try {
      await _plugin.cancel(id.hashCode);
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
