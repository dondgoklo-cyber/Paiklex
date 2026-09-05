import 'package:equatable/equatable.dart';

/// Базовый класс ошибок приложения
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure(this.message, [this.code]);

  @override
  List<Object?> get props => [message, code];

  @override
  String toString() => 'Failure($code): $message';
}

/// Ошибка базы данных
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, [super.code = 'DB_ERROR']);
}

/// Ошибка валидации
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, [super.code = 'VALIDATION_ERROR']);
}

/// Ошибка "не найдено"
class NotFoundFailure extends Failure {
  const NotFoundFailure(String entity, String id)
      : super('$entity with id $id not found', 'NOT_FOUND');
}

/// Ошибка парсинга
class ParseFailure extends Failure {
  const ParseFailure(super.message, [super.code = 'PARSE_ERROR']);
}

/// Ошибка синхронизации
class SyncFailure extends Failure {
  const SyncFailure(super.message, [super.code = 'SYNC_ERROR']);
}
