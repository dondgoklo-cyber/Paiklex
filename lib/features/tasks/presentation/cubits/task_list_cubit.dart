import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/undo_manager.dart';
import '../../domain/entities/task.dart';
import '../../domain/usecases/watch_tasks.dart';
import '../../domain/usecases/toggle_task.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/create_task.dart';

part 'task_list_state.dart';

/// Cubit for managing task list state
class TaskListCubit extends Cubit<TaskListState> {
  final WatchAllTasks _watchAll;
  final ToggleTask _toggle;
  final DeleteTask _delete;
  final CreateTask _create;
  StreamSubscription<Either<Failure, List<Task>>>? _sub;

  TaskListCubit(this._watchAll, this._toggle, this._delete, this._create)
      : super(const TaskListState());

  /// Starts watching all tasks
  void watch() {
    emit(state.copyWith(status: TaskListStatus.loading));
    _sub?.cancel();
    _sub = _watchAll().listen(
      (result) {
        result.fold(
          (f) => emit(state.copyWith(
            status: TaskListStatus.error,
            errorMessage: f.message,
          )),
          (tasks) => emit(state.copyWith(
            status: TaskListStatus.loaded,
            tasks: tasks,
          )),
        );
      },
      onError: (e) => emit(state.copyWith(
        status: TaskListStatus.error,
        errorMessage: e.toString(),
      )),
    );
  }

  /// Toggles task completion
  Future<void> toggle(String id) => _toggle(id).then((_) {});

  /// Deletes a task with undo support
  Future<String?> delete(String id) async {
    // Get the task before deletion for undo
    final task = state.tasks.firstWhere((t) => t.id == id);
    
    final result = await _delete(id);
    
    return result.fold(
      (failure) {
        // Return null if deletion failed
        return null;
      },
      (_) {
        // Add undo action
        final actionId = undoManager.addAction(
          type: UndoActionType.deleteTask,
          entity: task,
          onUndo: () async {
            await _create(task.copyWith(id: id));
          },
        );
        return actionId;
      },
    );
  }

  /// Restores a deleted task
  Future<void> restoreTask(Task task) async {
    await _create(task);
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
