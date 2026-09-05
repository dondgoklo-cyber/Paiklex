import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';

import 'package:monolith_tasks/features/tasks/domain/repositories/task_repository.dart';
import 'package:monolith_tasks/features/tasks/domain/usecases/get_task.dart';
import 'package:monolith_tasks/features/tasks/domain/usecases/get_all_tasks.dart';
import 'package:monolith_tasks/features/tasks/domain/entities/task.dart';
import 'package:monolith_tasks/core/errors/failures.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late GetTask getTask;
  late GetAllTasks getAllTasks;
  late TaskRepository mockRepository;

  const testTask = Task(
    id: 'test-id',
    content: 'Test task',
    isCompleted: false,
    priority: TaskPriority.medium,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  const testTasks = [
    testTask,
    Task(
      id: 'test-id-2',
      content: 'Another task',
      isCompleted: true,
      priority: TaskPriority.high,
      createdAt: DateTime(2024, 1, 2),
      updatedAt: DateTime(2024, 1, 2),
    ),
  ];

  setUp(() {
    mockRepository = MockTaskRepository();
    getTask = GetTask(mockRepository);
    getAllTasks = GetAllTasks(mockRepository);
  });

  group('GetTask', () {
    test('should return task when found', () async {
      // Arrange
      when(() => mockRepository.getById('test-id')).thenAnswer(
        (_) async => Right(Some(testTask)),
      );

      // Act
      final result = await getTask('test-id');

      // Assert
      expect(result.isRight, true);
      result.fold(
        (failure) => fail('Expected success but got failure: $failure'),
        (task) {
          expect(task, testTask);
        },
      );

      verify(() => mockRepository.getById('test-id')).called(1);
    });

    test('should return NotFoundFailure when task not found', () async {
      // Arrange
      when(() => mockRepository.getById('non-existent-id')).thenAnswer(
        (_) async => Right(None()),
      );

      // Act
      final result = await getTask('non-existent-id');

      // Assert
      expect(result.isLeft, true);
      result.fold(
        (failure) {
          expect(failure, isA<NotFoundFailure>());
          expect(failure.message, 'Task with id non-existent-id not found');
        },
        (task) => fail('Expected failure but got success: $task'),
      );

      verify(() => mockRepository.getById('non-existent-id')).called(1);
    });

    test('should return DatabaseFailure when repository fails', () async {
      // Arrange
      when(() => mockRepository.getById('test-id')).thenAnswer(
        (_) async => Left(DatabaseFailure('Database error')),
      );

      // Act
      final result = await getTask('test-id');

      // Assert
      expect(result.isLeft, true);
      result.fold(
        (failure) {
          expect(failure, isA<DatabaseFailure>());
          expect(failure.message, 'Database error');
        },
        (task) => fail('Expected failure but got success: $task'),
      );

      verify(() => mockRepository.getById('test-id')).called(1);
    });
  });

  group('GetAllTasks', () {
    test('should return all tasks', () async {
      // Arrange
      when(() => mockRepository.getAllOnce()).thenAnswer(
        (_) async => Right(testTasks),
      );

      // Act
      final result = await getAllTasks();

      // Assert
      expect(result.isRight, true);
      result.fold(
        (failure) => fail('Expected success but got failure: $failure'),
        (tasks) {
          expect(tasks, testTasks);
          expect(tasks.length, 2);
        },
      );

      verify(() => mockRepository.getAllOnce()).called(1);
    });

    test('should return empty list when no tasks', () async {
      // Arrange
      when(() => mockRepository.getAllOnce()).thenAnswer(
        (_) async => Right(const []),
      );

      // Act
      final result = await getAllTasks();

      // Assert
      expect(result.isRight, true);
      result.fold(
        (failure) => fail('Expected success but got failure: $failure'),
        (tasks) {
          expect(tasks, []);
          expect(tasks.isEmpty, true);
        },
      );

      verify(() => mockRepository.getAllOnce()).called(1);
    });

    test('should return DatabaseFailure when repository fails', () async {
      // Arrange
      when(() => mockRepository.getAllOnce()).thenAnswer(
        (_) async => Left(DatabaseFailure('Database error')),
      );

      // Act
      final result = await getAllTasks();

      // Assert
      expect(result.isLeft, true);
      result.fold(
        (failure) {
          expect(failure, isA<DatabaseFailure>());
          expect(failure.message, 'Database error');
        },
        (tasks) => fail('Expected failure but got success: $tasks'),
      );

      verify(() => mockRepository.getAllOnce()).called(1);
    });
  });
}
