import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/di.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/logger.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/priority.dart';
import '../../domain/usecases/create_task.dart';
import '../../domain/usecases/update_task.dart';
import '../../domain/usecases/get_task.dart';
import '../../domain/usecases/get_all_tasks.dart';
import '../../domain/usecases/delete_task.dart';

/// Screen for viewing and editing task details
class TaskDetailScreen extends StatefulWidget {
  final String? taskId;

  const TaskDetailScreen({super.key, this.taskId});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _contentController = TextEditingController();
  final _descriptionController = TextEditingController();
  TaskPriority _priority = TaskPriority.medium;
  DateTime? _dueDate;
  final _tagsController = TextEditingController();
  final _subtasksController = TextEditingController();
  List<Task> _subtasks = [];
  bool _isLoading = false;
  final _logger = AppLogger.forService('TaskDetailScreen');

  late final CreateTask _createTask;
  late final UpdateTask _updateTask;
  late final GetTask _getTask;
  late final GetAllTasks _getAllTasks;
  late final DeleteTask _deleteTask;

  @override
  void initState() {
    super.initState();
    _createTask = getIt<CreateTask>();
    _updateTask = getIt<UpdateTask>();
    _getTask = getIt<GetTask>();
    _getAllTasks = getIt<GetAllTasks>();
    _deleteTask = getIt<DeleteTask>();

    if (widget.taskId != null) {
      _loadTask();
    }
  }

