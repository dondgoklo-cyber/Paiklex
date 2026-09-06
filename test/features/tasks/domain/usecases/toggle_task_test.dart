import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';

import 'package:monolith_tasks/features/tasks/domain/repositories/task_repository.dart';
import 'package:monolith_tasks/features/tasks/domain/usecases/toggle_task.dart';
import 'package:monolith_tasks/features/tasks/domain/entities/task.dart';
import 'package:monolith_tasks/features/tasks/domain/entities/priority.dart';
import 'package:monolith_tasks/core/errors/failures.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late ToggleTask useCase;
  late TaskRepository mockRepository;

  final originalTask = Task(
    id: 'test-id',
    content: 'Test task',
    isCompleted: false,
    priority: TaskPriority.medium,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  final toggledTask = Task(
    id: 'test-id',
    content: 'Test task',
    isCompleted: true,
    priority: TaskPriority.medium,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 2),
  );

  setUp(() {
    mockRepository = MockTaskRepository();
    useCase = ToggleTask(mockRepository);
  });

  group('ToggleTask', () {
    test('should toggle task completion successfully', () async {
      // Arrange
      when(() => mockRepository.toggle('test-id')).thenAnswer(
        (_) async => Right(toggledTask),
      );

      // Act
      final result = await useCase('test-id');

      // Assert
      expect(result.isRight, true);
      result.fold(
        (failure) => fail('Expected success but got failure: $failure'),
        (task) {
          expect(task.isCompleted, true);
        },
      );

      verify(() => mockRepository.toggle('test-id')).called(1);
    });

    test('should return DatabaseFailure when getById fails', () async {
      // Arrange
      when(() => mockRepository.toggle('test-id')).thenAnswer(
        (_) async => Left(DatabaseFailure('Database error')),
      );

      // Act
      final result = await useCase('test-id');

      // Assert
      expect(result.isLeft, true);
      result.fold(
        (failure) {
          expect(failure, isA<DatabaseFailure>());
          expect(failure.message, 'Database error');
        },
        (task) => fail('Expected failure but got success: $task'),
      );

      verify(() => mockRepository.toggle('test-id')).called(1);
    });

    test('should return NotFoundFailure when task not found', () async {
      // Arrange
      when(() => mockRepository.toggle('non-existent-id')).thenAnswer(
        (_) async => Left(NotFoundFailure('Task', 'non-existent-id')),
      );

      // Act
      final result = await useCase('non-existent-id');

      // Assert
      expect(result.isLeft, true);
      result.fold(
        (failure) {
          expect(failure, isA<NotFoundFailure>());
          expect(failure.message, 'Task with id non-existent-id not found');
        },
        (task) => fail('Expected failure but got success: $task'),
      );

      verify(() => mockRepository.toggle('non-existent-id')).called(1);
    });

    test('should return DatabaseFailure when update fails', () async {
      // Arrange
      when(() => mockRepository.toggle('test-id')).thenAnswer(
        (_) async => Left(DatabaseFailure('Update failed')),
      );

      // Act
      final result = await useCase('test-id');

      // Assert
      expect(result.isLeft, true);
      result.fold(
        (failure) {
          expect(failure, isA<DatabaseFailure>());
          expect(failure.message, 'Update failed');
        },
        (task) => fail('Expected failure but got success: $task'),
      );

      verify(() => mockRepository.toggle('test-id')).called(1);
    });

    test('should toggle from completed to incomplete', () async {
      // Arrange
      when(() => mockRepository.toggle('test-id')).thenAnswer(
        (_) async => Right(originalTask),
      );

      // Act
      final result = await useCase('test-id');

      // Assert
      expect(result.isRight, true);
      result.fold(
        (failure) => fail('Expected success but got failure: $failure'),
        (task) {
          expect(task.isCompleted, false);
        },
      );

      verify(() => mockRepository.toggle('test-id')).called(1);
    });
  });
}
