import "package:fpdart/fpdart.dart" as fpdart;
import '../entities/project.dart';
import '../../../../core/errors/failures.dart';

/// Abstract contract for project repository
abstract class ProjectRepository {
  /// Watches all projects as a stream
  Stream<fpdart.Either<Failure, List<Project>>> watchAll();

  /// Gets all projects once
  Future<fpdart.Either<Failure, List<Project>>> getAllOnce();

  /// Gets a project by ID
  Future<fpdart.Either<Failure, Project?>> getById(String projectId);

  /// Creates a new project
  Future<fpdart.Either<Failure, Project>> create(Project project);

  /// Updates an existing project
  Future<fpdart.Either<Failure, Project>> update(Project project);

  /// Deletes a project by ID
  Future<fpdart.Either<Failure, void>> delete(String projectId);

  /// Archives or unarchives a project
  Future<fpdart.Either<Failure, Project>> toggleArchive(String projectId);
}
