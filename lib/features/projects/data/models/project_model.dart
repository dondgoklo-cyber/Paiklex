import 'package:drift/drift.dart';
import '../../domain/entities/project.dart';
import '../../../../database/app_database.dart';

/// Extension for mapping ProjectRow to Project entity
extension ProjectRowMapper on ProjectRow {
  /// Converts a ProjectRow to a Project entity
  Project toEntity() {
    return Project(
      id: id,
      name: name,
      color: color,
      isArchived: isArchived,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt),
    );
  }
}

/// Extension for mapping Project entity to ProjectsCompanion
extension ProjectEntityMapper on Project {
  /// Converts a Project entity to a ProjectsCompanion for database insertion
  ProjectsCompanion toCompanion() {
    return ProjectsCompanion(
      id: Value(id),
      name: Value(name),
      color: Value(color),
      isArchived: Value(isArchived),
      createdAt: Value(createdAt.millisecondsSinceEpoch),
      updatedAt: Value(updatedAt.millisecondsSinceEpoch),
    );
  }
}
