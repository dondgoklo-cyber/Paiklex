part of 'habit_list_cubit.dart';

/// Status of habit list operations
enum HabitListStatus {
  initial,
  loading,
  loaded,
  error,
}

/// State for habit list
class HabitListState extends Equatable {
  final HabitListStatus status;
  final List<Habit> habits;
  final String? errorMessage;

  const HabitListState({
    this.status = HabitListStatus.initial,
    this.habits = const [],
    this.errorMessage,
  });

  /// Creates a copy with optional changes
  HabitListState copyWith({
    HabitListStatus? status,
    List<Habit>? habits,
    String? errorMessage,
  }) {
    return HabitListState(
      status: status ?? this.status,
      habits: habits ?? this.habits,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, habits, errorMessage];
}
