import 'package:go_router/go_router.dart';
import '../features/tasks/presentation/screens/task_list_screen.dart';
import '../features/tasks/presentation/screens/task_detail_screen.dart';
import '../features/kanban/presentation/screens/kanban_screen.dart';
import '../features/calendar_view/presentation/screens/calendar_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/search/presentation/screens/search_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/projects/presentation/screens/project_list_screen.dart';
import '../features/projects/presentation/screens/project_detail_screen.dart';
import '../features/habits/presentation/screens/habit_list_screen.dart';
import '../features/habits/presentation/screens/habit_detail_screen.dart';
import '../features/reminders/presentation/screens/reminder_list_screen.dart';
import '../features/reminders/presentation/screens/reminder_detail_screen.dart';

/// Application router configuration
final router = GoRouter(
  initialLocation: '/tasks',
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/tasks',
      builder: (context, state) => const TaskListScreen(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return TaskDetailScreen(taskId: id);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/kanban',
      builder: (context, state) => const KanbanScreen(),
    ),
    GoRoute(
      path: '/calendar',
      builder: (context, state) => const CalendarScreen(),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    // ==========================================================================
    // Projects
    // ==========================================================================
    GoRoute(
      path: '/projects',
      builder: (context, state) => const ProjectListScreen(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return ProjectDetailScreen(projectId: id);
          },
        ),
      ],
    ),
    // ==========================================================================
    // Habits
    // ==========================================================================
    GoRoute(
      path: '/habits',
      builder: (context, state) => const HabitListScreen(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return HabitDetailScreen(habitId: id);
          },
        ),
      ],
    ),
    // ==========================================================================
    // Reminders
    // ==========================================================================
    GoRoute(
      path: '/reminders',
      builder: (context, state) => const ReminderListScreen(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return ReminderDetailScreen(reminderId: id);
          },
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Route not found: ${state.uri}'),
    ),
  ),
);
