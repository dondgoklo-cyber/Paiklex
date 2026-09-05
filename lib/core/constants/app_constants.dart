/// Application constants
class AppConstants {
  AppConstants._();

  /// Database name
  static const String databaseName = 'monolith';

  /// Default priority value (medium)
  static const int defaultPriority = 3;

  /// Default color for projects
  static const int defaultProjectColor = 0xFF2196F3;

  /// Maximum length for task content
  static const int maxTaskContentLength = 2000;

  /// Maximum length for project name
  static const int maxProjectNameLength = 200;

  /// Maximum nesting level for subtasks
  static const int maxSubtaskLevel = 2;

  /// Recurrence types
  static const List<String> recurrenceTypes = ['daily', 'weekly', 'monthly'];

  /// Habit frequencies
  static const List<String> habitFrequencies = ['daily', 'weekly', 'monthly'];

  /// Priority values
  static const List<int> priorityValues = [1, 2, 3, 4];
}
