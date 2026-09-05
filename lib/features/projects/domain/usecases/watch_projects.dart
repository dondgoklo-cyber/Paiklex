import 'package:fpdart/fpdart.dart';
import '../entities/project.dart';
import '../repositories/project_repository.dart';
import '../../../../core/errors/failures.dart';

/// Use case for watching all projects
class WatchProjects {
  final ProjectRepository _repo;

  const WatchProjects(this._repo);

  /// Watches all projects as a stream
  Stream<Either<Failure, List<Project>>> call() => _repo.watchAll();
}

/// Use case for getting all projects once
class GetAllProjects {
  final ProjectRepository _repo;

  const GetAllProjects(this._repo);

  /// Gets all projects once
  Future<Either<Failure, List<Project>>> call() => _repo.getAllOnce();
}

/// Use case for getting a single project by ID
class GetProject {
  final ProjectRepository _repo;

  const GetProject(this._repo);

  /// Gets a project by ID
  Future<Either<Failure, Project?>> call(String projectId) => _repo.getById(projectId);
}
