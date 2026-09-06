import "package:fpdart/fpdart.dart" as fpdart;
import 'package:drift/drift.dart';
import 'package:logger/logger.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/habit.dart';
import '../../domain/repositories/habit_repository.dart';
import '../models/habit_model.dart';
import '../../../../database/app_database.dart';
import '../../../../core/utils/date_utils.dart';

/// Implementation of HabitRepository using Drift
class HabitRepositoryImpl implements HabitRepository {
  final AppDatabase _db;
  final Logger _logger;

  HabitRepositoryImpl(this._db) : _logger = Logger('HabitRepositoryImpl');

  @override
  Stream<fpdart.Either<Failure, List<Habit>>> watchAll() {
    return _db.habitDao.watchAll().map((rows) {
      try {
        return fpdart.Right(rows.map((row) => row.toEntity()).toList());
      } catch (e, s) {
        _logger.e('Failed to map habit rows', error: e, stackTrace: s);
        return fpdart.Left(DatabaseFailure(e.toString()));
      }
    }).handleError((e, s) {
      _logger.e('Failed to watch habits', error: e, stackTrace: s);
      return fpdart.Left(DatabaseFailure(e.toString()));
    });
  }

  @override
  Future<fpdart.Either<Failure, List<Habit>>> getAllOnce() async {
    try {
      final rows = await _db.habitDao.getAllOnce();
      return fpdart.Right(rows.map((row) => row.toEntity()).toList());
    } catch (e, s) {
      _logger.e('Failed to get all habits', error: e, stackTrace: s);
      return fpdart.Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<fpdart.Either<Failure, Habit?>> getById(String habitId) async {
    try {
      final row = await _db.habitDao.getById(habitId);
      return fpdart.Right(row?.toEntity());
    } catch (e, s) {
      _logger.e('Failed to get habit by ID', error: e, stackTrace: s);
      return fpdart.Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<fpdart.Either<Failure, Habit>> create(Habit habit) async {
    try {
      final now = DateTime.now().toUtc();
      final updatedHabit = habit.copyWith(
        createdAt: now,
        updatedAt: now,
      );
      await _db.habitDao.insertHabit(updatedHabit.toCompanion());
      return fpdart.Right(updatedHabit);
    } catch (e, s) {
      _logger.e('Failed to create habit', error: e, stackTrace: s);
      return fpdart.Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<fpdart.Either<Failure, Habit>> update(Habit habit) async {
    try {
      final updatedHabit = habit.copyWith(
        updatedAt: DateTime.now().toUtc(),
      );
      await _db.habitDao.updateHabit(updatedHabit.toCompanion());
      return fpdart.Right(updatedHabit);
    } catch (e, s) {
      _logger.e('Failed to update habit', error: e, stackTrace: s);
      return fpdart.Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<fpdart.Either<Failure, void>> delete(String habitId) async {
    try {
      // First delete all reminders for this habit
      await _db.reminderDao.deleteRemindersByHabit(habitId);
      
      await _db.habitDao.deleteHabit(habitId);
      return const fpdart.Right(null);
    } catch (e, s) {
      _logger.e('Failed to delete habit', error: e, stackTrace: s);
      return fpdart.Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<fpdart.Either<Failure, Habit>> complete(String habitId) async {
    try {
      final row = await _db.habitDao.getById(habitId);
      if (row == null) {
        return fpdart.Left(NotFoundFailure('Habit', habitId));
      }

      final habit = row.toEntity();
      final updatedHabit = habit.complete();
      await _db.habitDao.updateHabit(updatedHabit.toCompanion());
      return fpdart.Right(updatedHabit);
    } catch (e, s) {
      _logger.e('Failed to complete habit', error: e, stackTrace: s);
      return fpdart.Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<fpdart.Either<Failure, List<Habit>>> getDueToday() async {
    try {
      final now = AppDateUtils.nowUtc();
      final today = AppDateUtils.dateOnlyUtc(now);
      final rows = await _db.habitDao.getAllOnce();
      
      final habits = rows.map((row) => row.toEntity()).toList();
      final dueToday = habits.where((h) => h.isDueToday).toList();
      
      return fpdart.Right(dueToday);
    } catch (e, s) {
      _logger.e('Failed to get habits due today', error: e, stackTrace: s);
      return fpdart.Left(DatabaseFailure(e.toString()));
    }
  }
}
