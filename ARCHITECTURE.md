# Monolith Tasks - Architecture v5.0

## Philosophy (7 Principles)

1. **"Working > Clever"** — working code is better than clever code
2. **"Boring tech"** — only packages with 10k+ likes on pub.dev
3. **"UTC inside, Local outside"** — UTC in DB, local in UI
4. **"Fail loud"** — log every error through `logger`
5. **"One screen, one purpose"** — each screen = one task
6. **"Tests are docs"** — tests = documentation
7. **"No magic DI"** — only manual GetIt

## Project Structure (Feature-First)

```
monolith_tasks/
├── android/app/src/main/AndroidManifest.xml
├── ios/Runner/Info.plist
├── web/
│   ├── index.html           # COOP/COEP meta
│   ├── sqlite3.wasm         # DOWNLOAD REQUIRED
│   ├── sqlite3.wasm.map     # DOWNLOAD REQUIRED
│   └── drift_worker.js      # FROM build_runner
├── lib/
│   ├── app/
│   │   ├── app.dart
│   │   ├── di.dart          # Manual GetIt
│   │   ├── router.dart
│   │   ├── error_boundary.dart
│   │   └── lifecycle_observer.dart
│   ├── core/
│   │   ├── constants/app_constants.dart
│   │   ├── errors/failures.dart
│   │   ├── utils/
│   │   │   ├── logger.dart
│   │   │   ├── date_utils.dart  # Pure Dart
│   │   │   └── nlp_parser.dart  # Pure Dart
│   │   └── extensions/datetime_ext.dart
│   ├── database/
│   │   ├── app_database.dart    # All tables + DAOs
│   │   └── migrations.dart
│   ├── features/
│   │   ├── tasks/
│   │   │   ├── domain/
│   │   │   │   ├── entities/task.dart
│   │   │   │   ├── entities/priority.dart
│   │   │   │   ├── repositories/task_repository.dart
│   │   │   │   └── usecases/
│   │   │   ├── data/
│   │   │   │   ├── models/task_model.dart
│   │   │   │   └── repositories/task_repository_impl.dart
│   │   │   └── presentation/
│   │   │       ├── cubits/task_list_cubit.dart
│   │   │       ├── screens/task_list_screen.dart
│   │   │       ├── screens/task_detail_screen.dart
│   │   │       └── widgets/
│   │   ├── projects/  (similar to tasks)
│   │   ├── habits/    (similar to tasks)
│   │   ├── reminders/ (similar to tasks)
│   │   ├── kanban/
│   │   │   └── presentation/screens/kanban_screen.dart
│   │   ├── calendar_view/
│   │   │   └── presentation/screens/calendar_screen.dart
│   │   ├── sync/data/sync_service.dart
│   │   ├── notifications/data/notification_service.dart
│   │   ├── settings/
│   │   │   ├── presentation/screens/settings_screen.dart
│   │   │   ├── data/theme_service.dart
│   │   │   └── data/locale_service.dart
│   │   ├── search/presentation/screens/search_screen.dart
│   │   └── onboarding/presentation/screens/onboarding_screen.dart
│   ├── shared/widgets/
│   │   ├── error_view.dart
│   │   ├── loading_view.dart
│   │   ├── empty_state.dart
│   │   └── confirm_dialog.dart
│   ├── shared/theme/app_theme.dart
│   ├── l10n/
│   │   ├── app_en.arb
│   │   └── app_ru.arb
│   └── main.dart
├── test/
├── build.yaml
├── l10n.yaml
└── pubspec.yaml
```

## Technology Stack

### Dependencies
- flutter: ^3.19.0
- flutter_localizations
- flutter_bloc: ^8.1.6
- equatable: ^2.0.5
- drift: ^2.20.0
- sqlite3_flutter_libs: ^0.5.24
- path_provider: ^2.1.4
- path: ^1.9.0
- go_router: ^14.2.7
- get_it: ^7.7.0
- fpdart: ^1.1.0
- flutter_local_notifications: ^17.2.3
- timezone: ^0.9.4
- uuid: ^4.5.1
- intl: ^0.19.0
- logger: ^2.4.0
- shared_preferences: ^2.3.2
- collection: ^1.18.0
- rxdart: ^0.28.0
- file_picker: ^8.1.2
- share_plus: ^10.0.2
- table_calendar: ^3.1.2

### Dev Dependencies
- flutter_test
- flutter_lints: ^4.0.0
- build_runner: ^2.4.13
- drift_dev: ^2.20.0
- mocktail: ^1.0.4
- bloc_test: ^9.1.7
- integration_test

## Critical Rules for AI

### ABSOLUTELY FORBIDDEN
- @injectable class X {}
- @LazySingleton(as: Y)
- @lazySingleton
- while(true) in Stream
- File() without kIsWeb check
- state.pathParams (use state.pathParameters)
- DateTime.now() in DB (use DateTime.now().toUtc())
- DateTime(2026, 1, 1) in DB (use DateTime.utc(2026, 1, 1))
- handleError with return in Stream
- print()
- Freezed
- Paid packages (syncfusion_*, ag_*)
- UUID in UI
- update().write() with partial fields (use .replace())
- firstWhere with throw in Stream (use getSingleOrNull)

### REQUIRED
- Feature-first structure
- UTC everywhere in DB, .toLocal() only in UI
- Either<Failure, T> from fpdart for DB
- Stream for lists, Future for single-shot
- Only get_it (manual, no injectable)
- Drift DAO for all queries
- @DataClassName for ALL tables (TaskRow, ProjectRow, HabitRow, ReminderRow)
- logger in every service
- Doc comments (///) on public APIs
- Minimum 1 unit test per UseCase
