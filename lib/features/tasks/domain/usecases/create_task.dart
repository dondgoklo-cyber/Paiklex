import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/date_utils.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

/// Use case for creating a new task
class CreateTask {
  final TaskRepository _repo;
  final Uuid _uuid;

  const CreateTask(this._repo, this._uuid);

  /// Creates a new task with generated UUID if not provided
  Future<Either<Failure, Task>> call(Task task) async {
    if (task.content.trim().isEmpty) {
      return const Left(ValidationFailure('Content cannot be empty'));
    }

    // Generate UUID if not set
    final finalTask = task.id.isEmpty
        ? task.copyWith(
            id: _uuid.v4(),
            createdAt: AppDateUtils.nowUtc(),
            updatedAt: AppDateUtils.nowUtc(),
          )
        : task;

    return _repo.create(finalTask);
  }
}
