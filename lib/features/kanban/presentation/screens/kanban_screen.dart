import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../app/di.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../tasks/presentation/cubits/task_list_cubit.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../../tasks/domain/entities/priority.dart';
import '../../../tasks/domain/usecases/reorder_task.dart';
import '../../../../shared/theme/app_theme.dart';

/// Kanban view screen with 3 columns: To Do, Doing, Done with drag-n-drop
class KanbanScreen extends StatefulWidget {
  const KanbanScreen({super.key});

  @override
  State<KanbanScreen> createState() => _KanbanScreenState();
}

class _KanbanScreenState extends State<KanbanScreen> {
  final _todoKey = GlobalKey<_KanbanColumnState>();
  final _doingKey = GlobalKey<_KanbanColumnState>();
  final _doneKey = GlobalKey<_KanbanColumnState>();

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

            // Group tasks by status
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
                    key: _todoKey,
                    title: AppLocalizations.of(context)!.todo,
                    tasks: todo,
                    color: AppTheme.priorityColors[3]!,
                    columnType: _KanbanColumnType.todo,
                    onReorder: _onReorder,
                  ),
                  _KanbanColumn(
                    key: _doingKey,
                    title: AppLocalizations.of(context)!.doing,
                    tasks: doing,
                    color: AppTheme.priorityColors[1]!,
                    columnType: _KanbanColumnType.doing,
                    onReorder: _onReorder,
                  ),
                  _KanbanColumn(
                    key: _doneKey,
                    title: AppLocalizations.of(context)!.completed,
                    tasks: done,
                    color: AppTheme.priorityColors[4]!,
                    columnType: _KanbanColumnType.done,
                    onReorder: _onReorder,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _onReorder(String taskId, _KanbanColumnType fromColumn, int oldIndex,
      _KanbanColumnType toColumn, int newIndex) {
    final cubit = context.read<TaskListCubit>();
    final reorderTask = getIt<ReorderTask>();

    // Calculate new order index based on column and position
    final newOrderIndex = _calculateOrderIndex(toColumn, newIndex);

    // Execute reorder
    reorderTask.call(taskId, newOrderIndex).then((result) {
      result.fold(
        (failure) => null,
        (_) => cubit.watch(),
      );
    });
  }

  int _calculateOrderIndex(_KanbanColumnType column, int index) {
    // Base index for each column
    switch (column) {
      case _KanbanColumnType.todo:
        return index * 1000;
      case _KanbanColumnType.doing:
        return 10000 + index * 1000;
      case _KanbanColumnType.done:
        return 20000 + index * 1000;
    }
  }
}

/// Column types for Kanban board
enum _KanbanColumnType {
  todo,
  doing,
  done,
}

/// A single column in the Kanban view with drag-n-drop support
class _KanbanColumn extends StatefulWidget {
  final String title;
  final List<Task> tasks;
  final Color color;
  final _KanbanColumnType columnType;
  final Function(String, _KanbanColumnType, int, _KanbanColumnType, int) onReorder;

  const _KanbanColumn({
    super.key,
    required this.title,
    required this.tasks,
    required this.color,
    required this.columnType,
    required this.onReorder,
  });

  @override
  State<_KanbanColumn> createState() => _KanbanColumnState();
}

class _KanbanColumnState extends State<_KanbanColumn> {
  late List<Task> _tasks;

  @override
  void initState() {
    super.initState();
    _tasks = List.from(widget.tasks);
  }

  @override
  void didUpdateWidget(_KanbanColumn oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tasks != widget.tasks) {
      setState(() => _tasks = List.from(widget.tasks));
    }
  }

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
                  color: widget.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              Text(
                '${_tasks.length}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _buildDragDropList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDragDropList(BuildContext context) {
    if (_tasks.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.empty,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }

    return ReorderableListView.builder(
      itemCount: _tasks.length,
      itemBuilder: (context, i) {
        final task = _tasks[i];
        return _DraggableKanbanTaskCard(
          key: ValueKey(task.id),
          task: task,
          columnType: widget.columnType,
          onDragStarted: () {},
          onDragCompleted: () {},
        );
      },
      onReorder: (oldIndex, newIndex) {
        if (oldIndex < newIndex) {
          newIndex -= 1;
        }
        final movedTask = _tasks.removeAt(oldIndex);
        _tasks.insert(newIndex, movedTask);
        
        // Notify parent about reorder within same column
        widget.onReorder(
          movedTask.id,
          widget.columnType,
          oldIndex,
          widget.columnType,
          newIndex,
        );
      },
    );
  }
}

