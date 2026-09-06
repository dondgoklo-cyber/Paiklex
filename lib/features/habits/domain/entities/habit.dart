import 'package:equatable/equatable.dart';

/// Habit entity representing a habit with streak tracking
class Habit extends Equatable {
  final String id;
  final String? projectId;
  final String title;
  final String frequency; // 'daily', 'weekly', 'monthly'
  final int streak;
  final int bestStreak;
  final DateTime? lastCompletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Habit({
    required this.id,
    this.projectId,
    required this.title,
    this.frequency = 'daily',
    this.streak = 0,
    this.bestStreak = 0,
    this.lastCompletedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a copy with optional changes
  Habit copyWith({
    String? id,
    String? Function()? projectId,
    String? title,
    String? frequency,
    int? streak,
    int? bestStreak,
    DateTime? Function()? lastCompletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Habit(
      id: id ?? this.id,
      projectId: projectId != null ? projectId() : this.projectId,
      title: title ?? this.title,
      frequency: frequency ?? this.frequency,
      streak: streak ?? this.streak,
      bestStreak: bestStreak ?? this.bestStreak,
      lastCompletedAt: lastCompletedAt != null ? lastCompletedAt() : this.lastCompletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Completes the habit and updates streak
  Habit complete() {
    final now = DateTime.now().toUtc();
    final dateOnlyToday = DateTime.utc(now.year, now.month, now.day);
    
    // Check if already completed today - if so, return unchanged
    if (lastCompletedAt != null) {
      final lastDate = DateTime.utc(
        lastCompletedAt!.year,
        lastCompletedAt!.month,
        lastCompletedAt!.day,
      );
      if (lastDate == dateOnlyToday) {
        // Already completed today - return unchanged
        return this;
      }
    }
    
    int newStreak = 1;
    int newBestStreak = bestStreak;
    
    // Check if last completion was yesterday
    if (lastCompletedAt != null) {
      final lastDate = DateTime.utc(
        lastCompletedAt!.year,
        lastCompletedAt!.month,
        lastCompletedAt!.day,
      );
      final yesterday = dateOnlyToday.subtract(const Duration(days: 1));
      
      if (lastDate == yesterday) {
        // Continue streak
        newStreak = streak + 1;
      }
    }
    
    if (newStreak > newBestStreak) {
      newBestStreak = newStreak;
    }
    
    return copyWith(
      streak: newStreak,
      bestStreak: newBestStreak,
      lastCompletedAt: () => now,
      updatedAt: now,
    );
  }

  /// Resets the streak
  Habit resetStreak() {
    return copyWith(
      streak: 0,
      updatedAt: DateTime.now().toUtc(),
    );
  }

  /// Returns true if this habit is for today
  bool get isDueToday {
    if (frequency == 'daily') return true;
    if (lastCompletedAt == null) return true;
    
    final now = DateTime.now().toUtc();
    final today = DateTime.utc(now.year, now.month, now.day);
    final lastDate = DateTime.utc(
      lastCompletedAt!.year,
      lastCompletedAt!.month,
      lastCompletedAt!.day,
    );
    
    if (frequency == 'weekly') {
      // For weekly: check if today is the day of week for this habit
      // Based on the day of week when it was last completed
      final lastDayOfWeek = lastDate.weekday;
      return today.weekday == lastDayOfWeek;
    }
    
    if (frequency == 'monthly') {
      // For monthly: check if today is the day of month for this habit
      final lastDayOfMonth = lastDate.day;
      return today.day == lastDayOfMonth;
    }
    
    // Default: not due if already completed today
    return lastDate != today;
  }

  @override
  List<Object?> get props => [
        id,
        projectId,
        title,
        frequency,
        streak,
        bestStreak,
        lastCompletedAt,
        createdAt,
        updatedAt,
      ];
}
