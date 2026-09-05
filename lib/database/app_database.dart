import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift/wasm.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// ============================================================================
// TABLES — @DataClassName for ALL to avoid conflicts with entities
// ============================================================================

@DataClassName('ProjectRow')
class Projects extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  IntColumn get color => integer().withDefault(const Constant(0xFF2196F3))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TaskRow')
class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text().nullable()();
  TextColumn get parentTaskId => text().nullable()();
  TextColumn get content => text().withLength(min: 1, max: 2000)();
  TextColumn get description => text().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  IntColumn get priority => integer().withDefault(const Constant(3))();
  IntColumn get dueDate => integer().nullable();
  IntColumn get duration => integer().nullable();
  TextColumn get tags => text().withDefault(const Constant('[]'))();
  TextColumn get recurrence => text().nullable();
  IntColumn get orderIndex => integer().withDefault(const Constant(0))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get completedAt => integer().nullable();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('HabitRow')
class Habits extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text().nullable()();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get frequency => text()();
  IntColumn get streak => integer().withDefault(const Constant(0))();
  IntColumn get bestStreak => integer().withDefault(const Constant(0))();
  IntColumn get lastCompletedAt => integer().nullable();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ReminderRow')
class Reminders extends Table {
  TextColumn get id => text()();
  TextColumn get taskId => text().nullable()();
  TextColumn get habitId => text().nullable()();
  IntColumn get triggerAt => integer()();
  TextColumn get title => text()();
  TextColumn get body => text().nullable();
  BoolColumn get isTriggered => boolean().withDefault(const Constant(false))();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================================
// DATABASE
// ============================================================================

@DriftDatabase(tables: [Projects, Tasks, Habits, Reminders])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async => await m.createAll(),
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await customStatement('PRAGMA journal_mode = WAL');
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    if (kIsWeb) {
      final result = await WasmDatabase.open(
        databaseName: 'monolith',
        sqlite3Uri: Uri.parse('sqlite3.wasm'),
        driftWorkerUri: Uri.parse('drift_worker.js'),
      );
      if (result.missingFeatures.isNotEmpty) {
        throw StateError('WASM missing: ${result.missingFeatures}');
      }
      return result.database;
    }
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'monolith.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

// ============================================================================
// DAOS — all 4 implemented
// ============================================================================

@DriftAccessor(tables: [Tasks])
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {
  TaskDao(super.db);

  Stream<List<TaskRow>> watchAll() {
    return (select(tasks)
          ..orderBy([
            (t) => OrderingTerm.asc(t.isCompleted),
            (t) => OrderingTerm.asc(t.priority),
            (t) => OrderingTerm.desc(t.createdAt),
          ])).watch();
  }

  Stream<List<TaskRow>> watchByProject(String? projectId) {
    final q = select(tasks);
    if (projectId == null) {
      q.where((t) => t.projectId.isNull());
    } else {
      q.where((t) => t.projectId.equals(projectId));
    }
    q.orderBy([(t) => OrderingTerm.asc(t.priority)]);
    return q.watch();
  }

  Future<List<TaskRow>> getAllOnce() => select(tasks).get();

  Future<TaskRow?> getById(String id) {
    return (select(tasks)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<String> insert(TasksCompanion row) => into(tasks).insert(row);

  Future<bool> update(TasksCompanion row) => update(tasks).replace(row);

  Future<int> delete(String id) {
    return transaction(() async {
      await (delete(tasks)..where((t) => t.parentTaskId.equals(id))).go();
      return (delete(tasks)..where((t) => t.id.equals(id))).go();
    });
  }

  Future<bool> toggleComplete(String id) async {
    final current = await getById(id);
    if (current == null) return false;
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    final wasCompleted = current.isCompleted;
    return update(tasks).replace(current.copyWith(
          isCompleted: !wasCompleted,
          completedAt: !wasCompleted ? now : null,
          updatedAt: now,
        ));
  }
}

@DriftAccessor(tables: [Projects])
class ProjectDao extends DatabaseAccessor<AppDatabase> with _$ProjectDaoMixin {
  ProjectDao(super.db);

  Stream<List<ProjectRow>> watchAll() =>
      (select(projects)..orderBy([(p) => OrderingTerm.asc(p.name)])).watch();

  Future<List<ProjectRow>> getAllOnce() => select(projects).get();

  Future<ProjectRow?> getById(String id) {
    return (select(projects)..where((p) => p.id.equals(id))).getSingleOrNull();
  }

  Future<String> insert(ProjectsCompanion row) => into(projects).insert(row);
  Future<bool> update(ProjectsCompanion row) => update(projects).replace(row);
  Future<int> delete(String id) =>
      (delete(projects)..where((p) => p.id.equals(id))).go();
}

@DriftAccessor(tables: [Habits])
class HabitDao extends DatabaseAccessor<AppDatabase> with _$HabitDaoMixin {
  HabitDao(super.db);

  Stream<List<HabitRow>> watchAll() => select(habits).watch();
  Future<List<HabitRow>> getAllOnce() => select(habits).get();

  Future<HabitRow?> getById(String id) {
    return (select(habits)..where((h) => h.id.equals(id))).getSingleOrNull();
  }

  Future<String> insert(HabitsCompanion row) => into(habits).insert(row);
  Future<bool> update(HabitsCompanion row) => update(habits).replace(row);
  Future<int> delete(String id) =>
      (delete(habits)..where((h) => h.id.equals(id))).go();
}

@DriftAccessor(tables: [Reminders])
class ReminderDao extends DatabaseAccessor<AppDatabase> with _$ReminderDaoMixin {
  ReminderDao(super.db);

  Stream<List<ReminderRow>> watchAll() => select(reminders).watch();
  Future<List<ReminderRow>> getAllOnce() => select(reminders).get();

  Future<String> insert(RemindersCompanion row) => into(reminders).insert(row);
  Future<bool> update(RemindersCompanion row) => update(reminders).replace(row);
  Future<int> delete(String id) =>
      (delete(reminders)..where((r) => r.id.equals(id))).go();
}
