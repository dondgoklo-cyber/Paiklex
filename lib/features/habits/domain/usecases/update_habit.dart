import 'package:fpdart/fpdart.dart';
import '../entities/habit.dart';
import '../repositories/habit_repository.dart';
import '../../../../core/errors/failures.dart';

/// Use case for updating a habit
class UpdateHabit {
  final HabitRepository _repo;

  const UpdateHabit(this._repo);

  /// Updates a habit
  Future<Either<Failure, Habit>> call(Habit habit) async {
    if (habit.title.trim().isEmpty) {
      return Left(ValidationFailure('Habit title cannot be empty'));
    }

    return _repo.update(habit);
  }
}

/// Use case for deleting a habit
class DeleteHabit {
  final HabitRepository _repo;

  const DeleteHabit(this._repo);

  /// Deletes a habit by ID
  Future<Either<Failure, void>> call(String habitId) => _repo.delete(habitId);
}

/// Use case for completing a habit
class CompleteHabit {
  final HabitRepository _repo;

  const CompleteHabit(this._repo);

  /// Completes a habit (updates streak)
  Future<Either<Failure, Habit>> call(String habitId) => _repo.complete(habitId);
}
