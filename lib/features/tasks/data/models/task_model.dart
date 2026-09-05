import 'dart:convert';
import 'package:drift/drift.dart';
import '../../../../database/app_database.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/priority.dart';

/// Extension to map TaskRow to Task entity
extension TaskRowMapper on TaskRow {
  /// Converts database row to domain entity
  Task toEntity() {
    return Task(
      id: id,
      projectId: projectId,
      parentTaskId: parentTaskId,
      content: content,
      description: description,
      isCompleted: isCompleted,
      priority: TaskPriority.fromValue(priority),
      dueDate: dueDate != null ? AppDateUtils.fromMillisUtc(dueDate!) : null,
      duration: duration,
      tags: _parseTags(tags),
      recurrence: recurrence,
      orderIndex: orderIndex,
      createdAt: AppDateUtils.fromMillisUtc(createdAt),
      updatedAt: AppDateUtils.fromMillisUtc(updatedAt),
      completedAt: completedAt != null
          ? AppDateUtils.fromMillisUtc(completedAt!)
          : null,
    );
  }

  /// Parses tags from JSON string
  static List<String> _parseTags(String json) {
    if (json == '[]' || json.isEmpty) return const [];
    try {
      final decoded = jsonDecode(json);
      if (decoded is List) return decoded.cast<String>();
      return const [];
    } catch (_) {
      return const [];
    }
  }
}

/// Extension to map Task entity to TasksCompanion
extension TaskEntityMapper on Task {
  /// Converts domain entity to database companion
  TasksCompanion toCompanion() {
    return TasksCompanion(
      id: Value(id),
      projectId: Value(projectId),
      parentTaskId: Value(parentTaskId),
      content: Value(content),
      description: Value(description),
      isCompleted: Value(isCompleted),
      priority: Value(priority.value),
      dueDate: Value(dueDate?.toUtc().millisecondsSinceEpoch),
      duration: Value(duration),
      tags: Value(jsonEncode(tags)),
      recurrence: Value(recurrence),
      orderIndex: Value(orderIndex),
      createdAt: Value(AppDateUtils.toMillisUtc(createdAt)),
      updatedAt: Value(AppDateUtils.toMillisUtc(updatedAt)),
      completedAt: Value(completedAt?.toUtc().millisecondsSinceEpoch),
    );
  }
}
