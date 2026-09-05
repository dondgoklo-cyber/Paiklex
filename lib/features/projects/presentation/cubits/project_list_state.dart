part of 'project_list_cubit.dart';

/// Status of project list operations
enum ProjectListStatus {
  initial,
  loading,
  loaded,
  error,
}

/// State for project list
class ProjectListState extends Equatable {
  final ProjectListStatus status;
  final List<Project> projects;
  final String? errorMessage;

  const ProjectListState({
    this.status = ProjectListStatus.initial,
    this.projects = const [],
    this.errorMessage,
  });

  /// Creates a copy with optional changes
  ProjectListState copyWith({
    ProjectListStatus? status,
    List<Project>? projects,
    String? errorMessage,
  }) {
    return ProjectListState(
      status: status ?? this.status,
      projects: projects ?? this.projects,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, projects, errorMessage];
}
