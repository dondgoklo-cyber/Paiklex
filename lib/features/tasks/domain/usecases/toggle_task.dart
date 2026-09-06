import "package:fpdart/fpdart.dart" as fpdart;
import '../../../../core/errors/failures.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

/// Use case for toggling task completion status
class ToggleTask {
  final TaskRepository _repo;

  const ToggleTask(this._repo);

  /// Toggles the completion status of a task
  Future<fpdart.Either<Failure, Task>> call(String taskId) => _repo.toggle(taskId);
}
