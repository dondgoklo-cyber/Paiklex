import "package:fpdart/fpdart.dart" as fpdart;
import '../entities/project.dart';
import '../repositories/project_repository.dart';
import '../../../../core/errors/failures.dart';

/// Use case for updating a project
class UpdateProject {
  final ProjectRepository _repo;

  const UpdateProject(this._repo);

  /// Updates a project
  Future<fpdart.Either<Failure, Project>> call(Project project) async {
    if (project.name.trim().isEmpty) {
      return fpdart.Left(ValidationFailure('Project name cannot be empty'));
    }

    return _repo.update(project);
  }
}

/// Use case for deleting a project
class DeleteProject {
  final ProjectRepository _repo;

  const DeleteProject(this._repo);

  /// Deletes a project by ID
  Future<fpdart.Either<Failure, void>> call(String projectId) => _repo.delete(projectId);
}

/// Use case for toggling project archive status
class ToggleProjectArchive {
  final ProjectRepository _repo;

  const ToggleProjectArchive(this._repo);

  /// Archives or unarchives a project
  Future<fpdart.Either<Failure, Project>> call(String projectId) => _repo.toggleArchive(projectId);
}
