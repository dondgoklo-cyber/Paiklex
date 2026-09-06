import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';

import 'package:monolith_tasks/features/tasks/domain/repositories/task_repository.dart';
import 'package:monolith_tasks/features/tasks/domain/usecases/update_task.dart';
import 'package:monolith_tasks/features/tasks/domain/entities/task.dart';
import 'package:monolith_tasks/features/tasks/domain/entities/priority.dart';
import 'package:monolith_tasks/core/errors/failures.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late UpdateTask useCase;
  late TaskRepository mockRepository;

  final originalTask = Task(
    id: 'test-id',
    content: 'Original task',
    isCompleted: false,
    priority: TaskPriority.medium,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  final updatedTask = Task(
    id: 'test-id',
    content: 'Updated task',
    isCompleted: true,
    priority: TaskPriority.high,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 2),
  );

  setUp(() {
    mockRepository = MockTaskRepository();
    useCase = UpdateTask(mockRepository);
  });

  group('UpdateTask', () {
    test('should update task successfully', () async {
      // Arrange
      when(() => mockRepository.update(any())).thenAnswer(
        (_) async => Right(updatedTask),
      );

      // Act
      final result = await useCase(updatedTask);

      // Assert
      expect(result.isRight, true);
      result.fold(
        (failure) => fail('Expected success but got failure: $failure'),
        (task) {
          expect(task, updatedTask);
          expect(task.content, 'Updated task');
          expect(task.isCompleted, true);
          expect(task.priority, TaskPriority.high);
        },
      );

      verify(() => mockRepository.update(any())).called(1);
    });

    test('should return DatabaseFailure when repository fails', () async {
      // Arrange
      when(() => mockRepository.update(any())).thenAnswer(
        (_) async => Left(DatabaseFailure('Database error')),
      );

      // Act
      final result = await useCase(updatedTask);

      // Assert
      expect(result.isLeft, true);
      result.fold(
        (failure) {
          expect(failure, isA<DatabaseFailure>());
          expect(failure.message, 'Database error');
        },
        (task) => fail('Expected failure but got success: $task'),
      );

      verify(() => mockRepository.update(any())).called(1);
    });

    test('should return NotFoundFailure when task not found', () async {
      // Arrange
      when(() => mockRepository.update(any())).thenAnswer(
        (_) async => Left(NotFoundFailure('Task', 'test-id')),
      );

      // Act
      final result = await useCase(updatedTask);

      // Assert
      expect(result.isLeft, true);
      result.fold(
        (failure) {
          expect(failure, isA<NotFoundFailure>());
          expect(failure.message, 'Task with id test-id not found');
        },
        (task) => fail('Expected failure but got success: $task'),
      );

      verify(() => mockRepository.update(any())).called(1);
    });

    test('should return ValidationFailure when task id is empty', () async {
      // Arrange
      final invalidTask = updatedTask.copyWith(id: '');

      // Act
      final result = await useCase(invalidTask);

      // Assert
      expect(result.isLeft, true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'Task id cannot be empty');
        },
        (task) => fail('Expected failure but got success: $task'),
      );

      verifyNever(() => mockRepository.update(any()));
    });

    test('should return ValidationFailure when task content is empty', () async {
      // Arrange
      final invalidTask = updatedTask.copyWith(content: '');

      // Act
      final result = await useCase(invalidTask);

      // Assert
      expect(result.isLeft, true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'Task content cannot be empty');
        },
        (task) => fail('Expected failure but got success: $task'),
      );

      verifyNever(() => mockRepository.update(any()));
    });
  });
}
