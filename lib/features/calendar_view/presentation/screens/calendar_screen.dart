import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../app/di.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../tasks/presentation/cubits/task_list_cubit.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../../../core/utils/date_utils.dart';

/// Helper function to compare two dates for same day
bool isSameDay(DateTime a, DateTime? b) {
  if (b == null) return false;
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

/// Calendar view screen using table_calendar
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TaskListCubit>()..watch(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.calendar),
        ),
        body: BlocBuilder<TaskListCubit, TaskListState>(
          builder: (context, state) {
            if (state.status == TaskListStatus.loading) {
              return const LoadingView();
            }

            final tasks = state.tasks;

            // Build events map: DateTime -> List<Task>
            final events = <DateTime, List<Task>>{};
            for (final t in tasks) {
              if (t.dueDate != null) {
                final day = AppDateUtils.dateOnlyUtc(t.dueDate!);
                events.putIfAbsent(day, () => []).add(t);
              }
            }

            return Column(
              children: [
                TableCalendar<Task>(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (d) => isSameDay(d, _selectedDay),
                  eventLoader: (day) {
                    final key = AppDateUtils.dateOnlyUtc(day.toUtc());
                    return events[key] ?? [];
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    setState(() => _focusedDay = focusedDay);
                  },
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: false,
                  ),
                ),
                const Divider(),
                Expanded(
                  child: _SelectedDayTasks(
                    day: _selectedDay,
                    tasks: tasks,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Widget for displaying tasks on the selected day
class _SelectedDayTasks extends StatelessWidget {
  final DateTime? day;
  final List<Task> tasks;

  const _SelectedDayTasks({required this.day, required this.tasks});

  @override
  Widget build(BuildContext context) {
    if (day == null) {
      return const Center(child: Text('Select a day'));
    }

    final dayKey = AppDateUtils.dateOnlyUtc(day!.toUtc());
    final dayTasks = tasks.where((t) {
      if (t.dueDate == null) return false;
      return AppDateUtils.dateOnlyUtc(t.dueDate!) == dayKey;
    }).toList();

    if (dayTasks.isEmpty) {
      return const Center(child: Text('No tasks for this day'));
    }

    return ListView.builder(
      itemCount: dayTasks.length,
      itemBuilder: (context, i) {
        final t = dayTasks[i];
        return ListTile(
          leading: Checkbox(
            value: t.isCompleted,
            onChanged: (_) => context.read<TaskListCubit>().toggle(t.id),
          ),
          title: Text(t.content),
          subtitle: Text(
            t.dueDate != null
                ? '${t.dueDate!.toLocal().hour}:${t.dueDate!.toLocal().minute.toString().padLeft(2, '0')}'
                : '',
          ),
          trailing: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: Color(t.priority.colorValue),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
