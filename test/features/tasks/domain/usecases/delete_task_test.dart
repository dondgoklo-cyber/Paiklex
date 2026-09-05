import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';

import 'package:monolith_tasks/features/tasks/domain/repositories/task_repository.dart';
import 'package:monolith_tasks/features/tasks/domain/usecases/delete_task.dart';
import 'package:monolith_tasks/core/errors/failures.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late DeleteTask useCase;
  late TaskRepository mockRepository;

  setUp(() {
    mockRepository = MockTaskRepository();
    useCase = DeleteTask(mockRepository);
  });

  group('DeleteTask', () {
    test('should delete task successfully', () async {
      // Arrange
      when(() => mockRepository.delete('test-id')).thenAnswer(
        (_) async => Right(unit),
      );

      // Act
      final result = await useCase('test-id');

      // Assert
      expect(result.isRight, true);
      result.fold(
        (failure) => fail('Expected success but got failure: $failure'),
        (unit) {
          expect(unit, unit);
        },
      );

      verify(() => mockRepository.delete('test-id')).called(1);
    });

    test('should return DatabaseFailure when repository fails', () async {
      // Arrange
      when(() => mockRepository.delete('test-id')).thenAnswer(
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
        (unit) => fail('Expected failure but got success: $unit'),
      );

      verify(() => mockRepository.delete('test-id')).called(1);
    });

    test('should return NotFoundFailure when task not found', () async {
      // Arrange
      when(() => mockRepository.delete('non-existent-id')).thenAnswer(
        (_) async => Left(NotFoundFailure('Task with id non-existent-id not found')),
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
        (unit) => fail('Expected failure but got success: $unit'),
      );

      verify(() => mockRepository.delete('non-existent-id')).called(1);
    });

    test('should return ValidationFailure when id is empty', () async {
      // Act
      final result = await useCase('');

      // Assert
      expect(result.isLeft, true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'Task id cannot be empty');
        },
        (unit) => fail('Expected failure but got success: $unit'),
      );

      verifyNever(() => mockRepository.delete(any()));
    });
  });
}
