import 'package:equatable/equatable.dart';

/// Reminder entity representing a scheduled notification
class Reminder extends Equatable {
  final String id;
  final String? taskId;
  final String? habitId;
  final DateTime triggerAt; // UTC timestamp when reminder should fire
  final String title;
  final String? body;
  final bool isTriggered;
  final DateTime createdAt;

  const Reminder({
    required this.id,
    this.taskId,
    this.habitId,
    required this.triggerAt,
    required this.title,
    this.body,
    this.isTriggered = false,
    required this.createdAt,
  });

  /// Creates a copy with optional changes
  Reminder copyWith({
    String? id,
    String? Function()? taskId,
    String? Function()? habitId,
    DateTime? triggerAt,
    String? title,
    String? Function()? body,
    bool? isTriggered,
    DateTime? createdAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      taskId: taskId != null ? taskId() : this.taskId,
      habitId: habitId != null ? habitId() : this.habitId,
      triggerAt: triggerAt ?? this.triggerAt,
      title: title ?? this.title,
      body: body != null ? body() : this.body,
      isTriggered: isTriggered ?? this.isTriggered,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Marks the reminder as triggered
  Reminder markAsTriggered() {
    return copyWith(isTriggered: true);
  }

  /// Returns true if this reminder is for a specific date
  bool get isForDate => taskId != null || habitId != null;

  @override
  List<Object?> get props => [
        id,
        taskId,
        habitId,
        triggerAt,
        title,
        body,
        isTriggered,
        createdAt,
      ];
}
