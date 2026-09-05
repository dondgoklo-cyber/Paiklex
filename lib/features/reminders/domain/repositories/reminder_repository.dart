import 'package:fpdart/fpdart.dart';
import '../entities/reminder.dart';
import '../../../../core/errors/failures.dart';

/// Abstract contract for reminder repository
abstract class ReminderRepository {
  /// Watches all reminders as a stream
  Stream<Either<Failure, List<Reminder>>> watchAll();

  /// Gets all reminders once
  Future<Either<Failure, List<Reminder>>> getAllOnce();

  /// Gets a reminder by ID
  Future<Either<Failure, Reminder?>> getById(String reminderId);

  /// Creates a new reminder
  Future<Either<Failure, Reminder>> create(Reminder reminder);

  /// Updates an existing reminder
  Future<Either<Failure, Reminder>> update(Reminder reminder);

  /// Deletes a reminder by ID
  Future<Either<Failure, void>> delete(String reminderId);

  /// Schedules a reminder (creates and sets up notification)
  Future<Either<Failure, Reminder>> schedule(Reminder reminder);

  /// Cancels a reminder (deletes and removes notification)
  Future<Either<Failure, void>> cancel(String reminderId);

  /// Gets reminders for a specific task
  Future<Either<Failure, List<Reminder>>> getByTask(String taskId);

  /// Gets reminders for a specific habit
  Future<Either<Failure, List<Reminder>>> getByHabit(String habitId);
}
