import "package:fpdart/fpdart.dart" as fpdart;
import '../entities/reminder.dart';
import '../repositories/reminder_repository.dart';
import '../../../../core/errors/failures.dart';
import 'package:uuid/uuid.dart';

/// Use case for creating a new reminder
class CreateReminder {
  final ReminderRepository _repo;
  final Uuid _uuid;

  const CreateReminder(this._repo, this._uuid);

  /// Creates a new reminder
  Future<fpdart.Either<Failure, Reminder>> call({
    String? taskId,
    String? habitId,
    required DateTime triggerAt,
    required String title,
    String? body,
  }) async {
    final reminder = Reminder(
      id: _uuid.v4(),
      taskId: taskId,
      habitId: habitId,
      triggerAt: triggerAt.toUtc(),
      title: title.trim(),
      body: body?.trim(),
      createdAt: DateTime.now().toUtc(),
    );

    if (reminder.title.isEmpty) {
      return fpdart.Left(ValidationFailure('Reminder title cannot be empty'));
    }

    return _repo.create(reminder);
  }
}
