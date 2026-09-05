import 'package:fpdart/fpdart.dart';
import '../entities/project.dart';
import '../../../../core/errors/failures.dart';

/// Abstract contract for project repository
abstract class ProjectRepository {
  /// Watches all projects as a stream
  Stream<Either<Failure, List<Project>>> watchAll();

  /// Gets all projects once
  Future<Either<Failure, List<Project>>> getAllOnce();

  /// Gets a project by ID
  Future<Either<Failure, Project?>> getById(String projectId);

  /// Creates a new project
  Future<Either<Failure, Project>> create(Project project);

  /// Updates an existing project
  Future<Either<Failure, Project>> update(Project project);

  /// Deletes a project by ID
  Future<Either<Failure, void>> delete(String projectId);

  /// Archives or unarchives a project
  Future<Either<Failure, Project>> toggleArchive(String projectId);
}
