import 'package:flutter_test/flutter_test.dart';
import 'package:monolith_tasks/features/tasks/domain/entities/task.dart';
import 'package:monolith_tasks/features/tasks/domain/entities/priority.dart';

void main() {
  final now = DateTime(2024, 1, 15, 12, 0, 0).toUtc();

  group('Task - Recurrence Logic', () {
    test('non-recurring task should not be recurring', () {
      // Arrange
      final task = Task(
        id: 'task-1',
        content: 'Test Task',
        priority: TaskPriority.medium,
        createdAt: now,
        updatedAt: now,
        recurrence: null,
      );

      // Act & Assert
      expect(task.isRecurring, false);
      expect(task.createNextOccurrence(), isNull);
    });

    test('daily recurring task should create next occurrence', () {
      // Arrange
      final dueDate = DateTime.utc(2024, 1, 15);
      final task = Task(
        id: 'task-1',
        content: 'Daily Task',
        priority: TaskPriority.medium,
        dueDate: dueDate,
        createdAt: now,
        updatedAt: now,
        recurrence: 'daily',
      );

      // Act
      final nextOccurrence = task.createNextOccurrence();

      // Assert
      expect(nextOccurrence, isNotNull);
      expect(nextOccurrence!.id, ''); // Empty ID to be filled by repository
      expect(nextOccurrence.content, 'Daily Task');
      expect(nextOccurrence.recurrence, 'daily');
      expect(nextOccurrence.parentTaskId, 'task-1');
      expect(nextOccurrence.isCompleted, false);
      
      // Next due date should be tomorrow
      expect(nextOccurrence.dueDate, DateTime.utc(2024, 1, 16));
    });

    test('weekly recurring task should create next occurrence', () {
      // Arrange
      final dueDate = DateTime.utc(2024, 1, 15); // Monday
      final task = Task(
        id: 'task-1',
        content: 'Weekly Task',
        priority: TaskPriority.medium,
        dueDate: dueDate,
        createdAt: now,
        updatedAt: now,
        recurrence: 'weekly',
      );

      // Act
      final nextOccurrence = task.createNextOccurrence();

      // Assert
      expect(nextOccurrence, isNotNull);
      expect(nextOccurrence!.dueDate, DateTime.utc(2024, 1, 22)); // Next Monday
    });

    test('monthly recurring task should create next occurrence', () {
      // Arrange
      final dueDate = DateTime.utc(2024, 1, 15);
      final task = Task(
        id: 'task-1',
        content: 'Monthly Task',
        priority: TaskPriority.medium,
        dueDate: dueDate,
        createdAt: now,
        updatedAt: now,
        recurrence: 'monthly',
      );

      // Act
      final nextOccurrence = task.createNextOccurrence();

      // Assert
      expect(nextOccurrence, isNotNull);
      expect(nextOccurrence!.dueDate, DateTime.utc(2024, 2, 15)); // Next month, same day
    });

    test('monthly recurring task on Jan 31 should handle Feb overflow', () {
      // Arrange
      final dueDate = DateTime.utc(2024, 1, 31); // Jan 31
      final task = Task(
        id: 'task-1',
        content: 'Monthly Task',
        priority: TaskPriority.medium,
        dueDate: dueDate,
        createdAt: now,
        updatedAt: now,
        recurrence: 'monthly',
      );

      // Act
      final nextOccurrence = task.createNextOccurrence();

      // Assert
      expect(nextOccurrence, isNotNull);
      // Jan 31 -> Feb 29 (2024 is leap year) or Feb 28 (non-leap)
      // Our implementation uses last day of month when overflow occurs
      expect(nextOccurrence!.dueDate, DateTime.utc(2024, 2, 29)); // 2024 is leap year
    });

    test('yearly recurring task should create next occurrence', () {
      // Arrange
      final dueDate = DateTime.utc(2024, 1, 15);
      final task = Task(
        id: 'task-1',
        content: 'Yearly Task',
        priority: TaskPriority.medium,
        dueDate: dueDate,
        createdAt: now,
        updatedAt: now,
        recurrence: 'yearly',
      );

      // Act
      final nextOccurrence = task.createNextOccurrence();

      // Assert
      expect(nextOccurrence, isNotNull);
      expect(nextOccurrence!.dueDate, DateTime.utc(2025, 1, 15)); // Next year
    });

    test('yearly recurring task on Feb 29 should handle non-leap year', () {
      // Arrange
      final dueDate = DateTime.utc(2024, 2, 29); // 2024 is leap year
      final task = Task(
        id: 'task-1',
        content: 'Yearly Task',
        priority: TaskPriority.medium,
        dueDate: dueDate,
        createdAt: now,
        updatedAt: now,
        recurrence: 'yearly',
      );

      // Act
      final nextOccurrence = task.createNextOccurrence();

      // Assert
      expect(nextOccurrence, isNotNull);
      // 2024 is leap, 2025 is not -> should use Feb 28
      expect(nextOccurrence!.dueDate, DateTime.utc(2025, 2, 28));
    });

    test('complete should return unchanged if already completed', () {
      // Arrange
      final task = Task(
        id: 'task-1',
        content: 'Test Task',
        isCompleted: true,
        priority: TaskPriority.medium,
        createdAt: now,
        updatedAt: now,
        completedAt: now,
      );

      // Act
      final completed = task.complete();

      // Assert
      expect(completed, task); // Should return the same instance
    });

    test('complete should mark task as completed', () {
      // Arrange
      final task = Task(
        id: 'task-1',
        content: 'Test Task',
        isCompleted: false,
        priority: TaskPriority.medium,
        createdAt: now,
        updatedAt: now,
      );

      // Act
      final completed = task.complete();

      // Assert
      expect(completed.isCompleted, true);
      expect(completed.completedAt, isNotNull);
      expect(completed.updatedAt, isNot(now));
    });

    test('complete should preserve all other fields', () {
      // Arrange
      final task = Task(
        id: 'task-1',
        content: 'Test Task',
        description: 'Test Description',
        isCompleted: false,
        priority: TaskPriority.high,
        dueDate: DateTime.utc(2024, 1, 20),
        duration: 60,
        tags: ['tag1', 'tag2'],
        recurrence: 'daily',
        orderIndex: 5,
        createdAt: now,
        updatedAt: now,
      );

      // Act
      final completed = task.complete();

      // Assert
      expect(completed.id, 'task-1');
      expect(completed.content, 'Test Task');
      expect(completed.description, 'Test Description');
      expect(completed.priority, TaskPriority.high);
      expect(completed.dueDate, DateTime.utc(2024, 1, 20));
      expect(completed.duration, 60);
      expect(completed.tags, ['tag1', 'tag2']);
      expect(completed.recurrence, 'daily');
      expect(completed.orderIndex, 5);
    });
  });

  group('Task - Helper Methods', () {
    test('_addMonths should handle normal case', () {
      // Arrange
      final date = DateTime.utc(2024, 1, 15);
      
      // We can't directly test private methods, but we can test through createNextOccurrence
      // This test verifies the overall behavior
      final task = Task(
        id: 'task-1',
        content: 'Test',
        dueDate: date,
        createdAt: date,
        updatedAt: date,
        recurrence: 'monthly',
      );

      final next = task.createNextOccurrence();
      expect(next!.dueDate, DateTime.utc(2024, 2, 15));
    });

    test('_addYears should handle normal case', () {
      // Arrange
      final date = DateTime.utc(2024, 1, 15);
      
      final task = Task(
        id: 'task-1',
        content: 'Test',
        dueDate: date,
        createdAt: date,
        updatedAt: date,
        recurrence: 'yearly',
      );

      final next = task.createNextOccurrence();
      expect(next!.dueDate, DateTime.utc(2025, 1, 15));
    });
  });

  group('Task - Due Date Logic', () {
    test('hasDueDate should return true when dueDate is set', () {
      // Arrange
      final task = Task(
        id: 'task-1',
        content: 'Test',
        dueDate: DateTime.utc(2024, 1, 20),
        createdAt: now,
        updatedAt: now,
      );

      // Act & Assert
      expect(task.hasDueDate, true);
    });

    test('hasDueDate should return false when dueDate is null', () {
      // Arrange
      final task = Task(
        id: 'task-1',
        content: 'Test',
        dueDate: null,
        createdAt: now,
        updatedAt: now,
      );

      // Act & Assert
      expect(task.hasDueDate, false);
    });

    test('isOverdue should return false when dueDate is null', () {
      // Arrange
      final task = Task(
        id: 'task-1',
        content: 'Test',
        dueDate: null,
        createdAt: now,
        updatedAt: now,
      );

      // Act & Assert
      expect(task.isOverdue, false);
    });

    test('isOverdue should return false when dueDate is in future', () {
      // Arrange
      final task = Task(
        id: 'task-1',
        content: 'Test',
        dueDate: now.add(const Duration(days: 5)),
        createdAt: now,
        updatedAt: now,
      );

      // Act & Assert
      expect(task.isOverdue, false);
    });

    test('isOverdue should return true when dueDate is in past', () {
      // Arrange
      final task = Task(
        id: 'task-1',
        content: 'Test',
        dueDate: now.subtract(const Duration(days: 5)),
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 5)),
      );

      // Act & Assert
      expect(task.isOverdue, true);
    });
  });

  group('Task - Subtask Logic', () {
    test('hasSubtasks should return false when parentTaskId is null', () {
      // Arrange
      final task = Task(
        id: 'task-1',
        content: 'Test',
        parentTaskId: null,
        createdAt: now,
        updatedAt: now,
      );

      // Act & Assert
      expect(task.hasSubtasks, false);
      expect(task.isSubtask, false);
    });

    test('hasSubtasks should return true when parentTaskId is not null', () {
      // Note: hasSubtasks checks if parentTaskId != null, which means
      // this task IS a subtask, not that it HAS subtasks
      // This might be a naming issue in the original code
      final task = Task(
        id: 'task-1',
        content: 'Test',
        parentTaskId: 'parent-1',
        createdAt: now,
        updatedAt: now,
      );

      // Act & Assert
      expect(task.hasSubtasks, true);
      expect(task.isSubtask, true);
    });
  });
}
