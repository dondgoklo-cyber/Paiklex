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

  // Kanban column status - separate from orderIndex
  // orderIndex is for sorting within a column, status is for column assignment
  final String? kanbanStatus; // 'todo', 'doing', 'done'

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

  /// Completes the task and returns the completed version
  /// For recurring tasks, the caller should create a new task for the next occurrence
  Task complete() {
    final now = DateTime.now().toUtc();
    
    if (isCompleted) {
      return this;
    }
    
    return copyWith(
      isCompleted: true,
      completedAt: () => now,
      updatedAt: now,
    );
  }

  /// Creates a new task instance for the next recurrence occurrence
  /// Returns null if this task is not recurring or has no due date
  Task? createNextOccurrence() {
    if (!isRecurring || dueDate == null) return null;
    
    final now = DateTime.now().toUtc();
    final nextDueDate = _calculateNextOccurrence(dueDate!, now);
    
    if (nextDueDate == null) return null;
    
    return Task(
      id: '', // Empty string, will be replaced with UUID by repository
      projectId: projectId,
      parentTaskId: id, // Link to original task
      content: content,
      description: description,
      isCompleted: false,
      priority: priority,
      dueDate: nextDueDate,
      duration: duration,
      tags: tags,
      recurrence: recurrence,
      orderIndex: orderIndex,
      createdAt: now,
      updatedAt: now,
      completedAt: null,
    );
  }

  /// Calculates the next occurrence date based on recurrence pattern
  /// Returns null if recurrence is not set or dueDate is null
  DateTime? _calculateNextOccurrence(DateTime currentDue, DateTime now) {
    if (recurrence == null) return null;
    
    // currentDue is the original due date of this occurrence
    // We need to find the next occurrence after now
    
    DateTime next;
    
    switch (recurrence) {
      case 'daily':
        // Next day from the original due date pattern
        next = DateTime.utc(currentDue.year, currentDue.month, currentDue.day + 1);
        // If we're past that date, find the next one
        while (next.isBefore(now) || next == now) {
          next = next.add(const Duration(days: 1));
        }
        return next;
      case 'weekly':
        // Same day of week, next week
        next = currentDue.add(const Duration(days: 7));
        while (next.isBefore(now) || next == now) {
          next = next.add(const Duration(days: 7));
        }
        return next;
      case 'monthly':
        // Same day of month, next month
        next = _addMonths(currentDue, 1);
        while (next.isBefore(now) || next == now) {
          next = _addMonths(next, 1);
        }
        return next;
      case 'yearly':
        // Same day of year, next year
        next = _addYears(currentDue, 1);
        while (next.isBefore(now) || next == now) {
          next = _addYears(next, 1);
        }
        return next;
      default:
        return null;
    }
  }

  /// Helper to add months to a date, handling overflow
  DateTime _addMonths(DateTime date, int months) {
    var year = date.year + (date.month + months - 1) ~/ 12;
    var month = (date.month + months - 1) % 12 + 1;
    var day = date.day;
    
    // Handle day overflow (e.g., Jan 31 -> Feb)
    var result = DateTime.utc(year, month, day);
    if (result.month != month) {
      // Day doesn't exist in target month, use last day
      result = DateTime.utc(year, month + 1, 0);
    }
    return result;
  }

  /// Helper to add years to a date, handling leap year edge case
  DateTime _addYears(DateTime date, int years) {
    final newYear = date.year + years;
    
    // Special handling for Feb 29
    if (date.month == 2 && date.day == 29) {
      // Check if new year is a leap year
      final isLeap = (newYear % 4 == 0 && newYear % 100 != 0) || (newYear % 400 == 0);
      if (!isLeap) {
        return DateTime.utc(newYear, 2, 28);
      }
    }
    
    return DateTime.utc(newYear, date.month, date.day);
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
