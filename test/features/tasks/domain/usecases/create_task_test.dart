import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

import 'package:monolith_tasks/features/tasks/domain/repositories/task_repository.dart';
import 'package:monolith_tasks/features/tasks/domain/usecases/create_task.dart';
import 'package:monolith_tasks/features/tasks/domain/entities/task.dart';
import 'package:monolith_tasks/core/errors/failures.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

class MockUuid extends Mock implements Uuid {}

void main() {
  late CreateTask useCase;
  late TaskRepository mockRepository;
  late Uuid mockUuid;

  const testTask = Task(
    id: 'test-id',
    content: 'Test task',
    isCompleted: false,
    priority: TaskPriority.medium,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  setUp(() {
    mockRepository = MockTaskRepository();
    mockUuid = MockUuid();
    useCase = CreateTask(mockRepository, mockUuid);
  });

  group('CreateTask', () {
    test('should create a task successfully', () async {
      // Arrange
      when(() => mockUuid.v4()).thenReturn('generated-id');
      when(() => mockRepository.create(any())).thenAnswer(
        (_) async => Right(testTask.copyWith(id: 'generated-id')),
      );

      // Act
      final result = await useCase('Test task');

      // Assert
      expect(result.isRight, true);
      result.fold(
        (failure) => fail('Expected success but got failure: $failure'),
        (task) {
          expect(task.content, 'Test task');
          expect(task.id, 'generated-id');
        },
      );

      verify(() => mockRepository.create(any())).called(1);
    });

    test('should return DatabaseFailure when repository fails', () async {
      // Arrange
      when(() => mockUuid.v4()).thenReturn('generated-id');
      when(() => mockRepository.create(any())).thenAnswer(
        (_) async => Left(DatabaseFailure('Database error')),
      );

      // Act
      final result = await useCase('Test task');

      // Assert
      expect(result.isLeft, true);
      result.fold(
        (failure) {
          expect(failure, isA<DatabaseFailure>());
          expect(failure.message, 'Database error');
        },
        (task) => fail('Expected failure but got success: $task'),
      );

      verify(() => mockRepository.create(any())).called(1);
    });

    test('should return ValidationFailure when content is empty', () async {
      // Arrange
      when(() => mockUuid.v4()).thenReturn('generated-id');

      // Act
      final result = await useCase('');

      // Assert
      expect(result.isLeft, true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'Task content cannot be empty');
        },
        (task) => fail('Expected failure but got success: $task'),
      );

      verifyNever(() => mockRepository.create(any()));
    });

    test('should create task with all optional parameters', () async {
      // Arrange
      when(() => mockUuid.v4()).thenReturn('generated-id');
      when(() => mockRepository.create(any())).thenAnswer(
        (_) async => Right(testTask.copyWith(id: 'generated-id')),
      );

      // Act
      final result = await useCase(
        'Test task',
        description: 'Test description',
        priority: TaskPriority.high,
        dueDate: DateTime(2024, 12, 31),
        tags: const ['work', 'important'],
        projectId: 'project-1',
      );

      // Assert
      expect(result.isRight, true);
      result.fold(
        (failure) => fail('Expected success but got failure: $failure'),
        (task) {
          expect(task.content, 'Test task');
          expect(task.description, 'Test description');
          expect(task.priority, TaskPriority.high);
          expect(task.dueDate, DateTime(2024, 12, 31));
          expect(task.tags, const ['work', 'important']);
          expect(task.projectId, 'project-1');
        },
      );

      verify(() => mockRepository.create(any())).called(1);
    });
  });
}
