import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/priority.dart';
import '../../../../shared/theme/app_theme.dart';
import '../cubits/task_list_cubit.dart';

/// Widget for displaying a single task in a list
class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onToggle;
  final VoidCallback? onLongPress;

  const TaskTile({
    super.key,
    required this.task,
    this.onTap,
    this.onToggle,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = task.isCompleted;

    return ListTile(
      leading: Checkbox(
        value: isCompleted,
        onChanged: (value) {
          onToggle?.call();
        },
      ),
      title: Text(
        task.content,
        style: TextStyle(
          decoration: isCompleted ? TextDecoration.lineThrough : null,
          color: isCompleted ? theme.disabledColor : theme.textTheme.bodyLarge?.color,
        ),
      ),
      subtitle: _buildSubtitle(context, task),
      trailing: _buildPriorityIndicator(task.priority),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }

  Widget? _buildSubtitle(BuildContext context, Task task) {
    final parts = <String>[];

    // Due date
    if (task.dueDate != null) {
      final due = task.dueDate!;
      final now = DateTime.now().toUtc();
      final today = DateTime.utc(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));
      final dueDateOnly = DateTime.utc(due.year, due.month, due.day);

      if (dueDateOnly == today) {
        parts.add('Today');
      } else if (dueDateOnly == tomorrow) {
        parts.add('Tomorrow');
      } else if (dueDateOnly.isBefore(today)) {
        parts.add('Overdue');
      } else {
        parts.add('${due.month}/${due.day}');
      }
    }

    // Tags
    if (task.tags.isNotEmpty) {
      parts.add(task.tags.join(' '));
    }

    // Recurrence
    if (task.recurrence != null) {
      parts.add('(${task.recurrence})');
    }

    return parts.isNotEmpty
        ? Text(
            parts.join(' '),
            style: Theme.of(context).textTheme.bodySmall,
          )
        : null;
  }

  Widget _buildPriorityIndicator(TaskPriority priority) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: AppTheme.getPriorityColor(priority.value),
        shape: BoxShape.circle,
      ),
    );
  }
}
