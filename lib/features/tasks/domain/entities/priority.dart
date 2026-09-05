/// Task priority levels
/// P1 = Urgent (highest), P4 = Low (lowest)
enum TaskPriority {
  /// Urgent priority - highest priority
  urgent(1, 'urgent', 0xFFE53935),

  /// High priority
  high(2, 'high', 0xFFFB8C00),

  /// Medium priority - default
  medium(3, 'medium', 0xFF1E88E5),

  /// Low priority - lowest
  low(4, 'low', 0xFF43A047);

  final int value;
  final String name;
  final int colorValue;

  const TaskPriority(this.value, this.name, this.colorValue);

  /// Get priority from numeric value
  static TaskPriority fromValue(int v) => TaskPriority.values.firstWhere(
        (p) => p.value == v,
        orElse: () => TaskPriority.medium,
      );

  /// Get color as Color object (for Flutter)
  // Note: This requires 'package:flutter/material.dart' to be imported by caller
}
