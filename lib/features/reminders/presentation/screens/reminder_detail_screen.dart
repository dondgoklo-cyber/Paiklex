import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import '../../../../app/di.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../domain/entities/reminder.dart';
import '../../domain/usecases/watch_reminders.dart';
import '../../domain/usecases/schedule_reminder.dart';
import '../cubits/reminder_list_cubit.dart';

/// Screen for viewing and editing reminder details
class ReminderDetailScreen extends StatefulWidget {
  final String reminderId;

  const ReminderDetailScreen({super.key, required this.reminderId});

  @override
  State<ReminderDetailScreen> createState() => _ReminderDetailScreenState();
}

class _ReminderDetailScreenState extends State<ReminderDetailScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  DateTime? _triggerAt;
  bool _isLoading = false;
  final _logger = Logger('ReminderDetailScreen');

  late final GetReminder _getReminder;
  late final UpdateReminder _updateReminder;
  late final DeleteReminder _deleteReminder;

  @override
  void initState() {
    super.initState();
    _getReminder = getIt<GetReminder>();
    _updateReminder = getIt<UpdateReminder>();
    _deleteReminder = getIt<DeleteReminder>();

    _loadReminder();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _loadReminder() async {
    setState(() => _isLoading = true);
    try {
      final result = await _getReminder(widget.reminderId);
      result.fold(
        (failure) {
          _logger.error('Failed to load reminder: ${failure.message}');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context)!.error)),
            );
          }
        },
        (reminder) {
          _titleController.text = reminder.title;
          _bodyController.text = reminder.body ?? '';
          _triggerAt = reminder.triggerAt;
          if (mounted) setState(() => _isLoading = false);
        },
      );
    } catch (e) {
      _logger.error('Exception loading reminder: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveReminder() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.contentCannotBeEmpty)),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final reminder = Reminder(
        id: widget.reminderId,
        title: _titleController.text,
        body: _bodyController.text.isEmpty ? null : _bodyController.text,
        triggerAt: _triggerAt ?? DateTime.now().toUtc(),
        isTriggered: false,
        taskId: null,
        habitId: null,
        createdAt: DateTime.now().toUtc(),
      );

      final result = await _updateReminder(reminder);
      result.fold(
        (failure) {
          _logger.error('Failed to update reminder: ${failure.message}');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${AppLocalizations.of(context)!.error}: ${failure.message}')),
            );
          }
        },
        (_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context)!.save)),
            );
            context.pop();
          }
        },
      );
    } catch (e) {
      _logger.error('Exception updating reminder: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteReminder() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: AppLocalizations.of(context)!.delete,
      message: AppLocalizations.of(context)!.deleteConfirmation,
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        final result = await _deleteReminder(widget.reminderId);
        result.fold(
          (failure) {
            _logger.error('Failed to delete reminder: ${failure.message}');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${AppLocalizations.of(context)!.error}: ${failure.message}')),
              );
            }
          },
          (_) {
            if (mounted) {
              context.pop();
              context.pop();
            }
          },
        );
      } catch (e) {
        _logger.error('Exception deleting reminder: $e');
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectTriggerDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _triggerAt ?? AppDateUtils.nowUtc().toLocal(),
      firstDate: AppDateUtils.nowUtc().toLocal(),
      lastDate: AppDateUtils.nowUtc().toLocal().add(const Duration(days: 365)),
    );

    if (selectedDate != null) {
      final selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_triggerAt ?? AppDateUtils.nowUtc().toLocal()),
      );

      if (selectedTime != null) {
        setState(() {
          _triggerAt = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          ).toUtc();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.edit),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: l10n.delete,
            onPressed: _isLoading ? null : _deleteReminder,
          ),
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: l10n.save,
            onPressed: _isLoading ? null : _saveReminder,
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
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: l10n.reminderTitle,
                      border: const OutlineInputBorder(),
                    ),
                    maxLength: 255,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _bodyController,
                    decoration: InputDecoration(
                      labelText: l10n.description,
                      border: const OutlineInputBorder(),
                      hintText: l10n.tagsHint,
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.schedule),
                    label: Text(_triggerAt == null
                        ? l10n.reminderTime
                        : '${_triggerAt!.toLocal().year}-${_triggerAt!.toLocal().month.toString().padLeft(2, '0')}-${_triggerAt!.toLocal().day.toString().padLeft(2, '0')} ${_triggerAt!.toLocal().hour.toString().padLeft(2, '0')}:${_triggerAt!.toLocal().minute.toString().padLeft(2, '0')}'),
                    onPressed: _selectTriggerDate,
                  ),
                ],
              ),
            ),
    );
  }
}
