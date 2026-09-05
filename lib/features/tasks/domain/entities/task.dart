import 'package:equatable/equatable.dart';
import 'priority.dart';

/// Task entity representing a single task in the system
class Task extends Equatable {
  final String id;
  final String? projectId;
  final String? parentTaskId;
  final String content;
  final String? description;
  final bool isCompleted;
  final TaskPriority priority;
  final DateTime? dueDate; // ВСЕГДА UTC
  final int? duration; // in minutes
  final List<String> tags;
  final String? recurrence; // "daily", "weekly", "monthly"
  final int orderIndex;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  const Task({
    required this.id,
    this.projectId,
    this.parentTaskId,
    required this.content,
    this.description,
    this.isCompleted = false,
    this.priority = TaskPriority.medium,
    this.dueDate,
    this.duration,
    this.tags = const [],
    this.recurrence,
    this.orderIndex = 0,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });

  /// Creates a copy with optional changes
  Task copyWith({
    String? id,
    String? Function()? projectId,
    String? Function()? parentTaskId,
    String? content,
    String? Function()? description,
    bool? isCompleted,
    TaskPriority? priority,
    DateTime? Function()? dueDate,
    int? Function()? duration,
    List<String>? tags,
    String? Function()? recurrence,
    int? orderIndex,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? Function()? completedAt,
  }) {
    return Task(
      id: id ?? this.id,
      projectId: projectId != null ? projectId() : this.projectId,
      parentTaskId: parentTaskId != null ? parentTaskId() : this.parentTaskId,
      content: content ?? this.content,
      description: description != null ? description() : this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      dueDate: dueDate != null ? dueDate() : this.dueDate,
      duration: duration != null ? duration() : this.duration,
      tags: tags ?? this.tags,
      recurrence: recurrence != null ? recurrence() : this.recurrence,
      orderIndex: orderIndex ?? this.orderIndex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt != null ? completedAt() : this.completedAt,
    );
  }

  /// Toggles the completed status
  Task toggle() {
    final now = DateTime.now().toUtc();
    final newCompleted = !isCompleted;
    return copyWith(
      isCompleted: newCompleted,
      completedAt: () => newCompleted ? now : null,
      updatedAt: now,
    );
  }

  /// Returns true if this task has subtasks
  bool get hasSubtasks => parentTaskId != null;

  /// Returns true if this task is a subtask
  bool get isSubtask => parentTaskId != null;

  /// Returns true if this task has a due date
  bool get hasDueDate => dueDate != null;

  /// Returns true if this task is overdue
  bool get isOverdue {
    if (dueDate == null) return false;
    return dueDate!.isBefore(DateTime.now().toUtc());
  }

  /// Returns true if this task is recurring
  bool get isRecurring => recurrence != null;

  @override
  List<Object?> get props => [
        id,
        projectId,
        parentTaskId,
        content,
        description,
        isCompleted,
        priority,
        dueDate,
        duration,
        tags,
        recurrence,
        orderIndex,
        createdAt,
        updatedAt,
        completedAt,
      ];
}