/// Draggable task card for Kanban with cross-column support
class _DraggableKanbanTaskCard extends StatelessWidget {
  final Task task;
  final _KanbanColumnType columnType;
  final VoidCallback onDragStarted;
  final VoidCallback onDragCompleted;

  const _DraggableKanbanTaskCard({
    super.key,
    required this.task,
    required this.columnType,
    required this.onDragStarted,
    required this.onDragCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<Task>(
      builder: (context, candidateData, rejectedData) {
        return Draggable<Task>(
          key: key,
          data: task,
          feedback: Material(
            elevation: 8,
            child: _KanbanTaskCard(task: task, isDragging: true),
          ),
          childWhenDragging: _KanbanTaskCard(task: task, isDragging: false),
          child: _KanbanTaskCard(task: task, isDragging: false),
          onDragStarted: onDragStarted,
          onDragEnd: (_) => onDragCompleted,
        );
      },
      onWillAccept: (data) => true,
      onAccept: (receivedTask) {
        if (receivedTask.id != task.id) {
          // Task moved from another column
          final cubit = context.read<TaskListCubit>();
          final reorderTask = getIt<ReorderTask>();
          
          // Determine the new column type based on where it was dropped
          final targetColumn = _getColumnTypeForTask(task);
          
          // Calculate new order index
          final tasksInTarget = _getTasksForColumn(context, targetColumn);
          final newIndex = tasksInTarget.length;
          final newOrderIndex = _calculateOrderIndex(targetColumn, newIndex);
          
          reorderTask.call(receivedTask.id, newOrderIndex).then((result) {
            result.fold(
              (failure) => null,
              (_) => cubit.watch(),
            );
          });
        }
      },
    );
  }

  _KanbanColumnType _getColumnTypeForTask(Task task) {
    if (task.isCompleted) return _KanbanColumnType.done;
    if (task.priority == TaskPriority.urgent) return _KanbanColumnType.doing;
    return _KanbanColumnType.todo;
  }

  List<Task> _getTasksForColumn(BuildContext context, _KanbanColumnType type) {
    final state = context.read<TaskListCubit>().state;
    if (state is! TaskListLoaded) return [];
    
    switch (type) {
      case _KanbanColumnType.todo:
        return state.tasks
            .where((t) => !t.isCompleted && t.priority != TaskPriority.urgent)
            .toList();
      case _KanbanColumnType.doing:
        return state.tasks
            .where((t) => !t.isCompleted && t.priority == TaskPriority.urgent)
            .toList();
      case _KanbanColumnType.done:
        return state.tasks.where((t) => t.isCompleted).toList();
    }
  }

  int _calculateOrderIndex(_KanbanColumnType column, int index) {
    switch (column) {
      case _KanbanColumnType.todo:
        return index * 1000;
      case _KanbanColumnType.doing:
        return 10000 + index * 1000;
      case _KanbanColumnType.done:
        return 20000 + index * 1000;
    }
  }
}

/// Card for a task in Kanban view
class _KanbanTaskCard extends StatelessWidget {
  final Task task;
  final bool isDragging;

  const _KanbanTaskCard({required this.task, this.isDragging = false});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isDragging ? 0.5 : 1.0,
      child: Card(
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
      ),
    );
  }

  String _formatDate(DateTime date, BuildContext context) {
    final now = DateTime.now().toUtc();
    final today = DateTime.utc(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime.utc(date.year, date.month, date.day);

    if (dateOnly == today) {
      return AppLocalizations.of(context)!.today;
    } else if (dateOnly == tomorrow) {
      return AppLocalizations.of(context)!.tomorrow;
    } else if (dateOnly.isBefore(today)) {
      return AppLocalizations.of(context)!.overdue;
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
