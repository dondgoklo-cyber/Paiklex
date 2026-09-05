import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/undo_manager.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/habit.dart';
import '../../domain/usecases/watch_habits.dart';
import '../../domain/usecases/create_habit.dart';
import '../../domain/usecases/update_habit.dart';
import '../../domain/usecases/delete_habit.dart';
import '../../domain/usecases/complete_habit.dart';

part 'habit_list_state.dart';

/// Cubit for managing habit list state
class HabitListCubit extends Cubit<HabitListState> {
  final WatchHabits _watchHabits;
  final CreateHabit _createHabit;
  final UpdateHabit _updateHabit;
  final DeleteHabit _deleteHabit;
  final CompleteHabit _completeHabit;
  final Logger _logger;

  StreamSubscription? _subscription;

  HabitListCubit(
    this._watchHabits,
    this._createHabit,
    this._updateHabit,
    this._deleteHabit,
    this._completeHabit,
  ) : _logger = AppLogger.forService('HabitListCubit'),
       super(const HabitListState());

  /// Starts watching habits
  void watch() {
    _subscription?.cancel();
    emit(state.copyWith(status: HabitListStatus.loading));

    _subscription = _watchHabits().listen(
      (result) {
        result.fold(
          (failure) {
            _logger.e('Failed to watch habits', error: failure);
            emit(state.copyWith(
              status: HabitListStatus.error,
              errorMessage: failure.message,
            ));
          },
          (habits) {
            emit(state.copyWith(
              status: HabitListStatus.loaded,
              habits: habits,
              errorMessage: null,
            ));
          },
        );
      },
      onError: (e, s) {
        _logger.e('Error watching habits', error: e, stackTrace: s);
        emit(state.copyWith(
          status: HabitListStatus.error,
          errorMessage: e.toString(),
        ));
      },
    );
  }

  /// Creates a new habit
  Future<void> create(String title, {String? projectId, String frequency = 'daily'}) async {
    final result = await _createHabit(title, projectId: projectId, frequency: frequency);
    result.fold(
      (failure) {
        _logger.e('Failed to create habit', error: failure);
        emit(state.copyWith(errorMessage: failure.message));
      },
      (habit) {
        _logger.d('Habit created: ${habit.id}');
        // Stream will emit new state automatically
      },
    );
  }

  /// Updates a habit
  Future<void> update(Habit habit) async {
    final result = await _updateHabit(habit);
    result.fold(
      (failure) {
        _logger.e('Failed to update habit', error: failure);
        emit(state.copyWith(errorMessage: failure.message));
      },
      (updatedHabit) {
        _logger.d('Habit updated: ${updatedHabit.id}');
        // Stream will emit new state automatically
      },
    );
  }

  /// Deletes a habit with undo support
  Future<String?> delete(String habitId) async {
    // Get the habit before deletion for undo
    final habit = state.habits.firstWhere((h) => h.id == habitId);
    
    final result = await _deleteHabit(habitId);
    
    return result.fold(
      (failure) {
        _logger.e('Failed to delete habit', error: failure);
        emit(state.copyWith(errorMessage: failure.message));
        return null;
      },
      (_) {
        _logger.d('Habit deleted: $habitId');
        // Add undo action
        final actionId = undoManager.addAction(
          type: UndoActionType.deleteHabit,
          entity: habit,
          onUndo: () async {
            await _createHabit(
              habit.title,
              projectId: habit.projectId,
              frequency: habit.frequency,
            );
          },
        );
        return actionId;
      },
    );
  }

  /// Completes a habit with undo support
  Future<String?> complete(String habitId) async {
    // Get the habit before completion for undo
    final habit = state.habits.firstWhere((h) => h.id == habitId);
    final currentStreak = habit.streak;
    
    final result = await _completeHabit(habitId);
    
    return result.fold(
      (failure) {
        _logger.e('Failed to complete habit', error: failure);
        emit(state.copyWith(errorMessage: failure.message));
        return null;
      },
      (completedHabit) {
        _logger.d('Habit completed: ${completedHabit.id}');
        // Add undo action
        final actionId = undoManager.addAction(
          type: UndoActionType.completeHabit,
          entity: completedHabit,
          onUndo: () async {
            // Reset streak back to previous value
            await _updateHabit(
              completedHabit.copyWith(
                streak: currentStreak,
                lastCompletedAt: null,
              ),
            );
          },
        );
        return actionId;
      },
    );
  }

  /// Restores a deleted habit
  Future<void> restoreHabit(Habit habit) async {
    await _createHabit(
      habit.title,
      projectId: habit.projectId,
      frequency: habit.frequency,
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
