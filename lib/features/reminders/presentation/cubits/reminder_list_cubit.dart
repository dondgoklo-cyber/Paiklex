import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/undo_manager.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/reminder.dart';
import '../../domain/usecases/watch_reminders.dart';
import '../../domain/usecases/create_reminder.dart';
import '../../domain/usecases/update_reminder.dart';
import '../../domain/usecases/delete_reminder.dart';
import '../../domain/usecases/schedule_reminder.dart';
import '../../domain/usecases/cancel_reminder.dart';

part 'reminder_list_state.dart';

/// Cubit for managing reminder list state
class ReminderListCubit extends Cubit<ReminderListState> {
  final WatchReminders _watchReminders;
  final CreateReminder _createReminder;
  final UpdateReminder _updateReminder;
  final DeleteReminder _deleteReminder;
  final ScheduleReminder _scheduleReminder;
  final CancelReminder _cancelReminder;
  final Logger _logger;

  StreamSubscription? _subscription;

  ReminderListCubit(
    this._watchReminders,
    this._createReminder,
    this._updateReminder,
    this._deleteReminder,
    this._scheduleReminder,
    this._cancelReminder,
  ) : _logger = AppLogger.forService('ReminderListCubit'),
       super(const ReminderListState());

  /// Starts watching reminders
  void watch() {
    _subscription?.cancel();
    emit(state.copyWith(status: ReminderListStatus.loading));

    _subscription = _watchReminders().listen(
      (result) {
        result.fold(
          (failure) {
            _logger.e('Failed to watch reminders', error: failure);
            emit(state.copyWith(
              status: ReminderListStatus.error,
              errorMessage: failure.message,
            ));
          },
          (reminders) {
            emit(state.copyWith(
              status: ReminderListStatus.loaded,
              reminders: reminders,
              errorMessage: null,
            ));
          },
        );
      },
      onError: (e, s) {
        _logger.e('Error watching reminders', error: e, stackTrace: s);
        emit(state.copyWith(
          status: ReminderListStatus.error,
          errorMessage: e.toString(),
        ));
      },
    );
  }

  /// Creates a new reminder
  Future<void> create({
    String? taskId,
    String? habitId,
    required DateTime triggerAt,
    required String title,
    String? body,
  }) async {
    final result = await _createReminder(
      taskId: taskId,
      habitId: habitId,
      triggerAt: triggerAt,
      title: title,
      body: body,
    );
    result.fold(
      (failure) {
        _logger.e('Failed to create reminder', error: failure);
        emit(state.copyWith(errorMessage: failure.message));
      },
      (reminder) {
        _logger.d('Reminder created: ${reminder.id}');
        // Stream will emit new state automatically
      },
    );
  }

  /// Schedules a reminder
  Future<void> schedule(Reminder reminder) async {
    final result = await _scheduleReminder(reminder);
    result.fold(
      (failure) {
        _logger.e('Failed to schedule reminder', error: failure);
        emit(state.copyWith(errorMessage: failure.message));
      },
      (scheduledReminder) {
        _logger.d('Reminder scheduled: ${scheduledReminder.id}');
        // Stream will emit new state automatically
      },
    );
  }

  /// Updates a reminder
  Future<void> update(Reminder reminder) async {
    final result = await _updateReminder(reminder);
    result.fold(
      (failure) {
        _logger.e('Failed to update reminder', error: failure);
        emit(state.copyWith(errorMessage: failure.message));
      },
      (updatedReminder) {
        _logger.d('Reminder updated: ${updatedReminder.id}');
        // Stream will emit new state automatically
      },
    );
  }

  /// Deletes a reminder with undo support
  Future<String?> delete(String reminderId) async {
    // Get the reminder before deletion for undo
    final reminder = state.reminders.firstWhere((r) => r.id == reminderId);
    
    final result = await _deleteReminder(reminderId);
    
    return result.fold(
      (failure) {
        _logger.e('Failed to delete reminder', error: failure);
        emit(state.copyWith(errorMessage: failure.message));
        return null;
      },
      (_) {
        _logger.d('Reminder deleted: $reminderId');
        // Add undo action
        final actionId = undoManager.addAction(
          type: UndoActionType.deleteReminder,
          entity: reminder,
          onUndo: () async {
            await _createReminder(
              taskId: reminder.taskId,
              habitId: reminder.habitId,
              triggerAt: reminder.triggerAt,
              title: reminder.title,
              body: reminder.body,
            );
          },
        );
        return actionId;
      },
    );
  }

  /// Cancels a reminder
  Future<void> cancel(String reminderId) async {
    final result = await _cancelReminder(reminderId);
    result.fold(
      (failure) {
        _logger.e('Failed to cancel reminder', error: failure);
        emit(state.copyWith(errorMessage: failure.message));
      },
      (_) {
        _logger.d('Reminder cancelled: $reminderId');
        // Stream will emit new state automatically
      },
    );
  }

  /// Restores a deleted reminder
  Future<void> restoreReminder(Reminder reminder) async {
    await _createReminder(
      taskId: reminder.taskId,
      habitId: reminder.habitId,
      triggerAt: reminder.triggerAt,
      title: reminder.title,
      body: reminder.body,
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
