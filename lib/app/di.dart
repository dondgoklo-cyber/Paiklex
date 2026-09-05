import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';
import '../features/tasks/data/repositories/task_repository_impl.dart';
import '../features/tasks/domain/repositories/task_repository.dart';
import '../features/tasks/domain/usecases/watch_tasks.dart';
import '../features/tasks/domain/usecases/create_task.dart';
import '../features/tasks/domain/usecases/update_task.dart';
import '../features/tasks/domain/usecases/delete_task.dart';
import '../features/tasks/domain/usecases/toggle_task.dart';
import '../features/tasks/domain/usecases/parse_and_create_task.dart';
import '../features/tasks/domain/usecases/reorder_task.dart';
import '../features/tasks/domain/usecases/get_task.dart';
import '../features/tasks/presentation/cubits/task_list_cubit.dart';
import '../features/settings/data/theme_service.dart';
import '../features/settings/data/locale_service.dart';
import '../features/sync/data/sync_service.dart';
import '../features/notifications/data/notification_service.dart';

// Projects
import '../features/projects/data/repositories/project_repository_impl.dart';
import '../features/projects/domain/repositories/project_repository.dart';
import '../features/projects/domain/usecases/watch_projects.dart';
import '../features/projects/domain/usecases/create_project.dart';
import '../features/projects/domain/usecases/update_project.dart';
import '../features/projects/presentation/cubits/project_list_cubit.dart';

// Habits
import '../features/habits/data/repositories/habit_repository_impl.dart';
import '../features/habits/domain/repositories/habit_repository.dart';
import '../features/habits/domain/usecases/watch_habits.dart';
import '../features/habits/domain/usecases/create_habit.dart';
import '../features/habits/domain/usecases/update_habit.dart';
import '../features/habits/presentation/cubits/habit_list_cubit.dart';

// Reminders
import '../features/reminders/data/repositories/reminder_repository_impl.dart';
import '../features/reminders/domain/repositories/reminder_repository.dart';
import '../features/reminders/domain/usecases/watch_reminders.dart';
import '../features/reminders/domain/usecases/create_reminder.dart';
import '../features/reminders/domain/usecases/schedule_reminder.dart';
import '../features/reminders/presentation/cubits/reminder_list_cubit.dart';

/// GetIt instance for dependency injection
final getIt = GetIt.instance;

