import "package:fpdart/fpdart.dart" as fpdart;
import '../entities/reminder.dart';
import '../../../../core/errors/failures.dart';

/// Abstract contract for reminder repository
abstract class ReminderRepository {
  /// Watches all reminders as a stream
  Stream<fpdart.Either<Failure, List<Reminder>>> watchAll();

  /// Gets all reminders once
  Future<fpdart.Either<Failure, List<Reminder>>> getAllOnce();

  /// Gets a reminder by ID
  Future<fpdart.Either<Failure, Reminder?>> getById(String reminderId);

  /// Creates a new reminder
  Future<fpdart.Either<Failure, Reminder>> create(Reminder reminder);

  /// Updates an existing reminder
  Future<fpdart.Either<Failure, Reminder>> update(Reminder reminder);

  /// Deletes a reminder by ID
  Future<fpdart.Either<Failure, void>> delete(String reminderId);

  /// Schedules a reminder (creates and sets up notification)
  Future<fpdart.Either<Failure, Reminder>> schedule(Reminder reminder);

  /// Cancels a reminder (deletes and removes notification)
  Future<fpdart.Either<Failure, void>> cancel(String reminderId);

  /// Gets reminders for a specific task
  Future<fpdart.Either<Failure, List<Reminder>>> getByTask(String taskId);

  /// Gets reminders for a specific habit
  Future<fpdart.Either<Failure, List<Reminder>>> getByHabit(String habitId);
}
