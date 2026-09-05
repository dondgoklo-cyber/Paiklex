import 'package:fpdart/fpdart.dart';
import 'package:drift/drift.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';
import '../models/project_model.dart';
import '../../../../database/app_database.dart';

/// Implementation of ProjectRepository using Drift
class ProjectRepositoryImpl implements ProjectRepository {
  final AppDatabase _db;
  final Logger _logger;

  ProjectRepositoryImpl(this._db) : _logger = AppLogger.forService('ProjectRepositoryImpl');

  @override
  Stream<Either<Failure, List<Project>>> watchAll() {
    return _db.projectDao.watchAll().map((rows) {
      try {
        return Right(rows.map((row) => row.toEntity()).toList());
      } catch (e, s) {
        _logger.e('Failed to map project rows', error: e, stackTrace: s);
        return Left(DatabaseFailure(e.toString()));
      }
    }).handleError((e, s) {
      _logger.e('Failed to watch projects', error: e, stackTrace: s);
      return Left(DatabaseFailure(e.toString()));
    });
  }

  @override
  Future<Either<Failure, List<Project>>> getAllOnce() async {
    try {
      final rows = await _db.projectDao.getAllOnce();
      return Right(rows.map((row) => row.toEntity()).toList());
    } catch (e, s) {
      _logger.e('Failed to get all projects', error: e, stackTrace: s);
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Project?>> getById(String projectId) async {
    try {
      final row = await _db.projectDao.getById(projectId);
      return Right(row?.toEntity());
    } catch (e, s) {
      _logger.e('Failed to get project by ID', error: e, stackTrace: s);
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Project>> create(Project project) async {
    try {
      final now = DateTime.now().toUtc();
      final updatedProject = project.copyWith(
        createdAt: now,
        updatedAt: now,
      );
      await _db.projectDao.insert(updatedProject.toCompanion());
      return Right(updatedProject);
    } catch (e, s) {
      _logger.e('Failed to create project', error: e, stackTrace: s);
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Project>> update(Project project) async {
    try {
      final updatedProject = project.copyWith(
        updatedAt: DateTime.now().toUtc(),
      );
      await _db.projectDao.update(updatedProject.toCompanion());
      return Right(updatedProject);
    } catch (e, s) {
      _logger.e('Failed to update project', error: e, stackTrace: s);
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> delete(String projectId) async {
    try {
      await _db.projectDao.delete(projectId);
      return const Right(null);
    } catch (e, s) {
      _logger.e('Failed to delete project', error: e, stackTrace: s);
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Project>> toggleArchive(String projectId) async {
    try {
      final row = await _db.projectDao.getById(projectId);
      if (row == null) {
        return Left(NotFoundFailure('Project not found'));
      }

      final project = row.toEntity();
      final updatedProject = project.toggleArchive();
      await _db.projectDao.update(updatedProject.toCompanion());
      return Right(updatedProject);
    } catch (e, s) {
      _logger.e('Failed to toggle project archive', error: e, stackTrace: s);
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
