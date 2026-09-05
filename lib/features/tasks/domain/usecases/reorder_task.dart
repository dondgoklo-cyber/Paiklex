import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/task_repository.dart';

/// Use case for reordering a task in the list
class ReorderTask {
  final TaskRepository _repo;

  const ReorderTask(this._repo);

  /// Reorders a task to a new index
  Future<Either<Failure, void>> call(String taskId, int newIndex) =>
      _repo.reorder(taskId, newIndex);
}
