import 'package:fpdart/fpdart.dart';
import '../entities/habit.dart';
import '../repositories/habit_repository.dart';
import '../../../../core/errors/failures.dart';

/// Use case for watching all habits
class WatchHabits {
  final HabitRepository _repo;

  const WatchHabits(this._repo);

  /// Watches all habits as a stream
  Stream<Either<Failure, List<Habit>>> call() => _repo.watchAll();
}

/// Use case for getting all habits once
class GetAllHabits {
  final HabitRepository _repo;

  const GetAllHabits(this._repo);

  /// Gets all habits once
  Future<Either<Failure, List<Habit>>> call() => _repo.getAllOnce();
}

/// Use case for getting a single habit by ID
class GetHabit {
  final HabitRepository _repo;

  const GetHabit(this._repo);

  /// Gets a habit by ID
  Future<Either<Failure, Habit?>> call(String habitId) => _repo.getById(habitId);
}

/// Use case for getting habits due today
class GetHabitsDueToday {
  final HabitRepository _repo;

  const GetHabitsDueToday(this._repo);

  /// Gets habits due today
  Future<Either<Failure, List<Habit>>> call() => _repo.getDueToday();
}
