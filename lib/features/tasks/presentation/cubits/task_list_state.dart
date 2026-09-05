part of 'task_list_cubit.dart';

/// Status of task list loading
enum TaskListStatus { initial, loading, loaded, error }

/// State for task list cubit
class TaskListState extends Equatable {
  final TaskListStatus status;
  final List<Task> tasks;
  final String? errorMessage;

  const TaskListState({
    this.status = TaskListStatus.initial,
    this.tasks = const [],
    this.errorMessage,
  });

  TaskListState copyWith({
    TaskListStatus? status,
    List<Task>? tasks,
    String? errorMessage,
  }) {
    return TaskListState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, tasks, errorMessage];
}
