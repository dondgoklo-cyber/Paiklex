import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/di.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../cubits/task_list_cubit.dart';
import '../widgets/task_tile.dart';
import '../widgets/task_quick_add.dart';
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
              onPressed: () => context.push('/search'),
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => context.push('/settings'),
            ),
          ],
        ),
        body: Column(
          children: [
            const TaskQuickAdd(),
            Expanded(
              child: BlocBuilder<TaskListCubit, TaskListState>(
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
                        onTap: () => context.push('/tasks/${task.id}'),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.push('/tasks'),
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
                context.push('/tasks');
                break;
              case 1:
                context.push('/calendar');
                break;
              case 2:
                context.push('/kanban');
                break;
            }
          },
        ),
      ),
    );
  }
}
