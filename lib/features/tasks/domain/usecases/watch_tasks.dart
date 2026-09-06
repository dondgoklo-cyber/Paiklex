import "package:fpdart/fpdart.dart" as fpdart;
import '../../../../core/errors/failures.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

/// Use case for watching all tasks
class WatchAllTasks {
  final TaskRepository _repo;

  const WatchAllTasks(this._repo);

  /// Returns a stream of all tasks
  Stream<fpdart.Either<Failure, List<Task>>> call() => _repo.watchAll();
}

/// Use case for watching tasks by project
class WatchTasksByProject {
  final TaskRepository _repo;

  const WatchTasksByProject(this._repo);

  /// Returns a stream of tasks filtered by project ID
  /// Pass null for inbox (tasks without project)
  Stream<fpdart.Either<Failure, List<Task>>> call(String? projectId) =>
      _repo.watchByProject(projectId);
}
