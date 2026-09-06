import 'package:fpdart/fpdart.dart';
import 'package:drift/drift.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/reminder.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../models/reminder_model.dart';
import '../../../../database/app_database.dart';
import '../../../../features/notifications/data/notification_service.dart';

/// Implementation of ReminderRepository using Drift and flutter_local_notifications
class ReminderRepositoryImpl implements ReminderRepository {
  final AppDatabase _db;
  final NotificationService _notificationService;
  final Logger _logger;

  ReminderRepositoryImpl(this._db, this._notificationService)
      : _logger = Logger('ReminderRepositoryImpl');

  @override
  Stream<Either<Failure, List<Reminder>>> watchAll() {
    return _db.reminderDao.watchAll().map((rows) {
      try {
        return Right(rows.map((row) => row.toEntity()).toList());
      } catch (e, s) {
        _logger.e('Failed to map reminder rows', error: e, stackTrace: s);
        return Left(DatabaseFailure(e.toString()));
      }
    }).handleError((e, s) {
      _logger.e('Failed to watch reminders', error: e, stackTrace: s);
      return Left(DatabaseFailure(e.toString()));
    });
  }

  @override
  Future<Either<Failure, List<Reminder>>> getAllOnce() async {
    try {
      final rows = await _db.reminderDao.getAllOnce();
      return Right(rows.map((row) => row.toEntity()).toList());
    } catch (e, s) {
      _logger.e('Failed to get all reminders', error: e, stackTrace: s);
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Reminder?>> getById(String reminderId) async {
    try {
      final row = await _db.reminderDao.getById(reminderId);
      return Right(row?.toEntity());
    } catch (e, s) {
      _logger.e('Failed to get reminder by ID', error: e, stackTrace: s);
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Reminder>> create(Reminder reminder) async {
    try {
      await _db.reminderDao.insert(reminder.toCompanion());
      return Right(reminder);
    } catch (e, s) {
      _logger.e('Failed to create reminder', error: e, stackTrace: s);
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Reminder>> update(Reminder reminder) async {
    try {
      await _db.reminderDao.update(reminder.toCompanion());
      return Right(reminder);
    } catch (e, s) {
      _logger.e('Failed to update reminder', error: e, stackTrace: s);
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> delete(String reminderId) async {
    try {
      await _db.reminderDao.delete(reminderId);
      return const Right(null);
    } catch (e, s) {
      _logger.e('Failed to delete reminder', error: e, stackTrace: s);
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Reminder>> schedule(Reminder reminder) async {
    try {
      // Create the reminder in the database
      await _db.reminderDao.insert(reminder.toCompanion());

      // Schedule the notification
      tz_data.initializeTimeZones();
      
      final now = AppDateUtils.nowUtc();
      final triggerDate = reminder.triggerAt.toLocal();
      
      if (triggerDate.isAfter(now)) {
        final notificationDetails = NotificationDetails(
          android: AndroidNotificationDetails(
            'reminder_channel',
            'Reminders',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        );

        await _notificationService.scheduleNotification(
          id: reminder.id.hashCode,
          title: reminder.title,
          body: reminder.body ?? '',
          scheduledTime: triggerDate,
          notificationDetails: notificationDetails,
        );
      }

      return Right(reminder);
    } catch (e, s) {
      _logger.e('Failed to schedule reminder', error: e, stackTrace: s);
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancel(String reminderId) async {
    try {
      // Delete from database
      await _db.reminderDao.delete(reminderId);

      // Cancel the notification
      await _notificationService.cancelNotification(reminderId.hashCode);

      return const Right(null);
    } catch (e, s) {
      _logger.e('Failed to cancel reminder', error: e, stackTrace: s);
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Reminder>>> getByTask(String taskId) async {
    try {
      final rows = await _db.reminderDao.getByTask(taskId);
      return Right(rows.map((row) => row.toEntity()).toList());
    } catch (e, s) {
      _logger.e('Failed to get reminders by task', error: e, stackTrace: s);
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Reminder>>> getByHabit(String habitId) async {
    try {
      final rows = await _db.reminderDao.getByHabit(habitId);
      return Right(rows.map((row) => row.toEntity()).toList());
    } catch (e, s) {
      _logger.e('Failed to get reminders by habit', error: e, stackTrace: s);
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
