import 'package:fpdart/fpdart.dart';
import '../entities/habit.dart';
import '../repositories/habit_repository.dart';
import '../../../../core/errors/failures.dart';
import 'package:uuid/uuid.dart';

/// Use case for creating a new habit
class CreateHabit {
  final HabitRepository _repo;
  final Uuid _uuid;

  const CreateHabit(this._repo, this._uuid);

  /// Creates a new habit
  Future<Either<Failure, Habit>> call(String title, {String? projectId, String frequency = 'daily'}) async {
    final now = DateTime.now().toUtc();
    final habit = Habit(
      id: _uuid.v4(),
      projectId: projectId,
      title: title.trim(),
      frequency: frequency,
      createdAt: now,
      updatedAt: now,
    );

    if (habit.title.isEmpty) {
      return Left(ValidationFailure('Habit title cannot be empty'));
    }

    return _repo.create(habit);
  }
}
