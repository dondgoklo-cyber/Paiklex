import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/logger.dart';
import '../../../../database/app_database.dart';

/// Service for exporting and importing data
class SyncService {
  final AppDatabase _db;
  final Logger _logger = Logger('SyncService');

  SyncService(this._db);

  /// Exports all data to a JSON file
  Future<File?> exportToJson() async {
    try {
      final tasks = await _db.taskDao.getAllOnce();
      final projects = await _db.projectDao.getAllOnce();
      final habits = await _db.habitDao.getAllOnce();
      final reminders = await _db.reminderDao.getAllOnce();

      final data = {
        'version': 1,
        'exportedAt': AppDateUtils.nowUtc().toIso8601String(),
        'tasks': tasks.map(_taskToJson).toList(),
        'projects': projects.map(_projectToJson).toList(),
        'habits': habits.map(_habitToJson).toList(),
        'reminders': reminders.map(_reminderToJson).toList(),
      };

      if (kIsWeb) return null;

      if (kIsWeb) return null;
      final dir = await getApplicationDocumentsDirectory();
      final ts = AppDateUtils.nowUtc()
          .toIso8601String()
          .replaceAll(':', '-');
      final file = File('${dir.path}/monolith_$ts.json');
      await file.writeAsString(jsonEncode(data));
      return file;
    } catch (e, s) {
      _logger.e('Export failed', error: e, stackTrace: s);
      return null;
    }
  }

  /// Exports data and shares via system share sheet
  Future<bool> exportAndShare() async {
    final file = await exportToJson();
    if (file == null) return false;

    try {
      await Share.shareXFiles([XFile(file.path)], text: 'Monolith export');
      return true;
    } catch (e, s) {
      _logger.e('Share failed', error: e, stackTrace: s);
      return false;
    }
  }

  /// Imports data from a file picker
  Future<bool> importFromFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result == null || result.files.isEmpty) return false;

      String json;
      if (kIsWeb) {
        json = utf8.decode(result.files.single.bytes!);
      } else {
        json = await File(result.files.single.path!).readAsString();
      }
      return importFromJson(json);
    } catch (e, s) {
      _logger.e('Import from file failed', error: e, stackTrace: s);
      return false;
    }
  }

  /// Imports data from a JSON string
  Future<bool> importFromJson(String json) async {
    try {
      final data = jsonDecode(json) as Map<String, Object?>;

      await _db.transaction(() async {
        for (final t in (data['tasks'] as List? ?? [])) {
          await _importTask(t as Map<String, Object?>);
        }
        for (final p in (data['projects'] as List? ?? [])) {
          await _importProject(p as Map<String, Object?>);
        }
        for (final h in (data['habits'] as List? ?? [])) {
          await _importHabit(h as Map<String, Object?>);
        }
        for (final r in (data['reminders'] as List? ?? [])) {
          await _importReminder(r as Map<String, Object?>);
        }
      });

      return true;
    } catch (e, s) {
      _logger.e('Import from JSON failed', error: e, stackTrace: s);
      return false;
    }
  }

  Future<void> _importTask(Map<String, Object?> j) async {
    final id = j['id'] as String;
    final existing = await _db.taskDao.getById(id);
    final incomingUpdated = j['updatedAt'] as int;

    if (existing == null || incomingUpdated > existing.updatedAt) {
      await _db.taskDao.insert(TasksCompanion(
        id: Value(id),
        projectId: Value(j['projectId'] as String?),
        parentTaskId: Value(j['parentTaskId'] as String?),
        content: Value(j['content'] as String),
        description: Value(j['description'] as String?),
        isCompleted: Value(j['isCompleted'] as bool? ?? false),
        priority: Value(j['priority'] as int? ?? 3),
        dueDate: Value(j['dueDate'] as int?),
        duration: Value(j['duration'] as int?),
        tags: Value(jsonEncode(j['tags'] ?? [])),
        recurrence: Value(j['recurrence'] as String?),
        orderIndex: Value(j['orderIndex'] as int? ?? 0),
        createdAt: Value(j['createdAt'] as int),
        updatedAt: Value(incomingUpdated),
        completedAt: Value(j['completedAt'] as int?),
      ));
    }
  }

  Future<void> _importProject(Map<String, Object?> j) async {
    final id = j['id'] as String;
    final existing = await _db.projectDao.getById(id);
    final incomingUpdated = j['updatedAt'] as int;

    if (existing == null || incomingUpdated > existing.updatedAt) {
      await _db.projectDao.insert(ProjectsCompanion(
        id: Value(id),
        name: Value(j['name'] as String),
        color: Value(j['color'] as int? ?? 0xFF2196F3),
        isArchived: Value(j['isArchived'] as bool? ?? false),
        createdAt: Value(j['createdAt'] as int),
        updatedAt: Value(incomingUpdated),
      ));
    }
  }

  Future<void> _importHabit(Map<String, Object?> j) async {
    final id = j['id'] as String;
    await _db.habitDao.insert(HabitsCompanion(
      id: Value(id),
      projectId: Value(j['projectId'] as String?),
      title: Value(j['title'] as String),
      frequency: Value(j['frequency'] as String),
      streak: Value(j['streak'] as int? ?? 0),
      bestStreak: Value(j['bestStreak'] as int? ?? 0),
      lastCompletedAt: Value(j['lastCompletedAt'] as int?),
      createdAt: Value(j['createdAt'] as int),
      updatedAt: Value(j['updatedAt'] as int),
    ));
  }

  Future<void> _importReminder(Map<String, Object?> j) async {
    await _db.reminderDao.insert(RemindersCompanion(
      id: Value(j['id'] as String),
      taskId: Value(j['taskId'] as String?),
      habitId: Value(j['habitId'] as String?),
      triggerAt: Value(j['triggerAt'] as int),
      title: Value(j['title'] as String),
      body: Value(j['body'] as String?),
      isTriggered: Value(j['isTriggered'] as bool? ?? false),
      createdAt: Value(j['createdAt'] as int),
    ));
  }

  Map<String, Object?> _taskToJson(TaskRow r) => {
        'id': r.id,
        'projectId': r.projectId,
        'parentTaskId': r.parentTaskId,
        'content': r.content,
        'description': r.description,
        'isCompleted': r.isCompleted,
        'priority': r.priority,
        'dueDate': r.dueDate,
        'duration': r.duration,
        'tags': jsonDecode(r.tags),
        'recurrence': r.recurrence,
        'orderIndex': r.orderIndex,
        'createdAt': r.createdAt,
        'updatedAt': r.updatedAt,
        'completedAt': r.completedAt,
      };

  Map<String, Object?> _projectToJson(ProjectRow r) => {
        'id': r.id,
        'name': r.name,
        'color': r.color,
        'isArchived': r.isArchived,
        'createdAt': r.createdAt,
        'updatedAt': r.updatedAt,
      };

  Map<String, Object?> _habitToJson(HabitRow r) => {
        'id': r.id,
        'projectId': r.projectId,
        'title': r.title,
        'frequency': r.frequency,
        'streak': r.streak,
        'bestStreak': r.bestStreak,
        'lastCompletedAt': r.lastCompletedAt,
        'createdAt': r.createdAt,
        'updatedAt': r.updatedAt,
      };

  Map<String, Object?> _reminderToJson(ReminderRow r) => {
        'id': r.id,
        'taskId': r.taskId,
        'habitId': r.habitId,
        'triggerAt': r.triggerAt,
        'title': r.title,
        'body': r.body,
        'isTriggered': r.isTriggered,
        'createdAt': r.createdAt,
      };
}
