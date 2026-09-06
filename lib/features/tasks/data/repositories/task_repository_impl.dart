import 'dart:async';
import 'package:drift/drift.dart';
import "package:fpdart/fpdart.dart" as fpdart;
import 'package:logger/logger.dart';
import '../../../../core/errors/failures.dart';
import '../../../../database/app_database.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../models/task_model.dart';

/// Implementation of TaskRepository using Drift database
class TaskRepositoryImpl implements TaskRepository {
  final TaskDao _dao;
  final AppDatabase _db;
  final Logger _logger = Logger('TaskRepository');

  TaskRepositoryImpl(this._dao, this._db);

  @override
  Stream<fpdart.Either<Failure, List<Task>>> watchAll() {
    return _dao.watchAll().map(
      (rows) => fpdart.Right<Failure, List<Task>>(
        rows.map((r) => r.toEntity()).toList(),
      ),
    ).handleError(
      (Object e, StackTrace s) {
        _logger.e('watchAll failed', error: e, stackTrace: s);
      },
    );
  }

  @override
  Stream<fpdart.Either<Failure, List<Task>>> watchByProject(String? projectId) {
    return _dao.watchByProject(projectId).map(
      (rows) => fpdart.Right<Failure, List<Task>>(
        rows.map((r) => r.toEntity()).toList(),
      ),
    );
  }

  @override
  Future<fpdart.Either<Failure, Task>> create(Task task) async {
    try {
      await _dao.insert(task.toCompanion());
      return fpdart.Right(task);
    } catch (e, s) {
      _logger.e('create failed', error: e, stackTrace: s);
      return fpdart.Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<fpdart.Either<Failure, Task>> update(Task task) async {
    try {
      final updated = task.copyWith(updatedAt: AppDateUtils.nowUtc());
      final ok = await _dao.updateTask(updated.toCompanion());
      return ok > 0 ? fpdart.Right(updated) : const fpdart.Left(DatabaseFailure('Update failed'));
    } catch (e, s) {
      _logger.e('update failed', error: e, stackTrace: s);
      return fpdart.Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<fpdart.Either<Failure, void>> delete(String taskId) async {
    try {
      // First delete all reminders for this task
      await _db.reminderDao.deleteRemindersByTask(taskId);
      
      final count = await _dao.deleteTask(taskId);
      return count > 0
          ? const fpdart.Right(null)
          : fpdart.Left(NotFoundFailure('Task', taskId));
    } catch (e, s) {
      _logger.e('delete failed', error: e, stackTrace: s);
      return fpdart.Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<fpdart.Either<Failure, Task>> toggle(String taskId) async {
    try {
      final ok = await _dao.toggleComplete(taskId);
      if (!ok) return fpdart.Left(NotFoundFailure('Task', taskId));
      final updated = await _dao.getById(taskId);
      if (updated == null) return fpdart.Left(NotFoundFailure('Task', taskId));
      return fpdart.Right(updated.toEntity());
    } catch (e, s) {
      _logger.e('toggle failed', error: e, stackTrace: s);
      return fpdart.Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<fpdart.Either<Failure, void>> reorder(String taskId, int newIndex) async {
    try {
      final current = await _dao.getById(taskId);
      if (current == null) return fpdart.Left(NotFoundFailure('Task', taskId));
      final now = AppDateUtils.nowUtc();
      final updated = current.copyWith(
        orderIndex: newIndex,
        updatedAt: AppDateUtils.toMillisUtc(now),
      );
      await _dao.updateTask(updated.toCompanion());
      return const fpdart.Right(null);
    } catch (e, s) {
      _logger.e('reorder failed', error: e, stackTrace: s);
      return fpdart.Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<fpdart.Either<Failure, Task?>> getById(String taskId) async {
    try {
      final row = await _dao.getById(taskId);
      return fpdart.Right(row?.toEntity());
    } catch (e, s) {
      _logger.e('getById failed', error: e, stackTrace: s);
      return fpdart.Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<fpdart.Either<Failure, List<Task>>> getAllOnce() async {
    try {
      final rows = await _dao.getAllOnce();
      return fpdart.Right(rows.map((r) => r.toEntity()).toList());
    } catch (e, s) {
      _logger.e('getAllOnce failed', error: e, stackTrace: s);
      return fpdart.Left(DatabaseFailure(e.toString()));
    }
  }
}
