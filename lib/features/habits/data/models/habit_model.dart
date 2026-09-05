import 'package:drift/drift.dart';
import '../../domain/entities/habit.dart';
import '../../../../database/app_database.dart';

/// Extension for mapping HabitRow to Habit entity
extension HabitRowMapper on HabitRow {
  /// Converts a HabitRow to a Habit entity
  Habit toEntity() {
    return Habit(
      id: id,
      projectId: projectId,
      title: title,
      frequency: frequency,
      streak: streak,
      bestStreak: bestStreak,
      lastCompletedAt: lastCompletedAt != null
          ? DateTime.fromMillisecondsSinceEpoch(lastCompletedAt!)
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt),
    );
  }
}

/// Extension for mapping Habit entity to HabitsCompanion
extension HabitEntityMapper on Habit {
  /// Converts a Habit entity to a HabitsCompanion for database insertion
  HabitsCompanion toCompanion() {
    return HabitsCompanion(
      id: Value(id),
      projectId: Value(projectId),
      title: Value(title),
      frequency: Value(frequency),
      streak: Value(streak),
      bestStreak: Value(bestStreak),
      lastCompletedAt: Value(lastCompletedAt?.millisecondsSinceEpoch),
      createdAt: Value(createdAt.millisecondsSinceEpoch),
      updatedAt: Value(updatedAt.millisecondsSinceEpoch),
    );
  }
}
