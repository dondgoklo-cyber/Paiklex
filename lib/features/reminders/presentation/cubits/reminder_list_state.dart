part of 'reminder_list_cubit.dart';

/// Status of reminder list operations
enum ReminderListStatus {
  initial,
  loading,
  loaded,
  error,
}

/// State for reminder list
class ReminderListState extends Equatable {
  final ReminderListStatus status;
  final List<Reminder> reminders;
  final String? errorMessage;

  const ReminderListState({
    this.status = ReminderListStatus.initial,
    this.reminders = const [],
    this.errorMessage,
  });

  /// Creates a copy with optional changes
  ReminderListState copyWith({
    ReminderListStatus? status,
    List<Reminder>? reminders,
    String? errorMessage,
  }) {
    return ReminderListState(
      status: status ?? this.status,
      reminders: reminders ?? this.reminders,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, reminders, errorMessage];
}
