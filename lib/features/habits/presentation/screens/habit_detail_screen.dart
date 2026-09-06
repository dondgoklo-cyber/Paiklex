import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import '../../../../app/di.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../domain/entities/habit.dart';
import '../../domain/usecases/get_habit.dart';
import '../../domain/usecases/update_habit.dart';
import '../../domain/usecases/delete_habit.dart';
import '../cubits/habit_list_cubit.dart';

/// Screen for viewing and editing habit details
class HabitDetailScreen extends StatefulWidget {
  final String habitId;

  const HabitDetailScreen({super.key, required this.habitId});

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  final _titleController = TextEditingController();
  String _frequency = 'daily';
  bool _isLoading = false;
  final _logger = Logger('HabitDetailScreen');

  late final GetHabit _getHabit;
  late final UpdateHabit _updateHabit;
  late final DeleteHabit _deleteHabit;

  @override
  void initState() {
    super.initState();
    _getHabit = getIt<GetHabit>();
    _updateHabit = getIt<UpdateHabit>();
    _deleteHabit = getIt<DeleteHabit>();

    _loadHabit();
  }

  Future<void> _loadHabit() async {
    setState(() => _isLoading = true);
    try {
      final result = await _getHabit(widget.habitId);
      result.fold(
        (failure) {
          _logger.e('Failed to load habit', error: failure);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(failure.message)),
            );
          }
        },
        (habit) {
          if (habit != null && mounted) {
            _titleController.text = habit.title;
            _frequency = habit.frequency;
          }
        },
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => getIt<HabitListCubit>()..watch(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.editHabit),
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
                    // Title
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: l10n.habitTitle,
                        border: const OutlineInputBorder(),
                      ),
                      maxLength: 100,
                      autofocus: true,
                    ),
                    const SizedBox(height: 16),

                    // Frequency
                    DropdownButtonFormField<String>(
                      value: _frequency,
                      items: [
                        DropdownMenuItem(
                          value: 'daily',
                          child: Text(l10n.daily),
                        ),
                        DropdownMenuItem(
                          value: 'weekly',
                          child: Text(l10n.weekly),
                        ),
                        DropdownMenuItem(
                          value: 'monthly',
                          child: Text(l10n.monthly),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _frequency = value);
                        }
                      },
                      decoration: InputDecoration(
                        labelText: l10n.frequency,
                        border: const OutlineInputBorder(),
                      ),
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
    if (_titleController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.habitTitleCannotBeEmpty)),
        );
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Get existing habit to preserve streak data
      final existingResult = await _getHabit(widget.habitId);
      final existingHabit = existingResult.getOrElse(() => null);

      final habit = Habit(
        id: widget.habitId,
        title: _titleController.text.trim(),
        frequency: _frequency,
        streak: existingHabit?.streak ?? 0,
        bestStreak: existingHabit?.bestStreak ?? 0,
        lastCompletedAt: existingHabit?.lastCompletedAt,
        createdAt: existingHabit?.createdAt ?? DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
      );

      final result = await _updateHabit(habit);
      result.fold(
        (failure) {
          _logger.e('Failed to update habit', error: failure);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(failure.message)),
            );
          }
        },
        (updatedHabit) {
          _logger.d('Habit updated: ${updatedHabit.id}');
          if (mounted) context.pop(updatedHabit);
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
      message: l10n.deleteHabitConfirmation,
      confirmText: l10n.yes,
      cancelText: l10n.no,
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        final result = await _deleteHabit(widget.habitId);
        result.fold(
          (failure) {
            _logger.e('Failed to delete habit', error: failure);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(failure.message)),
              );
            }
          },
          (_) {
            _logger.d('Habit deleted: ${widget.habitId}');
            if (mounted) context.pop();
          },
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }
}
