import "package:fpdart/fpdart.dart" as fpdart;
import '../entities/project.dart';
import '../repositories/project_repository.dart';
import '../../../../core/errors/failures.dart';
import 'package:uuid/uuid.dart';

/// Use case for creating a new project
class CreateProject {
  final ProjectRepository _repo;
  final Uuid _uuid;

  const CreateProject(this._repo, this._uuid);

  /// Creates a new project
  Future<fpdart.Either<Failure, Project>> call(String name, {int? color}) async {
    final now = DateTime.now().toUtc();
    final project = Project(
      id: _uuid.v4(),
      name: name.trim(),
      color: color ?? 0xFF2196F3,
      createdAt: now,
      updatedAt: now,
    );

    if (project.name.isEmpty) {
      return fpdart.Left(ValidationFailure('Project name cannot be empty'));
    }

    return _repo.create(project);
  }
}
