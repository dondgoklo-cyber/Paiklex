import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'date_utils.dart';

/// Types of undoable actions
enum UndoActionType {
  deleteTask,
  deleteProject,
  deleteHabit,
  deleteReminder,
  archiveProject,
  completeHabit,
}

/// Represents an undoable action
@immutable
class UndoAction {
  final String id;
  final UndoActionType type;
  final Object? entity;
  final DateTime timestamp;
  final Duration timeout;

  const UndoAction({
    required this.id,
    required this.type,
    required this.entity,
    required this.timestamp,
    this.timeout = const Duration(seconds: 5),
  });

  bool get isExpired => AppDateUtils.nowUtc().difference(timestamp) > timeout;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UndoAction &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type;

  @override
  int get hashCode => id.hashCode ^ type.hashCode;

  @override
  String toString() => 'UndoAction(type: $type, id: $id, entity: $entity)';
}

/// Callback type for undo operations
typedef UndoCallback = Future<void> Function();

/// Action with undo callback and full state restoration
class UndoableAction {
  final UndoAction action;
  final UndoCallback onUndo;
  final Map<String, dynamic>? fullState; // Full state for exact restoration

  const UndoableAction({
    required this.action,
    required this.onUndo,
    this.fullState,
  });

  /// Creates an undoable action with full state capture
  UndoableAction.withState({
    required this.action,
    required this.onUndo,
    required this.fullState,
  });
}

/// Manager for undo operations
/// Singleton that manages a stack of undoable actions with timeout
class UndoManager {
  static final UndoManager _instance = UndoManager._internal();

  factory UndoManager() => _instance;

  UndoManager._internal() : _logger = Logger(
      printer: PrettyPrinter(
        colors: true,
        printTime: true,
        methodCount: 0,
      ),
    ) {
    _cleanupTimer = Timer.periodic(_cleanupInterval, (_) => _cleanupExpired());
  }

  final Logger _logger;
  final List<UndoableAction> _actions = [];
  final Duration _cleanupInterval = const Duration(seconds: 1);
  Timer? _cleanupTimer;

  /// Maximum number of actions to keep in history
  static const int _maxHistorySize = 50;

  /// Add an undoable action
  /// Returns the action ID for reference
  String addAction({
    required UndoActionType type,
    required Object? entity,
    required UndoCallback onUndo,
    Duration timeout = const Duration(seconds: 5),
    Map<String, dynamic>? fullState,
  }) {
    final action = UndoAction(
      id: _generateId(),
      type: type,
      entity: entity,
      timestamp: AppDateUtils.nowUtc(),
      timeout: timeout,
    );

    _actions.add(UndoableAction(
      action: action,
      onUndo: onUndo,
      fullState: fullState,
    ));
    _logger.d('Added undo action: ${action.type} for ${action.id}');

    // Trim history if too large
    if (_actions.length > _maxHistorySize) {
      _actions.removeAt(0);
    }

    return action.id;
  }

  /// Add an action with full state capture for exact restoration
  String addActionWithState({
    required UndoActionType type,
    required Object? entity,
    required UndoCallback onUndo,
    required Map<String, dynamic> fullState,
    Duration timeout = const Duration(seconds: 5),
  }) {
    return addAction(
      type: type,
      entity: entity,
      onUndo: onUndo,
      timeout: timeout,
      fullState: fullState,
    );
  }

  /// Perform undo for a specific action
  Future<bool> undo(String actionId) async {
    final index = _actions.indexWhere((a) => a.action.id == actionId);
    if (index == -1) {
      _logger.w('Undo action not found: $actionId');
      return false;
    }

    final undoableAction = _actions[index];
    if (undoableAction.action.isExpired) {
      _logger.w('Undo action expired: $actionId');
      _actions.removeAt(index);
      return false;
    }

    try {
      await undoableAction.onUndo();
      _actions.removeAt(index);
      _logger.d('Successfully undid action: $actionId');
      return true;
    } catch (e) {
      _logger.e('Failed to undo action $actionId: $e');
      return false;
    }
  }

  /// Get the most recent non-expired action
  UndoableAction? get latestAction {
    for (var i = _actions.length - 1; i >= 0; i--) {
      final action = _actions[i];
      if (!action.action.isExpired) {
        return action;
      }
    }
    return null;
  }

  /// Get all non-expired actions
  List<UndoableAction> get activeActions {
    return _actions.where((a) => !a.action.isExpired).toList();
  }

  /// Clear all actions
  void clear() {
    _actions.clear();
    _logger.d('Cleared all undo actions');
  }

  /// Clear actions of a specific type
  void clearByType(UndoActionType type) {
    _actions.removeWhere((a) => a.action.type == type);
    _logger.d('Cleared undo actions of type: $type');
  }

  /// Remove a specific action by ID
  void removeAction(String actionId) {
    _actions.removeWhere((a) => a.action.id == actionId);
    _logger.d('Removed undo action: $actionId');
  }

  /// Cleanup expired actions
  void _cleanupExpired() {
    final beforeCount = _actions.length;
    _actions.removeWhere((a) => a.action.isExpired);
    final removedCount = beforeCount - _actions.length;

    if (removedCount > 0) {
      _logger.d('Cleaned up $removedCount expired undo actions');
    }
  }

  /// Generate unique ID for actions
  String _generateId() {
    return 'undo_${AppDateUtils.nowUtc().millisecondsSinceEpoch}_${_actions.length}';
  }

  /// Dispose the manager
  void dispose() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
    _actions.clear();
    _logger.d('UndoManager disposed');
  }
}

/// Global instance of UndoManager
final undoManager = UndoManager();
