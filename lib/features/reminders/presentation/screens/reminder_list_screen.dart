import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/di.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../cubits/reminder_list_cubit.dart';
import '../../domain/entities/reminder.dart';

/// Screen for listing all reminders
class ReminderListScreen extends StatelessWidget {
  const ReminderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ReminderListCubit>()..watch(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.reminders),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: AppLocalizations.of(context)!.addReminder,
              onPressed: () => context.push('/reminders/create'),
            ),
          ],
        ),
        body: BlocBuilder<ReminderListCubit, ReminderListState>(
          builder: (context, state) {
            if (state.status == ReminderListStatus.loading) {
              return const LoadingView();
            }
            if (state.status == ReminderListStatus.error) {
              return ErrorView(
                message: state.errorMessage ?? 'Error loading reminders',
                onRetry: () => context.read<ReminderListCubit>().watch(),
              );
            }

            final reminders = state.reminders;

            if (reminders.isEmpty) {
              return EmptyState(
                icon: Icons.notifications_none,
                title: AppLocalizations.of(context)!.noReminders,
                subtitle: AppLocalizations.of(context)!.noRemindersDesc,
                action: ElevatedButton(
                  onPressed: () => context.push('/reminders/create'),
                  child: Text(AppLocalizations.of(context)!.addReminder),
                ),
              );
            }

            return ListView.builder(
              itemCount: reminders.length,
              itemBuilder: (context, i) {
                final reminder = reminders[i];
                return _ReminderTile(
                  reminder: reminder,
                  onCancel: () => context.read<ReminderListCubit>().cancel(reminder.id),
                  onTap: () => context.push('/reminders/${reminder.id}'),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// Tile for a single reminder
class _ReminderTile extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback onCancel;
  final VoidCallback onTap;

  const _ReminderTile({
    required this.reminder,
    required this.onCancel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final triggerDate = reminder.triggerAt.toLocal();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.notifications_active),
        title: Text(reminder.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${triggerDate.year}-${triggerDate.month.toString().padLeft(2, '0')}-${triggerDate.day.toString().padLeft(2, '0')} ${triggerDate.hour.toString().padLeft(2, '0')}:${triggerDate.minute.toString().padLeft(2, '0')}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (reminder.body != null)
              Text(
                reminder.body!,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.cancel_outlined),
          tooltip: l10n.cancel,
          onPressed: onCancel,
        ),
        onTap: onTap,
      ),
    );
  }
}
