import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/project.dart';
import '../../domain/usecases/watch_projects.dart';
import '../../domain/usecases/create_project.dart';
import '../../domain/usecases/update_project.dart';
import '../../domain/usecases/delete_project.dart';
import '../../domain/usecases/toggle_project_archive.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';

part 'project_list_state.dart';

/// Cubit for managing project list state
class ProjectListCubit extends Cubit<ProjectListState> {
  final WatchProjects _watchProjects;
  final CreateProject _createProject;
  final UpdateProject _updateProject;
  final DeleteProject _deleteProject;
  final ToggleProjectArchive _toggleProjectArchive;
  final Logger _logger;

  StreamSubscription? _subscription;

  ProjectListCubit(
    this._watchProjects,
    this._createProject,
    this._updateProject,
    this._deleteProject,
    this._toggleProjectArchive,
  ) : _logger = AppLogger.forService('ProjectListCubit'),
       super(const ProjectListState());

  /// Starts watching projects
  void watch() {
    _subscription?.cancel();
    emit(state.copyWith(status: ProjectListStatus.loading));

    _subscription = _watchProjects().listen(
      (result) {
        result.fold(
          (failure) {
            _logger.e('Failed to watch projects', error: failure);
            emit(state.copyWith(
              status: ProjectListStatus.error,
              errorMessage: failure.message,
            ));
          },
          (projects) {
            emit(state.copyWith(
              status: ProjectListStatus.loaded,
              projects: projects,
              errorMessage: null,
            ));
          },
        );
      },
      onError: (e, s) {
        _logger.e('Error watching projects', error: e, stackTrace: s);
        emit(state.copyWith(
          status: ProjectListStatus.error,
          errorMessage: e.toString(),
        ));
      },
    );
  }

  /// Creates a new project
  Future<void> create(String name, {int? color}) async {
    final result = await _createProject(name, color: color);
    result.fold(
      (failure) {
        _logger.e('Failed to create project', error: failure);
        emit(state.copyWith(errorMessage: failure.message));
      },
      (project) {
        _logger.d('Project created: ${project.id}');
        // Stream will emit new state automatically
      },
    );
  }

  /// Updates a project
  Future<void> update(Project project) async {
    final result = await _updateProject(project);
    result.fold(
      (failure) {
        _logger.e('Failed to update project', error: failure);
        emit(state.copyWith(errorMessage: failure.message));
      },
      (updatedProject) {
        _logger.d('Project updated: ${updatedProject.id}');
        // Stream will emit new state automatically
      },
    );
  }

  /// Deletes a project
  Future<void> delete(String projectId) async {
    final result = await _deleteProject(projectId);
    result.fold(
      (failure) {
        _logger.e('Failed to delete project', error: failure);
        emit(state.copyWith(errorMessage: failure.message));
      },
      (_) {
        _logger.d('Project deleted: $projectId');
        // Stream will emit new state automatically
      },
    );
  }

  /// Toggles project archive status
  Future<void> toggleArchive(String projectId) async {
    final result = await _toggleProjectArchive(projectId);
    result.fold(
      (failure) {
        _logger.e('Failed to toggle project archive', error: failure);
        emit(state.copyWith(errorMessage: failure.message));
      },
      (updatedProject) {
        _logger.d('Project archive toggled: ${updatedProject.id}');
        // Stream will emit new state automatically
      },
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
