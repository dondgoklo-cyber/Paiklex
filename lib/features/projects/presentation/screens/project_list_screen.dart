import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/di.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../cubits/project_list_cubit.dart';
import '../../domain/entities/project.dart';
import '../../../../shared/theme/app_theme.dart';

/// Screen for listing all projects
class ProjectListScreen extends StatelessWidget {
  const ProjectListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProjectListCubit>()..watch(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.projects),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: AppLocalizations.of(context)!.addProject,
              onPressed: () => _showCreateDialog(context),
            ),
          ],
        ),
        body: BlocBuilder<ProjectListCubit, ProjectListState>(
          builder: (context, state) {
            if (state.status == ProjectListStatus.loading) {
              return const LoadingView();
            }
            if (state.status == ProjectListStatus.error) {
              return ErrorView(
                message: state.errorMessage ?? 'Error loading projects',
                onRetry: () => context.read<ProjectListCubit>().watch(),
              );
            }

            final projects = state.projects;

            if (projects.isEmpty) {
              return EmptyState(
                icon: Icons.folder_open,
                title: AppLocalizations.of(context)!.noProjects,
                subtitle: AppLocalizations.of(context)!.noProjectsDesc,
                action: ElevatedButton(
                  onPressed: () => _showCreateDialog(context),
                  child: Text(AppLocalizations.of(context)!.addProject),
                ),
              );
            }

            return ListView.builder(
              itemCount: projects.length,
              itemBuilder: (context, i) {
                final project = projects[i];
                return _ProjectTile(
                  project: project,
                  onToggleArchive: () => context.read<ProjectListCubit>().toggleArchive(project.id),
                  onDelete: () => _confirmDelete(context, project.id),
                  onTap: () => context.push('/projects/${project.id}'),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController();

    final created = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.addProject),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: l10n.projectName,
            hintText: l10n.projectNameHint,
          ),
          autofocus: true,
          onSubmitted: (_) => Navigator.pop(context, true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.create),
          ),
        ],
      ),
    );

    if (created == true && nameController.text.trim().isNotEmpty) {
      context.read<ProjectListCubit>().create(nameController.text.trim());
    }
  }

  Future<void> _confirmDelete(BuildContext context, String projectId) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: l10n.delete,
      message: l10n.deleteProjectConfirmation,
      confirmText: l10n.yes,
      cancelText: l10n.no,
    );

    if (confirmed == true) {
      context.read<ProjectListCubit>().delete(projectId);
    }
  }
}

/// Tile for a single project
class _ProjectTile extends StatelessWidget {
  final Project project;
  final VoidCallback onToggleArchive;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _ProjectTile({
    required this.project,
    required this.onToggleArchive,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Color(project.color),
            shape: BoxShape.circle,
          ),
          child: Icon(
            project.isArchived ? Icons.archive : Icons.folder,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(project.name),
        subtitle: Text(
          project.isArchived ? l10n.archived : l10n.active,
          style: TextStyle(
            color: project.isArchived
                ? Theme.of(context).colorScheme.onSurfaceVariant
                : Theme.of(context).colorScheme.primary,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                project.isArchived ? Icons.unarchive : Icons.archive,
              ),
              tooltip: project.isArchived ? l10n.unarchive : l10n.archive,
              onPressed: onToggleArchive,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: l10n.delete,
              onPressed: onDelete,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
