import 'package:equatable/equatable.dart';

/// Project entity representing a project in the system
class Project extends Equatable {
  final String id;
  final String name;
  final int color;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Project({
    required this.id,
    required this.name,
    this.color = 0xFF2196F3,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a copy with optional changes
  Project copyWith({
    String? id,
    String? name,
    int? color,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Toggles the archived status
  Project toggleArchive() {
    return copyWith(
      isArchived: !isArchived,
      updatedAt: DateTime.now().toUtc(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        color,
        isArchived,
        createdAt,
        updatedAt,
      ];
}
