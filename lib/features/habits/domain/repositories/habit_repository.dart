import 'package:fpdart/fpdart.dart';
import '../entities/habit.dart';
import '../../../../core/errors/failures.dart';

/// Abstract contract for habit repository
abstract class HabitRepository {
  /// Watches all habits as a stream
  Stream<Either<Failure, List<Habit>>> watchAll();

  /// Gets all habits once
  Future<Either<Failure, List<Habit>>> getAllOnce();

  /// Gets a habit by ID
  Future<Either<Failure, Habit?>> getById(String habitId);

  /// Creates a new habit
  Future<Either<Failure, Habit>> create(Habit habit);

  /// Updates an existing habit
  Future<Either<Failure, Habit>> update(Habit habit);

  /// Deletes a habit by ID
  Future<Either<Failure, void>> delete(String habitId);

  /// Completes a habit (updates streak)
  Future<Either<Failure, Habit>> complete(String habitId);

  /// Gets habits due today
  Future<Either<Failure, List<Habit>>> getDueToday();
}
