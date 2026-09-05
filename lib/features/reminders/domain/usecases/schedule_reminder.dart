import 'package:fpdart/fpdart.dart';
import '../entities/reminder.dart';
import '../repositories/reminder_repository.dart';
import '../../../../core/errors/failures.dart';

/// Use case for scheduling a reminder
class ScheduleReminder {
  final ReminderRepository _repo;

  const ScheduleReminder(this._repo);

  /// Schedules a reminder (creates and sets up notification)
  Future<Either<Failure, Reminder>> call(Reminder reminder) => _repo.schedule(reminder);
}

/// Use case for canceling a reminder
class CancelReminder {
  final ReminderRepository _repo;

  const CancelReminder(this._repo);

  /// Cancels a reminder (deletes and removes notification)
  Future<Either<Failure, void>> call(String reminderId) => _repo.cancel(reminderId);
}

/// Use case for updating a reminder
class UpdateReminder {
  final ReminderRepository _repo;

  const UpdateReminder(this._repo);

  /// Updates a reminder
  Future<Either<Failure, Reminder>> call(Reminder reminder) async {
    if (reminder.title.trim().isEmpty) {
      return Left(ValidationFailure('Reminder title cannot be empty'));
    }

    return _repo.update(reminder);
  }
}

/// Use case for deleting a reminder
class DeleteReminder {
  final ReminderRepository _repo;

  const DeleteReminder(this._repo);

  /// Deletes a reminder by ID
  Future<Either<Failure, void>> call(String reminderId) => _repo.delete(reminderId);
}
