import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../app/di.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../cubits/task_list_cubit.dart';
import '../widgets/task_tile.dart';
import 'task_detail_screen.dart';

/// Screen for displaying the list of tasks
class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TaskListCubit>()..watch(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.tasks),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => Navigator.pushNamed(context, '/search'),
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => Navigator.pushNamed(context, '/settings'),
            ),
          ],
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
            if (state.tasks.isEmpty) {
              return EmptyState(
                icon: Icons.check_circle_outline,
                title: 'No tasks',
                subtitle: 'Add your first task to get started',
              );
            }
            return ListView.builder(
              itemCount: state.tasks.length,
              itemBuilder: (context, index) {
                final task = state.tasks[index];
                return TaskTile(
                  task: task,
                  onToggle: () => context.read<TaskListCubit>().toggle(task.id),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TaskDetailScreen(taskId: task.id),
                    ),
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TaskDetailScreen(),
            ),
          ),
          child: const Icon(Icons.add),
        ),
        bottomNavigationBar: NavigationBar(
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.list_alt),
              label: 'Tasks',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_today),
              label: 'Calendar',
            ),
            NavigationDestination(
              icon: Icon(Icons.view_kanban),
              label: 'Kanban',
            ),
          ],
          selectedIndex: 0,
          onDestinationSelected: (index) {
            switch (index) {
              case 0:
                Navigator.pushNamed(context, '/tasks');
                break;
              case 1:
                Navigator.pushNamed(context, '/calendar');
                break;
              case 2:
                Navigator.pushNamed(context, '/kanban');
                break;
            }
          },
        ),
      ),
    );
  }
}
