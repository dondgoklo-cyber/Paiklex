import 'dart:async';
import 'package:uuid/uuid.dart';
import '../../core/utils/logger.dart';

/// Manages undo/redo operations for destructive actions
class UndoManager {
  static final UndoManager _instance = UndoManager._internal();
  factory UndoManager() => _instance;
  UndoManager._internal() : _logger = AppLogger.forService('UndoManager');

  final AppLogger _logger;

  final _actions = <String, _UndoAction>{};
  final _history = <_UndoAction>[];
  static const _timeout = Duration(seconds: 5);

  /// Register an action that can be undone
  String register({
    required String type,
    required Future<void> Function() undoCallback,
    required Future<void> Function() redoCallback,
    Map<String, dynamic>? metadata,
  }) {
    final id = const Uuid().v4();
    final action = _UndoAction(
      id: id,
      type: type,
      undoCallback: undoCallback,
      redoCallback: redoCallback,
      metadata: metadata ?? {},
      timestamp: DateTime.now(),
    );

    _actions[id] = action;
    _history.add(action);

    _logger.d('Registered undo action: $id (type: $type)');

    // Auto-cleanup after timeout
    Future.delayed(_timeout, () {
      _actions.remove(id);
      _logger.d('Auto-removed undo action: $id');
    });

    return id;
  }

  /// Undo the action with the given ID
  Future<bool> undo(String actionId) async {
    final action = _actions[actionId];
    if (action == null) {
      _logger.w('Undo action not found: $actionId');
      return false;
    }

    try {
      _logger.d('Undoing action: $actionId');
      await action.undoCallback();
      _actions.remove(actionId);
      return true;
    } catch (e, stack) {
      _logger.e('Failed to undo action: $actionId', error: e, stackTrace: stack);
      return false;
    }
  }

  /// Redo the action with the given ID
  Future<bool> redo(String actionId) async {
    final action = _history.firstWhere(
      (a) => a.id == actionId,
      orElse: () => throw Exception('Action not found in history'),
    );

    try {
      _logger.d('Redoing action: $actionId');
      await action.redoCallback();
      return true;
    } catch (e, stack) {
      _logger.e('Failed to redo action: $actionId', error: e, stackTrace: stack);
      return false;
    }
  }

  /// Check if an action can be undone
  bool canUndo(String actionId) => _actions.containsKey(actionId);

  /// Clear all pending undo actions
  void clear() {
    _actions.clear();
    _history.clear();
    _logger.d('Cleared all undo actions');
  }
}

class _UndoAction {
  final String id;
  final String type;
  final Future<void> Function() undoCallback;
  final Future<void> Function() redoCallback;
  final Map<String, dynamic> metadata;
  final DateTime timestamp;

  _UndoAction({
    required this.id,
    required this.type,
    required this.undoCallback,
    required this.redoCallback,
    required this.metadata,
    required this.timestamp,
  });
}

/// Global instance
final undoManager = UndoManager();