  Future<void> _loadTask() async {
    setState(() => _isLoading = true);
    try {
      final result = await _getTask(widget.taskId!);
      result.fold(
        (failure) {
          _logger.e('Failed to load task', error: failure);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(failure.message)),
            );
          }
        },
        (task) {
          if (task != null) {
            if (mounted) {
              _contentController.text = task.content;
              _descriptionController.text = task.description ?? '';
              _priority = task.priority;
              _dueDate = task.dueDate;
              _tagsController.text = task.tags.join(', ');
            }
          }
        },
      );

      // Load subtasks
      final subtasksResult = await _getAllTasks.call();
      subtasksResult.fold(
        (failure) => _logger.e('Failed to load subtasks', error: failure),
        (allTasks) {
          if (mounted) {
            setState(() {
              _subtasks = allTasks
                  .where((t) => t.parentTaskId == widget.taskId)
                  .toList();
            });
          }
        },
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    _subtasksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.taskId == null ? l10n.addTask : l10n.edit),
        actions: [
          if (widget.taskId != null)
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
                  // Content
                  TextField(
                    controller: _contentController,
                    decoration: InputDecoration(
                      labelText: l10n.taskContent,
                      border: const OutlineInputBorder(),
                    ),
                    maxLength: 2000,
                    autofocus: widget.taskId == null,
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: l10n.description,
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  // Priority
                  DropdownButtonFormField<TaskPriority>(
                    value: _priority,
                    items: TaskPriority.values.map((p) {
                      return DropdownMenuItem(
                        value: p,
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Color(p.colorValue),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(_getPriorityName(p, l10n)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _priority = value);
                      }
                    },
                    decoration: InputDecoration(
                      labelText: l10n.priority,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Due Date
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: TextEditingController(
                            text: _dueDate != null
                                ? '${_dueDate!.toLocal().year}-${_dueDate!.toLocal().month.toString().padLeft(2, '0')}-${_dueDate!.toLocal().day.toString().padLeft(2, '0')}'
                                : '',
                          ),
                          decoration: InputDecoration(
                            labelText: l10n.dueDate,
                            border: const OutlineInputBorder(),
                            suffixIcon: const Icon(Icons.calendar_today),
                          ),
                          readOnly: true,
                          onTap: _pickDate,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tags
                  TextField(
                    controller: _tagsController,
                    decoration: InputDecoration(
                      labelText: l10n.tags,
                      hintText: l10n.addTag,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.tagsHint,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),

                  // Subtasks
                  _SubtasksSection(
                    subtasks: _subtasks,
                    onToggle: _toggleSubtask,
                    onDelete: _deleteSubtask,
                    onAdd: _addSubtask,
                  ),
                  const SizedBox(height: 24),

                  // Save button
                  FilledButton(
                    onPressed: _save,
                    child: Text(widget.taskId == null ? l10n.save : l10n.save),
                  ),
                ],
              ),
            ),
      floatingActionButton: widget.taskId != null
          ? FloatingActionButton(
              onPressed: _save,
              tooltip: l10n.save,
              child: const Icon(Icons.save),
            )
          : null,
    );
  }

  String _getPriorityName(TaskPriority p, AppLocalizations l10n) {
    switch (p) {
      case TaskPriority.urgent:
        return l10n.urgent;
      case TaskPriority.high:
        return l10n.high;
      case TaskPriority.medium:
        return l10n.medium;
      case TaskPriority.low:
        return l10n.low;
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now().toUtc();
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date != null) {
      if (mounted) {
        setState(() => _dueDate = DateTime.utc(date.year, date.month, date.day));
      }
    }
  }

  Future<void> _toggleSubtask(Task subtask) async {
    final updatedSubtask = subtask.copyWith(
      isCompleted: !subtask.isCompleted,
      updatedAt: DateTime.now().toUtc(),
    );

    final result = await _updateTask(updatedSubtask);
    result.fold(
      (failure) {
        _logger.e('Failed to toggle subtask', error: failure);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(failure.message)),
          );
        }
      },
      (savedTask) {
        if (mounted) {
          setState(() {
            final index = _subtasks.indexWhere((t) => t.id == subtask.id);
            if (index != -1) {
              _subtasks[index] = savedTask;
            }
          });
        }
      },
    );
  }

  Future<void> _deleteSubtask(Task subtask) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: l10n.delete,
      message: '${l10n.delete} ${l10n.subtasks.toLowerCase()}?',
      confirmText: l10n.yes,
      cancelText: l10n.no,
    );

    if (confirmed == true) {
      final result = await _deleteTask(subtask.id);
      result.fold(
        (failure) {
          _logger.e('Failed to delete subtask', error: failure);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(failure.message)),
            );
          }
        },
        (_) {
          _logger.d('Subtask deleted: ${subtask.id}');
          if (mounted) {
            setState(() {
              _subtasks.removeWhere((t) => t.id == subtask.id);
            });
          }
        },
      );
    }
  }

  Future<void> _addSubtask() async {
    if (_subtasksController.text.trim().isEmpty) return;

    final newSubtask = Task(
      id: '',
      parentTaskId: widget.taskId,
      content: _subtasksController.text.trim(),
      priority: TaskPriority.medium,
      createdAt: AppDateUtils.nowUtc(),
      updatedAt: AppDateUtils.nowUtc(),
    );

    final result = await _createTask(newSubtask);
    result.fold(
      (failure) {
        _logger.e('Failed to save subtask', error: failure);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(failure.message)),
          );
        }
      },
      (savedTask) {
        _logger.d('Subtask saved: ${savedTask.id}');
        if (mounted) {
          setState(() {
            _subtasks.add(savedTask);
            _subtasksController.clear();
          });
        }
      },
    );
  }

  Future<void> _save() async {
    if (_contentController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.contentCannotBeEmpty)),
        );
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      final tags = _tagsController.text
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      final task = Task(
        id: widget.taskId ?? '',
        content: _contentController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        priority: _priority,
        dueDate: _dueDate,
        tags: tags,
        createdAt: widget.taskId == null
            ? AppDateUtils.nowUtc()
            : AppDateUtils.nowUtc(),
        updatedAt: AppDateUtils.nowUtc(),
      );

      final result = widget.taskId == null
          ? await _createTask(task)
          : await _updateTask(task);

      result.fold(
        (failure) {
          _logger.e('Failed to save task', error: failure);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(failure.message)),
            );
          }
        },
        (savedTask) {
          _logger.d('Task saved: ${savedTask.id}');
          if (mounted) context.pop(savedTask);
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
      message: l10n.deleteConfirmation,
      confirmText: l10n.yes,
      cancelText: l10n.no,
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        final result = await _deleteTask(widget.taskId!);
        result.fold(
          (failure) {
            _logger.e('Failed to delete task', error: failure);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(failure.message)),
              );
            }
          },
          (_) {
            _logger.d('Task deleted: ${widget.taskId}');
            if (mounted) context.pop();
          },
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }
}

/// Section for displaying and managing subtasks
class _SubtasksSection extends StatelessWidget {
  final List<Task> subtasks;
  final Function(Task) onToggle;
  final Function(Task) onDelete;
  final VoidCallback onAdd;

  const _SubtasksSection({
    required this.subtasks,
    required this.onToggle,
    required this.onDelete,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.subtasks,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: l10n.addSubtask,
              onPressed: onAdd,
            ),
          ],
        ),
        if (subtasks.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              l10n.noSubtasks,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ...subtasks.map((subtask) {
          return _SubtaskTile(
            key: ValueKey(subtask.id),
            subtask: subtask,
            onToggle: () => onToggle(subtask),
            onDelete: () => onDelete(subtask),
          );
        }).toList(),
      ],
    );
  }
}

/// Tile for a single subtask
class _SubtaskTile extends StatelessWidget {
  final Task subtask;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _SubtaskTile({
    super.key,
    required this.subtask,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Checkbox(
          value: subtask.isCompleted,
          onChanged: (_) => onToggle(),
        ),
        title: Text(
          subtask.content,
          style: TextStyle(
            decoration: subtask.isCompleted
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, size: 20),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
