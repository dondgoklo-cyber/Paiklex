import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

/// Use case for updating a task
class UpdateTask {
  final TaskRepository _repo;

  const UpdateTask(this._repo);

  /// Updates an existing task
  Future<Either<Failure, Task>> call(Task task) async {
    if (task.id.trim().isEmpty) {
      return const Left(ValidationFailure('Task id cannot be empty'));
    }
    if (task.content.trim().isEmpty) {
      return const Left(ValidationFailure('Task content cannot be empty'));
    }
    return _repo.update(task);
  }
}
