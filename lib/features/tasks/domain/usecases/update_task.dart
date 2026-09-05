import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

/// Use case for updating a task
class UpdateTask {
  final TaskRepository _repo;

  const UpdateTask(this._repo);

  /// Updates an existing task
  Future<Either<Failure, Task>> call(Task task) => _repo.update(task);
}
