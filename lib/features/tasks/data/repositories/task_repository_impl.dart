import 'dart:async';
import 'package:drift/drift.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logger/logger.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../../../../database/app_database.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../models/task_model.dart';

/// Implementation of TaskRepository using Drift database
class TaskRepositoryImpl implements TaskRepository {
  final TaskDao _dao;
  final Logger _logger = Logger('TaskRepository');

  TaskRepositoryImpl(this._dao);

  @override
  Stream<Either<Failure, List<Task>>> watchAll() {
    return _dao.watchAll().map(
      (rows) => Right<Failure, List<Task>>(
        rows.map((r) => r.toEntity()).toList(),
      ),
    ).handleError(
      (Object e, StackTrace s) {
        _logger.e('watchAll failed', error: e, stackTrace: s);
      },
    );
  }

  @override
  Stream<Either<Failure, List<Task>>> watchByProject(String? projectId) {
    return _dao.watchByProject(projectId).map(
      (rows) => Right<Failure, List<Task>>(
        rows.map((r) => r.toEntity()).toList(),
      ),
    );
  }

  @override
  Future<Either<Failure, Task>> create(Task task) async {
    try {
      await _dao.insert(task.toCompanion());
      return Right(task);
    } catch (e, s) {
      _logger.e('create failed', error: e, stackTrace: s);
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Task>> update(Task task) async {
    try {
      final updated = task.copyWith(updatedAt: AppDateUtils.nowUtc());
      final ok = await _dao.update(updated.toCompanion());
      return ok ? Right(updated) : const Left(DatabaseFailure('Update failed'));
    } catch (e, s) {
      _logger.e('update failed', error: e, stackTrace: s);
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> delete(String taskId) async {
    try {
      final count = await _dao.delete(taskId);
      return count > 0
          ? const Right(null)
          : Left(NotFoundFailure('Task', taskId));
    } catch (e, s) {
      _logger.e('delete failed', error: e, stackTrace: s);
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Task>> toggle(String taskId) async {
    try {
      final ok = await _dao.toggleComplete(taskId);
      if (!ok) return Left(NotFoundFailure('Task', taskId));
      final updated = await _dao.getById(taskId);
      if (updated == null) return Left(NotFoundFailure('Task', taskId));
      return Right(updated.toEntity());
    } catch (e, s) {
      _logger.e('toggle failed', error: e, stackTrace: s);
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> reorder(String taskId, int newIndex) async {
    try {
      final current = await _dao.getById(taskId);
      if (current == null) return Left(NotFoundFailure('Task', taskId));
      final updated = current.copyWith(
        orderIndex: newIndex,
        updatedAt: AppDateUtils.toMillisUtc(AppDateUtils.nowUtc()),
      );
      await _dao.update(updated);
      return const Right(null);
    } catch (e, s) {
      _logger.e('reorder failed', error: e, stackTrace: s);
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Task?>> getById(String taskId) async {
    try {
      final row = await _dao.getById(taskId);
      return Right(row?.toEntity());
    } catch (e, s) {
      _logger.e('getById failed', error: e, stackTrace: s);
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Task>>> getAllOnce() async {
    try {
      final rows = await _dao.getAllOnce();
      return Right(rows.map((r) => r.toEntity()).toList());
    } catch (e, s) {
      _logger.e('getAllOnce failed', error: e, stackTrace: s);
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
