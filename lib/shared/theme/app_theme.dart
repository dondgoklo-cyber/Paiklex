import 'package:flutter/material.dart';

/// Application theme configuration
class AppTheme {
  AppTheme._();

  /// Light theme
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2196F3),
        brightness: Brightness.light,
      ),
      useMaterial3: true,
    );
  }

  /// Dark theme
  static ThemeData get darkTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2196F3),
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    );
  }

  /// Priority colors based on TaskPriority values
  static const Map<int, Color> priorityColors = {
    1: Color(0xFFE53935), // Urgent - Red
    2: Color(0xFFFB8C00), // High - Orange
    3: Color(0xFF1E88E5), // Medium - Blue
    4: Color(0xFF43A047), // Low - Green
  };

  /// Get color for a priority value
  static Color getPriorityColor(int priority) {
    return priorityColors[priority] ?? priorityColors[3]!; // Default to medium
  }

  /// Tag colors
  static const List<Color> tagColors = [
    Color(0xFFE57373),
    Color(0xFFFFB74D),
    Color(0xFFFFF176),
    Color(0xFF81C784),
    Color(0xFF4DB6AC),
    Color(0xFF64B5F6),
    Color(0xFF9575CD),
    Color(0xFFB39DDB),
    Color(0xFF90A4AE),
    Color(0xFF7986CB),
  ];

  /// Get color for a tag based on its hash
  static Color getTagColor(String tag) {
    final index = tag.hashCode.abs() % tagColors.length;
    return tagColors[index];
  }
}
