import 'package:fpdart/fpdart.dart';
import '../entities/reminder.dart';
import '../repositories/reminder_repository.dart';
import '../../../../core/errors/failures.dart';

/// Use case for watching all reminders
class WatchReminders {
  final ReminderRepository _repo;

  const WatchReminders(this._repo);

  /// Watches all reminders as a stream
  Stream<Either<Failure, List<Reminder>>> call() => _repo.watchAll();
}

/// Use case for getting all reminders once
class GetAllReminders {
  final ReminderRepository _repo;

  const GetAllReminders(this._repo);

  /// Gets all reminders once
  Future<Either<Failure, List<Reminder>>> call() => _repo.getAllOnce();
}

/// Use case for getting a single reminder by ID
class GetReminder {
  final ReminderRepository _repo;

  const GetReminder(this._repo);

  /// Gets a reminder by ID
  Future<Either<Failure, Reminder?>> call(String reminderId) => _repo.getById(reminderId);
}

/// Use case for getting reminders by task
class GetRemindersByTask {
  final ReminderRepository _repo;

  const GetRemindersByTask(this._repo);

  /// Gets reminders for a specific task
  Future<Either<Failure, List<Reminder>>> call(String taskId) => _repo.getByTask(taskId);
}

/// Use case for getting reminders by habit
class GetRemindersByHabit {
  final ReminderRepository _repo;

  const GetRemindersByHabit(this._repo);

  /// Gets reminders for a specific habit
  Future<Either<Failure, List<Reminder>>> call(String habitId) => _repo.getByHabit(habitId);
}
