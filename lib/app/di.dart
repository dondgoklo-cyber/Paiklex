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
  // Repositories
  // ==========================================================================
  getIt.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(getIt<TaskDao>()),
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
}
