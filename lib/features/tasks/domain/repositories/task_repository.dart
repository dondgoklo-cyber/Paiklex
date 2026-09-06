import "package:fpdart/fpdart.dart" as fpdart;
import '../../../../core/errors/failures.dart';
import '../entities/task.dart';

/// Abstract contract for task operations
/// All methods return fpdart.Either<Failure, T> for error handling
abstract class TaskRepository {
  /// Watch all tasks as a stream
  Stream<fpdart.Either<Failure, List<Task>>> watchAll();

  /// Watch tasks filtered by project
  Stream<fpdart.Either<Failure, List<Task>>> watchByProject(String? projectId);

  /// Create a new task
  Future<fpdart.Either<Failure, Task>> create(Task task);

  /// Update an existing task
  Future<fpdart.Either<Failure, Task>> update(Task task);

  /// Delete a task by ID
  Future<fpdart.Either<Failure, void>> delete(String taskId);

  /// Toggle task completion status
  Future<fpdart.Either<Failure, Task>> toggle(String taskId);

  /// Reorder task in list
  Future<fpdart.Either<Failure, void>> reorder(String taskId, int newIndex);

  /// Get a single task by ID
  Future<fpdart.Either<Failure, Task?>> getById(String taskId);

  /// Get all tasks once (not as stream)
  Future<fpdart.Either<Failure, List<Task>>> getAllOnce();
}
