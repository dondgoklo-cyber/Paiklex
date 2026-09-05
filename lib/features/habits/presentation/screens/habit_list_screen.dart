import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/di.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../cubits/habit_list_cubit.dart';
import '../../domain/entities/habit.dart';

/// Screen for listing all habits
class HabitListScreen extends StatelessWidget {
  const HabitListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HabitListCubit>()..watch(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.habits),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: AppLocalizations.of(context)!.addHabit,
              onPressed: () => _showCreateDialog(context),
            ),
          ],
        ),
        body: BlocBuilder<HabitListCubit, HabitListState>(
          builder: (context, state) {
            if (state.status == HabitListStatus.loading) {
              return const LoadingView();
            }
            if (state.status == HabitListStatus.error) {
              return ErrorView(
                message: state.errorMessage ?? 'Error loading habits',
                onRetry: () => context.read<HabitListCubit>().watch(),
              );
            }

            final habits = state.habits;

            if (habits.isEmpty) {
              return EmptyState(
                icon: Icons.flag,
                title: AppLocalizations.of(context)!.noHabits,
                subtitle: AppLocalizations.of(context)!.noHabitsDesc,
                action: ElevatedButton(
                  onPressed: () => _showCreateDialog(context),
                  child: Text(AppLocalizations.of(context)!.addHabit),
                ),
              );
            }

            return ListView.builder(
              itemCount: habits.length,
              itemBuilder: (context, i) {
                final habit = habits[i];
                return _HabitTile(
                  habit: habit,
                  onComplete: () => context.read<HabitListCubit>().complete(habit.id),
                  onDelete: () => _confirmDelete(context, habit.id),
                  onTap: () => context.push('/habits/${habit.id}'),
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
    final titleController = TextEditingController();

    final created = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.addHabit),
        content: TextField(
          controller: titleController,
          decoration: InputDecoration(
            labelText: l10n.habitTitle,
            hintText: l10n.habitTitleHint,
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

    if (created == true && titleController.text.trim().isNotEmpty) {
      context.read<HabitListCubit>().create(titleController.text.trim());
    }
  }

  Future<void> _confirmDelete(BuildContext context, String habitId) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.delete),
        content: Text(l10n.deleteHabitConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.no),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.yes),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      context.read<HabitListCubit>().delete(habitId);
    }
  }
}

/// Tile for a single habit
class _HabitTile extends StatelessWidget {
  final Habit habit;
  final VoidCallback onComplete;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _HabitTile({
    required this.habit,
    required this.onComplete,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: _StreakIndicator(
          streak: habit.streak,
          bestStreak: habit.bestStreak,
        ),
        title: Text(habit.title),
        subtitle: Row(
          children: [
            Text(
              _getFrequencyText(habit.frequency, l10n),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (habit.isDueToday)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  l10n.dueToday,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check_circle_outline),
              tooltip: l10n.complete,
              onPressed: onComplete,
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

  String _getFrequencyText(String frequency, AppLocalizations l10n) {
    switch (frequency) {
      case 'daily':
        return l10n.daily;
      case 'weekly':
        return l10n.weekly;
      case 'monthly':
        return l10n.monthly;
      default:
        return frequency;
    }
  }
}

/// Streak indicator widget
class _StreakIndicator extends StatelessWidget {
  final int streak;
  final int bestStreak;

  const _StreakIndicator({
    required this.streak,
    required this.bestStreak,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    if (streak == 0) {
      return const Icon(Icons.flag_outline, color: Colors.grey);
    }

    return Tooltip(
      message: '${l10n.streak}: $streak (${l10n.best}: $bestStreak)',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flag, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 4),
          Text('$streak'),
        ],
      ),
    );
  }
}
