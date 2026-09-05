import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../app/di.dart';
import '../../../../core/utils/logger.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../domain/entities/project.dart';
import '../../domain/usecases/get_project.dart';
import '../../domain/usecases/update_project.dart';
import '../../domain/usecases/delete_project.dart';
import '../cubits/project_list_cubit.dart';

/// Screen for viewing and editing project details
class ProjectDetailScreen extends StatefulWidget {
  final String projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  final _nameController = TextEditingController();
  int _color = 0xFF2196F3;
  bool _isLoading = false;
  final _logger = AppLogger.forService('ProjectDetailScreen');

  late final GetProject _getProject;
  late final UpdateProject _updateProject;
  late final DeleteProject _deleteProject;

  @override
  void initState() {
    super.initState();
    _getProject = getIt<GetProject>();
    _updateProject = getIt<UpdateProject>();
    _deleteProject = getIt<DeleteProject>();

    _loadProject();
  }

  Future<void> _loadProject() async {
    setState(() => _isLoading = true);
    try {
      final result = await _getProject(widget.projectId);
      result.fold(
        (failure) {
          _logger.e('Failed to load project', error: failure);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(failure.message)),
            );
          }
        },
        (project) {
          if (project != null && mounted) {
            _nameController.text = project.name;
            _color = project.color;
          }
        },
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => getIt<ProjectListCubit>()..watch(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.editProject),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: l10n.delete,
              onPressed: _confirmDelete,
            ),
          ],
        ),
        body: _isLoading
            ? const LoadingView()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Name
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: l10n.projectName,
                        border: const OutlineInputBorder(),
                      ),
                      maxLength: 100,
                      autofocus: true,
                    ),
                    const SizedBox(height: 16),

                    // Color picker
                    _ColorPicker(
                      selectedColor: _color,
                      onColorSelected: (color) => setState(() => _color = color),
                    ),
                    const SizedBox(height: 24),

                    // Save button
                    FilledButton(
                      onPressed: _save,
                      child: Text(l10n.save),
                    ),
                  ],
                ),
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: _save,
          tooltip: l10n.save,
          child: const Icon(Icons.save),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.projectNameCannotBeEmpty)),
        );
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      final project = Project(
        id: widget.projectId,
        name: _nameController.text.trim(),
        color: _color,
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
      );

      final result = await _updateProject(project);
      result.fold(
        (failure) {
          _logger.e('Failed to update project', error: failure);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(failure.message)),
            );
          }
        },
        (updatedProject) {
          _logger.d('Project updated: ${updatedProject.id}');
          if (mounted) context.pop(updatedProject);
        },
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmDelete() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: l10n.delete,
      message: l10n.deleteProjectConfirmation,
      confirmText: l10n.yes,
      cancelText: l10n.no,
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        final result = await _deleteProject(widget.projectId);
        result.fold(
          (failure) {
            _logger.e('Failed to delete project', error: failure);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(failure.message)),
              );
            }
          },
          (_) {
            _logger.d('Project deleted: ${widget.projectId}');
            if (mounted) context.pop();
          },
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }
}

/// Color picker widget for project colors
class _ColorPicker extends StatelessWidget {
  final int selectedColor;
  final Function(int) onColorSelected;

  const _ColorPicker({
    required this.selectedColor,
    required this.onColorSelected,
  });

  final List<int> colors = const [
    0xFFE53935, // Red
    0xFFFB8C00, // Orange
    0xFFFFF176, // Yellow
    0xFF43A047, // Green
    0xFF2196F3, // Blue
    0xFF64B5F6, // Light Blue
    0xFF9575CD, // Purple
    0xFFB39DDB, // Light Purple
    0xFF90A4AE, // Grey
    0xFF7986CB, // Deep Purple
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.color,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: colors.map((color) {
            return GestureDetector(
              onTap: () => onColorSelected(color),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Color(color),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selectedColor == color
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: selectedColor == color
                    ? const Icon(Icons.check, color: Colors.white)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
