import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../app/di.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../tasks/presentation/cubits/task_list_cubit.dart';
import '../../../tasks/domain/entities/task.dart';

/// Search screen for filtering tasks by content and tags
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  List<Task> _filterTasks(List<Task> tasks, String query) {
    if (query.isEmpty) return [];

    final lower = query.toLowerCase();
    return tasks.where((t) {
      // Match content
      if (t.content.toLowerCase().contains(lower)) return true;
      // Match tags
      if (t.tags.any((tag) => tag.toLowerCase().contains(lower))) return true;
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TaskListCubit>()..watch(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.search),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: AppLocalizations.of(context)!.searchHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
                ),
                onSubmitted: (_) => FocusScope.of(context).unfocus(),
              ),
            ),
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

                  final query = _searchController.text;
                  final filtered = _filterTasks(state.tasks, query);

                  if (query.isEmpty) {
                    return EmptyState(
                      icon: Icons.search,
                      title: AppLocalizations.of(context)!.searchEmptyTitle,
                      subtitle: AppLocalizations.of(context)!.searchEmptySubtitle,
                    );
                  }

                  if (filtered.isEmpty) {
                    return EmptyState(
                      icon: Icons.search_off,
                      title: AppLocalizations.of(context)!.noResults,
                      subtitle: AppLocalizations.of(context)!.noResultsDesc,
                    );
                  }

                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final task = filtered[i];
                      return _SearchTaskTile(task: task);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Task tile for search results
class _SearchTaskTile extends StatelessWidget {
  final Task task;

  const _SearchTaskTile({required this.task});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: task.isCompleted,
        onChanged: (_) => context.read<TaskListCubit>().toggle(task.id),
      ),
      title: Text(
        task.content,
        style: TextStyle(
          decoration: task.isCompleted
              ? TextDecoration.lineThrough
              : TextDecoration.none,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (task.dueDate != null) ...[
            Text(
              task.dueDate!.toLocal().toString().split(' ')[0],
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          if (task.tags.isNotEmpty) ...[
            Wrap(
              spacing: 4,
              children: task.tags
                  .map((t) => Chip(
                        label: Text('#$t'),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
      trailing: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: Color(task.priority.colorValue),
          shape: BoxShape.circle,
        ),
      ),
      onTap: () => context.push('/tasks/${task.id}'),
    );
  }
}
