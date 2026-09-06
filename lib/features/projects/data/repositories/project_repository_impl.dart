import "package:fpdart/fpdart.dart" as fpdart;
import 'package:drift/drift.dart';
import 'package:logger/logger.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';
import '../models/project_model.dart';
import '../../../../database/app_database.dart';

/// Implementation of ProjectRepository using Drift
class ProjectRepositoryImpl implements ProjectRepository {
  final AppDatabase _db;
  final Logger _logger;

  ProjectRepositoryImpl(this._db) : _logger = Logger(
      printer: PrettyPrinter(
        colors: true,
        printTime: true,
        methodCount: 0,
      ),
    );

  @override
  Stream<fpdart.Either<Failure, List<Project>>> watchAll() {
    return _db.projectDao.watchAll().map((rows) {
      try {
        return fpdart.Right(rows.map((row) => row.toEntity()).toList());
      } catch (e, s) {
        Logger().e('Failed to map project rows', error: e, stackTrace: s);
        return fpdart.Left(DatabaseFailure(e.toString()));
      }
    }).handleError((e, s) {
      Logger().e('Failed to watch projects', error: e, stackTrace: s);
      return fpdart.Left(DatabaseFailure(e.toString()));
    });
  }

  @override
  Future<fpdart.Either<Failure, List<Project>>> getAllOnce() async {
    try {
      final rows = await _db.projectDao.getAllOnce();
      return fpdart.Right(rows.map((row) => row.toEntity()).toList());
    } catch (e, s) {
      Logger().e('Failed to get all projects', error: e, stackTrace: s);
      return fpdart.Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<fpdart.Either<Failure, Project?>> getById(String projectId) async {
    try {
      final row = await _db.projectDao.getById(projectId);
      return fpdart.Right(row?.toEntity());
    } catch (e, s) {
      Logger().e('Failed to get project by ID', error: e, stackTrace: s);
      return fpdart.Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<fpdart.Either<Failure, Project>> create(Project project) async {
    try {
      final now = DateTime.now().toUtc();
      final updatedProject = project.copyWith(
        createdAt: now,
        updatedAt: now,
      );
      await _db.projectDao.insertProject(updatedProject.toCompanion());
      return fpdart.Right(updatedProject);
    } catch (e, s) {
      Logger().e('Failed to create project', error: e, stackTrace: s);
      return fpdart.Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<fpdart.Either<Failure, Project>> update(Project project) async {
    try {
      final updatedProject = project.copyWith(
        updatedAt: DateTime.now().toUtc(),
      );
      await _db.projectDao.updateProject(updatedProject.toCompanion());
      return fpdart.Right(updatedProject);
    } catch (e, s) {
      Logger().e('Failed to update project', error: e, stackTrace: s);
      return fpdart.Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<fpdart.Either<Failure, void>> delete(String projectId) async {
    try {
      // First delete all tasks in this project
      final tasks = await _db.taskDao.getAllOnce();
      for (final task in tasks) {
        if (task.projectId == projectId) {
          await _db.taskDao.deleteTask(task.id);
        }
      }
      // Then delete all habits in this project
      final habits = await _db.habitDao.getAllOnce();
      for (final habit in habits) {
        if (habit.projectId == projectId) {
          await _db.habitDao.deleteHabit(habit.id);
        }
      }
      // Finally delete the project
      await _db.projectDao.deleteProject(projectId);
      return const fpdart.Right(null);
    } catch (e, s) {
      Logger().e('Failed to delete project', error: e, stackTrace: s);
      return fpdart.Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<fpdart.Either<Failure, Project>> toggleArchive(String projectId) async {
    try {
      final row = await _db.projectDao.getById(projectId);
      if (row == null) {
        return fpdart.Left(NotFoundFailure('Project not found'));
      }

      final project = row.toEntity();
      final updatedProject = project.toggleArchive();
      await _db.projectDao.updateProject(updatedProject.toCompanion());
      return fpdart.Right(updatedProject);
    } catch (e, s) {
      Logger().e('Failed to toggle project archive', error: e, stackTrace: s);
      return fpdart.Left(DatabaseFailure(e.toString()));
    }
  }
}
