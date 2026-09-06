import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:drift/drift.dart';

import 'package:monolith_tasks/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:monolith_tasks/features/tasks/domain/entities/task.dart';
import 'package:monolith_tasks/features/tasks/domain/entities/priority.dart';
import 'package:monolith_tasks/database/app_database.dart';
import 'package:monolith_tasks/core/errors/failures.dart';

class MockTaskDao extends Mock implements TaskDao {
  MockTaskDao() {
    // Setup mock to return empty list by default
    when(() => getAllOnce()).thenAnswer((_) async => []);
    when(() => watchAll()).thenAnswer((_) => Stream.value([]));
  }
}

class MockAppDatabase extends Mock implements AppDatabase {
  MockAppDatabase() {
    when(() => taskDao).thenReturn(MockTaskDao());
    when(() => reminderDao).thenReturn(MockReminderDao());
  }
}

class MockReminderDao extends Mock implements ReminderDao {
  MockReminderDao() {
    when(() => deleteRemindersByTask(any())).thenAnswer((_) async => 0);
  }
}

void main() {
  late TaskRepositoryImpl repository;
  late MockTaskDao mockDao;
  late MockAppDatabase mockDb;

  final now = DateTime(2024, 1, 1, 12, 0, 0).toUtc();
  
  final taskA = Task(
    id: 'task-a',
    content: 'Task A',
    isCompleted: false,
    priority: TaskPriority.medium,
    createdAt: now,
    updatedAt: now,
    orderIndex: 0,
  );

  final taskB = Task(
    id: 'task-b',
    content: 'Task B',
    isCompleted: false,
    priority: TaskPriority.medium,
    createdAt: now,
    updatedAt: now,
    orderIndex: 1,
  );

  final taskC = Task(
    id: 'task-c',
    content: 'Task C',
    isCompleted: false,
    priority: TaskPriority.medium,
    createdAt: now,
    updatedAt: now,
    orderIndex: 2,
  );

  setUp(() {
    mockDao = MockTaskDao();
    mockDb = MockAppDatabase();
    
    // Override the mock to use our specific mockDao
    when(() => mockDb.taskDao).thenReturn(mockDao);
    when(() => mockDb.reminderDao).thenReturn(MockReminderDao());
    
    repository = TaskRepositoryImpl(mockDao, mockDb);
  });

  group('TaskRepositoryImpl - Update Isolation', () {
    test('update should only affect the specified task (not mass update)', () async {
      // Arrange
      // Setup: taskA and taskB exist in database
      final taskARow = TaskRow(
        id: 'task-a',
        projectId: null,
        parentTaskId: null,
        content: 'Task A',
        description: null,
        isCompleted: false,
        priority: 3,
        dueDate: null,
        duration: null,
        tags: '[]',
        recurrence: null,
        orderIndex: 0,
        createdAt: now.millisecondsSinceEpoch,
        updatedAt: now.millisecondsSinceEpoch,
        completedAt: null,
      );
      
      final taskBRow = TaskRow(
        id: 'task-b',
        projectId: null,
        parentTaskId: null,
        content: 'Task B',
        description: null,
        isCompleted: false,
        priority: 3,
        dueDate: null,
        duration: null,
        tags: '[]',
        recurrence: null,
        orderIndex: 1,
        createdAt: now.millisecondsSinceEpoch,
        updatedAt: now.millisecondsSinceEpoch,
        completedAt: null,
      );
      
      when(() => mockDao.getById('task-a')).thenAnswer((_) async => taskARow);
      when(() => mockDao.getAllOnce()).thenAnswer((_) async => [taskARow, taskBRow]);
      when(() => mockDao.updateTask(any())).thenAnswer((_) async => 1);

      // Act: Update taskA
      final updatedTaskA = taskA.copyWith(
        content: 'Updated Task A',
        updatedAt: now.add(const Duration(minutes: 1)),
      );
      
      await repository.update(updatedTaskA);

      // Assert: Verify updateTask was called with correct WHERE clause
      // The DAO's updateTask uses: where((t) => t.id.equals(companion.id.value))
      // This ensures only task-a is updated, not all tasks
      verify(() => mockDao.updateTask(any())).called(1);
    });

    test('reorder should only update orderIndex and updatedAt', () async {
      // Arrange
      when(() => mockDao.getById('task-a')).thenAnswer((_) async => TaskRow(
        id: 'task-a',
        projectId: null,
        parentTaskId: null,
        content: 'Task A',
        description: null,
        isCompleted: false,
        priority: 3,
        dueDate: null,
        duration: null,
        tags: '[]',
        recurrence: null,
        orderIndex: 0,
        createdAt: now.millisecondsSinceEpoch,
        updatedAt: now.millisecondsSinceEpoch,
        completedAt: null,
      ));
      when(() => mockDao.updateTask(any())).thenAnswer((_) async => 1);

      // Act
      await repository.reorder('task-a', 5);

      // Assert
      verify(() => mockDao.updateTask(any())).called(1);
      
      // Verify the companion passed to updateTask has the correct values
      final captured = verify(() => mockDao.updateTask(captureAny())).captured;
      final companion = captured.single as TasksCompanion;
      
      expect(companion.id.value, 'task-a');
      expect(companion.orderIndex.value, 5);
      // updatedAt should be updated
      expect(companion.updatedAt.value, isNot(now.millisecondsSinceEpoch));
      // Other fields should remain unchanged
      expect(companion.content.value, 'Task A');
      expect(companion.isCompleted.value, false);
    });

    test('delete should delete reminders for task before deleting task', () async {
      // Arrange
      final mockReminderDao = MockReminderDao();
      when(() => mockDb.reminderDao).thenReturn(mockReminderDao);
      when(() => mockReminderDao.deleteRemindersByTask('task-a')).thenAnswer((_) async => 1);
      when(() => mockDao.deleteTask('task-a')).thenAnswer((_) async => 1);
      
      repository = TaskRepositoryImpl(mockDao, mockDb);

      // Act
      await repository.delete('task-a');

      // Assert: Reminders deleted first
      verify(() => mockReminderDao.deleteRemindersByTask('task-a')).called(1);
      // Then task deleted
      verify(() => mockDao.deleteTask('task-a')).called(1);
    });

    test('complete should create next occurrence for recurring task', () async {
      // Arrange
      final recurringTask = taskA.copyWith(
        recurrence: 'daily',
        dueDate: now.add(const Duration(days: 1)),
      );
      
      final taskRow = TaskRow(
        id: 'task-a',
        projectId: null,
        parentTaskId: null,
        content: 'Task A',
        description: null,
        isCompleted: false,
        priority: 3,
        dueDate: now.add(const Duration(days: 1)).millisecondsSinceEpoch,
        duration: null,
        tags: '[]',
        recurrence: 'daily',
        orderIndex: 0,
        createdAt: now.millisecondsSinceEpoch,
        updatedAt: now.millisecondsSinceEpoch,
        completedAt: null,
      );
      
      when(() => mockDao.getById('task-a')).thenAnswer((_) async => taskRow);
      when(() => mockDao.updateTask(any())).thenAnswer((_) async => 1);
      when(() => mockDao.insertTask(any())).thenAnswer((_) async => 1);

      // Act
      await repository.complete('task-a');

      // Assert: Original task updated
      verify(() => mockDao.updateTask(any())).called(1);
      // New occurrence created
      verify(() => mockDao.insertTask(any())).called(1);
    });

    test('complete should not create next occurrence for non-recurring task', () async {
      // Arrange
      when(() => mockDao.getById('task-a')).thenAnswer((_) async => TaskRow(
        id: 'task-a',
        projectId: null,
        parentTaskId: null,
        content: 'Task A',
        description: null,
        isCompleted: false,
        priority: 3,
        dueDate: null,
        duration: null,
        tags: '[]',
        recurrence: null,
        orderIndex: 0,
        createdAt: now.millisecondsSinceEpoch,
        updatedAt: now.millisecondsSinceEpoch,
        completedAt: null,
      ));
      when(() => mockDao.updateTask(any())).thenAnswer((_) async => 1);

      // Act
      await repository.complete('task-a');

      // Assert: Only update, no insert
      verify(() => mockDao.updateTask(any())).called(1);
      verifyNever(() => mockDao.insertTask(any()));
    });

    test('complete should return unchanged if task already completed', () async {
      // Arrange
      final completedTaskRow = TaskRow(
        id: 'task-a',
        projectId: null,
        parentTaskId: null,
        content: 'Task A',
        description: null,
        isCompleted: true,
        priority: 3,
        dueDate: null,
        duration: null,
        tags: '[]',
        recurrence: null,
        orderIndex: 0,
        createdAt: now.millisecondsSinceEpoch,
        updatedAt: now.millisecondsSinceEpoch,
        completedAt: now.millisecondsSinceEpoch,
      );
      
      when(() => mockDao.getById('task-a')).thenAnswer((_) async => completedTaskRow);

      // Act
      final result = await repository.complete('task-a');

      // Assert
      expect(result.isRight, true);
      result.fold(
        (failure) => fail('Expected success but got failure: $failure'),
        (task) {
          expect(task.isCompleted, true);
        },
      );
      
      // No update or insert should occur
      verifyNever(() => mockDao.updateTask(any()));
      verifyNever(() => mockDao.insertTask(any()));
    });
  });

  group('TaskRepositoryImpl - Foreign Key Integrity', () {
    test('getById should return null for non-existent task', () async {
      // Arrange
      when(() => mockDao.getById('non-existent')).thenAnswer((_) async => null);

      // Act
      final result = await repository.getById('non-existent');

      // Assert
      expect(result.isRight, true);
      result.fold(
        (failure) => fail('Expected success but got failure: $failure'),
        (task) {
          expect(task, isNull);
        },
      );
    });

    test('getAllOnce should return all tasks', () async {
      // Arrange
      when(() => mockDao.getAllOnce()).thenAnswer((_) async => []);

      // Act
      final result = await repository.getAllOnce();

      // Assert
      expect(result.isRight, true);
      result.fold(
        (failure) => fail('Expected success but got failure: $failure'),
        (tasks) {
          expect(tasks, isEmpty);
        },
      );
    });
  });
}
