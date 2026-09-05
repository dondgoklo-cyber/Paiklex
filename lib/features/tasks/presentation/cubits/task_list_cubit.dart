import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/task.dart';
import '../../domain/usecases/watch_tasks.dart';
import '../../domain/usecases/toggle_task.dart';
import '../../domain/usecases/delete_task.dart';

part 'task_list_state.dart';

/// Cubit for managing task list state
class TaskListCubit extends Cubit<TaskListState> {
  final WatchAllTasks _watchAll;
  final ToggleTask _toggle;
  final DeleteTask _delete;
  StreamSubscription<Either<Failure, List<Task>>>? _sub;

  TaskListCubit(this._watchAll, this._toggle, this._delete)
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

  /// Deletes a task
  Future<void> delete(String id) => _delete(id).then((_) {});

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
