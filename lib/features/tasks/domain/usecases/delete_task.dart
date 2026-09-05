import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/task_repository.dart';

/// Use case for deleting a task
class DeleteTask {
  final TaskRepository _repo;

  const DeleteTask(this._repo);

  /// Deletes a task by ID
  Future<Either<Failure, void>> call(String taskId) => _repo.delete(taskId);
}
