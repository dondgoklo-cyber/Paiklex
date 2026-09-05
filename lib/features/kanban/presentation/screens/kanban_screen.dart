import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../app/di.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../tasks/presentation/cubits/task_list_cubit.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../../tasks/domain/entities/priority.dart';
import '../../../../shared/theme/app_theme.dart';

/// Kanban view screen with 3 columns: To Do, Doing, Done
class KanbanScreen extends StatelessWidget {
  const KanbanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TaskListCubit>()..watch(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.kanban),
        ),
        body: BlocBuilder<TaskListCubit, TaskListState>(
          builder: (context, state) {
            if (state.status == TaskListStatus.loading) {
              return const LoadingView();
            }
            if (state.status == TaskListStatus.error) {
              return ErrorView(
                message: state.errorMessage ?? 'Error loading tasks',
                onRetry: () => context.read<TaskListCubit>().watch(),
              );
            }

            final tasks = state.tasks;

            // Group tasks by status and priority
            final todo = tasks
                .where((t) => !t.isCompleted && t.priority != TaskPriority.urgent)
                .toList();
            final doing = tasks
                .where((t) => !t.isCompleted && t.priority == TaskPriority.urgent)
                .toList();
            final done = tasks.where((t) => t.isCompleted).toList();

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _KanbanColumn(
                    title: AppLocalizations.of(context)!.todo,
                    tasks: todo,
                    color: AppTheme.priorityColors[3]!, // Medium priority color
                  ),
                  _KanbanColumn(
                    title: 'Doing',
                    tasks: doing,
                    color: AppTheme.priorityColors[1]!, // Urgent priority color
                  ),
                  _KanbanColumn(
                    title: AppLocalizations.of(context)!.completed,
                    tasks: done,
                    color: AppTheme.priorityColors[4]!, // Low priority color (green)
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// A single column in the Kanban view
class _KanbanColumn extends StatelessWidget {
  final String title;
  final List<Task> tasks;
  final Color color;

  const _KanbanColumn({
    required this.title,
    required this.tasks,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              Text(
                '${tasks.length}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: tasks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final task = tasks[i];
                return _KanbanTaskCard(task: task);
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Card for a task in Kanban view
class _KanbanTaskCard extends StatelessWidget {
  final Task task;

  const _KanbanTaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                decoration: task.isCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
            const SizedBox(height: 8),
            if (task.dueDate != null) ...[
              Text(
                _formatDate(task.dueDate!, context),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
            ],
            if (task.tags.isNotEmpty) ...[
              Wrap(
                spacing: 4,
                children: task.tags.map((tag) => _TagChip(tag: tag)).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date, BuildContext context) {
    final now = DateTime.now().toUtc();
    final today = DateTime.utc(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime.utc(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == tomorrow) {
      return 'Tomorrow';
    } else if (dateOnly.isBefore(today)) {
      return 'Overdue';
    } else {
      return '${date.month}/${date.day}';
    }
  }
}

/// Chip for displaying a tag
class _TagChip extends StatelessWidget {
  final String tag;

  const _TagChip({required this.tag});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        '#$tag',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          fontSize: 10,
        ),
      ),
      backgroundColor: AppTheme.getTagColor(tag),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
