import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/nlp_parser.dart';
import '../entities/task.dart';
import 'create_task.dart';

/// Use case for parsing natural language input and creating a task
class ParseAndCreateTask {
  final CreateTask _create;
  final String locale;

  const ParseAndCreateTask(this._create, {this.locale = 'ru'});

  /// Parses input string and creates a task
  /// Example: "buy milk tomorrow at 18:00 #shopping p1 every day"
  Future<Either<Failure, Task>> call(String input) async {
    if (input.trim().isEmpty) {
      return const Left(ValidationFailure('Input is empty'));
    }

    final parsed = NlpParser.parse(input, locale: locale);

    final task = Task(
      id: '', // CreateTask will generate UUID
      content: parsed.content,
      dueDate: parsed.dueDate,
      priority: TaskPriority.fromValue(parsed.priority ?? 3),
      tags: parsed.tags,
      recurrence: parsed.recurrence,
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );

    return _create(task);
  }
}
