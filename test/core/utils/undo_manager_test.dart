import 'package:flutter_test/flutter_test.dart';
import 'package:monolith_tasks/core/utils/undo_manager.dart';

class TestEntity {
  final String id;
  final String name;

  const TestEntity({required this.id, required this.name});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TestEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  String toString() => 'TestEntity(id: $id, name: $name)';
}

void main() {
  group('UndoManager', () {
    setUp(() {
      // Reset the singleton for each test
      undoManager.clear();
    });

    tearDown(() {
      undoManager.clear();
    });

    test('should add and retrieve undo actions', () {
      // Arrange
      final entity = TestEntity(id: '1', name: 'Test');
      bool undid = false;

      // Act
      final actionId = undoManager.addAction(
        type: UndoActionType.deleteTask,
        entity: entity,
        onUndo: () async {
          undid = true;
        },
      );

      // Assert
      expect(actionId, isNotEmpty);
      expect(undoManager.latestAction, isNotNull);
      expect(undoManager.latestAction!.action.id, actionId);
      expect(undoManager.latestAction!.action.type, UndoActionType.deleteTask);
      expect(undoManager.latestAction!.action.entity, entity);
    });

    test('should undo action successfully', () async {
      // Arrange
      final entity = TestEntity(id: '1', name: 'Test');
      bool undid = false;

      final actionId = undoManager.addAction(
        type: UndoActionType.deleteTask,
        entity: entity,
        onUndo: () async {
          undid = true;
        },
      );

      // Act
      final result = await undoManager.undo(actionId);

      // Assert
      expect(result, true);
      expect(undid, true);
      expect(undoManager.latestAction, isNull);
    });

    test('should return false when undoing non-existent action', () async {
      // Act
      final result = await undoManager.undo('non-existent-id');

      // Assert
      expect(result, false);
    });

    test('should return false when undoing expired action', () async {
      // Arrange
      final entity = TestEntity(id: '1', name: 'Test');
      bool undid = false;

      final actionId = undoManager.addAction(
        type: UndoActionType.deleteTask,
        entity: entity,
        onUndo: () async {
          undid = true;
        },
        timeout: const Duration(milliseconds: 10),
      );

      // Wait for expiration
      await Future.delayed(const Duration(milliseconds: 20));

      // Act
      final result = await undoManager.undo(actionId);

      // Assert
      expect(result, false);
      expect(undid, false);
    });

    test('should clear all actions', () {
      // Arrange
      undoManager.addAction(
        type: UndoActionType.deleteTask,
        entity: TestEntity(id: '1', name: 'Test 1'),
        onUndo: () async {},
      );
      undoManager.addAction(
        type: UndoActionType.deleteProject,
        entity: TestEntity(id: '2', name: 'Test 2'),
        onUndo: () async {},
      );

      // Act
      undoManager.clear();

      // Assert
      expect(undoManager.latestAction, isNull);
      expect(undoManager.activeActions, isEmpty);
    });

    test('should clear actions by type', () {
      // Arrange
      undoManager.addAction(
        type: UndoActionType.deleteTask,
        entity: TestEntity(id: '1', name: 'Test 1'),
        onUndo: () async {},
      );
      undoManager.addAction(
        type: UndoActionType.deleteProject,
        entity: TestEntity(id: '2', name: 'Test 2'),
        onUndo: () async {},
      );
      undoManager.addAction(
        type: UndoActionType.deleteTask,
        entity: TestEntity(id: '3', name: 'Test 3'),
        onUndo: () async {},
      );

      // Act
      undoManager.clearByType(UndoActionType.deleteTask);

      // Assert
      expect(undoManager.activeActions.length, 1);
      expect(undoManager.activeActions.first.action.type, UndoActionType.deleteProject);
    });

    test('should remove specific action by ID', () {
      // Arrange
      final actionId1 = undoManager.addAction(
        type: UndoActionType.deleteTask,
        entity: TestEntity(id: '1', name: 'Test 1'),
        onUndo: () async {},
      );
      final actionId2 = undoManager.addAction(
        type: UndoActionType.deleteProject,
        entity: TestEntity(id: '2', name: 'Test 2'),
        onUndo: () async {},
      );

      // Act
      undoManager.removeAction(actionId1);

      // Assert
      expect(undoManager.activeActions.length, 1);
      expect(undoManager.activeActions.first.action.id, actionId2);
    });

    test('should return all active actions', () {
      // Arrange
      undoManager.addAction(
        type: UndoActionType.deleteTask,
        entity: TestEntity(id: '1', name: 'Test 1'),
        onUndo: () async {},
      );
      undoManager.addAction(
        type: UndoActionType.deleteProject,
        entity: TestEntity(id: '2', name: 'Test 2'),
        onUndo: () async {},
      );

      // Act
      final actions = undoManager.activeActions;

      // Assert
      expect(actions.length, 2);
    });

    test('should handle undo action exception gracefully', () async {
      // Arrange
      final entity = TestEntity(id: '1', name: 'Test');

      final actionId = undoManager.addAction(
        type: UndoActionType.deleteTask,
        entity: entity,
        onUndo: () async {
          throw Exception('Undo failed');
        },
      );

      // Act
      final result = await undoManager.undo(actionId);

      // Assert
      expect(result, false);
      // Action should still be removed even if undo failed
      expect(undoManager.latestAction, isNull);
    });

    test('should trim history when exceeding max size', () {
      // Arrange - Add more than max history size
      for (var i = 0; i < UndoManager._maxHistorySize + 5; i++) {
        undoManager.addAction(
          type: UndoActionType.deleteTask,
          entity: TestEntity(id: i.toString(), name: 'Test $i'),
          onUndo: () async {},
        );
      }

      // Assert
      expect(undoManager.activeActions.length, UndoManager._maxHistorySize);
    });

    test('should return latest action from multiple actions', () {
      // Arrange
      final actionId1 = undoManager.addAction(
        type: UndoActionType.deleteTask,
        entity: TestEntity(id: '1', name: 'Test 1'),
        onUndo: () async {},
      );
      final actionId2 = undoManager.addAction(
        type: UndoActionType.deleteProject,
        entity: TestEntity(id: '2', name: 'Test 2'),
        onUndo: () async {},
      );

      // Act
      final latest = undoManager.latestAction;

      // Assert
      expect(latest, isNotNull);
      expect(latest!.action.id, actionId2);
    });
  });

  group('UndoAction', () {
    test('should correctly identify expired actions', () {
      // Arrange
      final action = UndoAction(
        id: 'test-id',
        type: UndoActionType.deleteTask,
        entity: TestEntity(id: '1', name: 'Test'),
        timestamp: DateTime.now().subtract(const Duration(seconds: 10)),
        timeout: const Duration(seconds: 5),
      );

      // Assert
      expect(action.isExpired, true);
    });

    test('should correctly identify non-expired actions', () {
      // Arrange
      final action = UndoAction(
        id: 'test-id',
        type: UndoActionType.deleteTask,
        entity: TestEntity(id: '1', name: 'Test'),
        timestamp: DateTime.now(),
        timeout: const Duration(seconds: 5),
      );

      // Assert
      expect(action.isExpired, false);
    });

    test('should have correct equality', () {
      // Arrange
      final action1 = UndoAction(
        id: 'test-id',
        type: UndoActionType.deleteTask,
        entity: TestEntity(id: '1', name: 'Test'),
        timestamp: DateTime.now(),
      );
      final action2 = UndoAction(
        id: 'test-id',
        type: UndoActionType.deleteTask,
        entity: TestEntity(id: '2', name: 'Other'),
        timestamp: DateTime.now(),
      );
      final action3 = UndoAction(
        id: 'other-id',
        type: UndoActionType.deleteTask,
        entity: TestEntity(id: '1', name: 'Test'),
        timestamp: DateTime.now(),
      );

      // Assert
      expect(action1, equals(action2));
      expect(action1, isNot(equals(action3)));
    });

    test('should have correct hashCode', () {
      // Arrange
      final action1 = UndoAction(
        id: 'test-id',
        type: UndoActionType.deleteTask,
        entity: TestEntity(id: '1', name: 'Test'),
        timestamp: DateTime.now(),
      );
      final action2 = UndoAction(
        id: 'test-id',
        type: UndoActionType.deleteTask,
        entity: TestEntity(id: '2', name: 'Other'),
        timestamp: DateTime.now(),
      );

      // Assert
      expect(action1.hashCode, equals(action2.hashCode));
    });
  });
}
