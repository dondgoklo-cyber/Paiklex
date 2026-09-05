import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

/// Use case for getting a single task by ID
class GetTask {
  final TaskRepository _repo;

  const GetTask(this._repo);

  /// Gets a task by ID
  Future<Either<Failure, Task?>> call(String taskId) => _repo.getById(taskId);
}

/// Use case for getting all tasks once
class GetAllTasks {
  final TaskRepository _repo;

  const GetAllTasks(this._repo);

  /// Gets all tasks once (not as stream)
  Future<Either<Failure, List<Task>>> call() => _repo.getAllOnce();
}