/// Sets up all dependencies for the application
/// Uses manual GetIt registration (no @injectable)
Future<void> setupDependencies() async {
  // ==========================================================================
  // Database
  // ==========================================================================
  final db = AppDatabase();
  getIt.registerLazySingleton<AppDatabase>(() => db);

  // ==========================================================================
  // DAOs
  // ==========================================================================
  getIt.registerLazySingleton(() => TaskDao(db));
  getIt.registerLazySingleton(() => ProjectDao(db));
  getIt.registerLazySingleton(() => HabitDao(db));
  getIt.registerLazySingleton(() => ReminderDao(db));

  // ==========================================================================
  // Utils
  // ==========================================================================
  getIt.registerLazySingleton(() => const Uuid());

  // ==========================================================================
  // Repositories - Tasks
  // ==========================================================================
  getIt.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(getIt<TaskDao>()),
  );

  // ==========================================================================
  // Repositories - Projects
  // ==========================================================================
  getIt.registerLazySingleton<ProjectRepository>(
    () => ProjectRepositoryImpl(getIt<AppDatabase>()),
  );

  // ==========================================================================
  // Repositories - Habits
  // ==========================================================================
  getIt.registerLazySingleton<HabitRepository>(
    () => HabitRepositoryImpl(getIt<AppDatabase>()),
  );

  // ==========================================================================
  // Repositories - Reminders
  // ==========================================================================
  getIt.registerLazySingleton<ReminderRepository>(
    () => ReminderRepositoryImpl(
      getIt<AppDatabase>(),
      getIt<NotificationService>(),
    ),
  );

  // ==========================================================================
  // Use Cases - Tasks
  // ==========================================================================
  getIt.registerLazySingleton(() => WatchAllTasks(getIt<TaskRepository>()));
  getIt.registerLazySingleton(
    () => WatchTasksByProject(getIt<TaskRepository>()),
  );
  getIt.registerLazySingleton(() => CreateTask(
        getIt<TaskRepository>(),
        getIt<Uuid>(),
      ));
  getIt.registerLazySingleton(() => UpdateTask(getIt<TaskRepository>()));
  getIt.registerLazySingleton(() => DeleteTask(getIt<TaskRepository>()));
  getIt.registerLazySingleton(() => ToggleTask(getIt<TaskRepository>()));
  getIt.registerLazySingleton(() => ReorderTask(getIt<TaskRepository>()));
  getIt.registerLazySingleton(() => GetTask(getIt<TaskRepository>()));
  getIt.registerLazySingleton(() => GetAllTasks(getIt<TaskRepository>()));
  getIt.registerLazySingleton(
    () => ParseAndCreateTask(getIt<CreateTask>(), locale: 'ru'),
  );

  // ==========================================================================
  // Use Cases - Projects
  // ==========================================================================
  getIt.registerLazySingleton(() => WatchProjects(getIt<ProjectRepository>()));
  getIt.registerLazySingleton(() => GetAllProjects(getIt<ProjectRepository>()));
  getIt.registerLazySingleton(() => GetProject(getIt<ProjectRepository>()));
  getIt.registerLazySingleton(() => CreateProject(
        getIt<ProjectRepository>(),
        getIt<Uuid>(),
      ));
  getIt.registerLazySingleton(() => UpdateProject(getIt<ProjectRepository>()));
  getIt.registerLazySingleton(() => DeleteProject(getIt<ProjectRepository>()));
  getIt.registerLazySingleton(() => ToggleProjectArchive(getIt<ProjectRepository>()));

  // ==========================================================================
  // Use Cases - Habits
  // ==========================================================================
  getIt.registerLazySingleton(() => WatchHabits(getIt<HabitRepository>()));
  getIt.registerLazySingleton(() => GetAllHabits(getIt<HabitRepository>()));
  getIt.registerLazySingleton(() => GetHabit(getIt<HabitRepository>()));
  getIt.registerLazySingleton(() => GetHabitsDueToday(getIt<HabitRepository>()));
  getIt.registerLazySingleton(() => CreateHabit(
        getIt<HabitRepository>(),
        getIt<Uuid>(),
      ));
  getIt.registerLazySingleton(() => UpdateHabit(getIt<HabitRepository>()));
  getIt.registerLazySingleton(() => DeleteHabit(getIt<HabitRepository>()));
  getIt.registerLazySingleton(() => CompleteHabit(getIt<HabitRepository>()));

  // ==========================================================================
  // Use Cases - Reminders
  // ==========================================================================
  getIt.registerLazySingleton(() => WatchReminders(getIt<ReminderRepository>()));
  getIt.registerLazySingleton(() => GetAllReminders(getIt<ReminderRepository>()));
  getIt.registerLazySingleton(() => GetReminder(getIt<ReminderRepository>()));
  getIt.registerLazySingleton(() => GetRemindersByTask(getIt<ReminderRepository>()));
  getIt.registerLazySingleton(() => GetRemindersByHabit(getIt<ReminderRepository>()));
  getIt.registerLazySingleton(() => CreateReminder(
        getIt<ReminderRepository>(),
        getIt<Uuid>(),
      ));
  getIt.registerLazySingleton(() => UpdateReminder(getIt<ReminderRepository>()));
  getIt.registerLazySingleton(() => DeleteReminder(getIt<ReminderRepository>()));
  getIt.registerLazySingleton(() => ScheduleReminder(getIt<ReminderRepository>()));
  getIt.registerLazySingleton(() => CancelReminder(getIt<ReminderRepository>()));

  // ==========================================================================
  // Services
  // ==========================================================================
  getIt.registerLazySingleton<NotificationService>(() => NotificationService());
  getIt.registerLazySingleton<SyncService>(() => SyncService(db));
  getIt.registerLazySingleton<ThemeService>(() => ThemeService());
  getIt.registerLazySingleton<LocaleService>(() => LocaleService());

  // ==========================================================================
  // Cubits (factory - new instance for each screen)
  // ==========================================================================
  getIt.registerFactory<TaskListCubit>(() => TaskListCubit(
        getIt<WatchAllTasks>(),
        getIt<ToggleTask>(),
        getIt<DeleteTask>(),
      ));

  getIt.registerFactory<ProjectListCubit>(() => ProjectListCubit(
        getIt<WatchProjects>(),
        getIt<CreateProject>(),
        getIt<UpdateProject>(),
        getIt<DeleteProject>(),
        getIt<ToggleProjectArchive>(),
      ));

  getIt.registerFactory<HabitListCubit>(() => HabitListCubit(
        getIt<WatchHabits>(),
        getIt<CreateHabit>(),
        getIt<UpdateHabit>(),
        getIt<DeleteHabit>(),
        getIt<CompleteHabit>(),
      ));

  getIt.registerFactory<ReminderListCubit>(() => ReminderListCubit(
        getIt<WatchReminders>(),
        getIt<CreateReminder>(),
        getIt<UpdateReminder>(),
        getIt<DeleteReminder>(),
        getIt<ScheduleReminder>(),
        getIt<CancelReminder>(),
      ));
}
