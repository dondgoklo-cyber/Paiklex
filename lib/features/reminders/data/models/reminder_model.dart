import 'package:drift/drift.dart';
import '../../domain/entities/reminder.dart';
import '../../../../database/app_database.dart';

/// Extension for mapping ReminderRow to Reminder entity
extension ReminderRowMapper on ReminderRow {
  /// Converts a ReminderRow to a Reminder entity
  Reminder toEntity() {
    return Reminder(
      id: id,
      taskId: taskId,
      habitId: habitId,
      triggerAt: DateTime.fromMillisecondsSinceEpoch(triggerAt),
      title: title,
      body: body,
      isTriggered: isTriggered,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
    );
  }
}

/// Extension for mapping Reminder entity to RemindersCompanion
extension ReminderEntityMapper on Reminder {
  /// Converts a Reminder entity to a RemindersCompanion for database insertion
  RemindersCompanion toCompanion() {
    return RemindersCompanion(
      id: Value(id),
      taskId: Value(taskId),
      habitId: Value(habitId),
      triggerAt: Value(triggerAt.millisecondsSinceEpoch),
      title: Value(title),
      body: Value(body),
      isTriggered: Value(isTriggered),
      createdAt: Value(createdAt.millisecondsSinceEpoch),
    );
  }
}
