import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/task.dart';

/// Abstract contract for task operations
/// All methods return Either<Failure, T> for error handling
abstract class TaskRepository {
  /// Watch all tasks as a stream
  Stream<Either<Failure, List<Task>>> watchAll();

  /// Watch tasks filtered by project
  Stream<Either<Failure, List<Task>>> watchByProject(String? projectId);

  /// Create a new task
  Future<Either<Failure, Task>> create(Task task);

  /// Update an existing task
  Future<Either<Failure, Task>> update(Task task);

  /// Delete a task by ID
  Future<Either<Failure, void>> delete(String taskId);

  /// Toggle task completion status
  Future<Either<Failure, Task>> toggle(String taskId);

  /// Reorder task in list
  Future<Either<Failure, void>> reorder(String taskId, int newIndex);

  /// Get a single task by ID
  Future<Either<Failure, Task?>> getById(String taskId);

  /// Get all tasks once (not as stream)
  Future<Either<Failure, List<Task>>> getAllOnce();
}
