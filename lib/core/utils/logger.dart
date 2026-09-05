import 'package:logger/logger.dart';

/// Единый логгер приложения
class AppLogger {
  static Logger? _instance;

  /// Возвращает синглтон логгера
  static Logger get instance {
    _instance ??= Logger(
      printer: PrettyPrinter(
        methodCount: 1,
        errorMethodCount: 5,
        lineLength: 100,
        colors: true,
        printEmojis: true,
        printTime: true,
      ),
    );
    return _instance!;
  }

  /// Создаёт логгер с тегом сервиса
  static Logger forService(String serviceName) {
    return Logger(
      printer: PrettyPrinter(
        colors: true,
        printTime: true,
        methodCount: 0,
      ),
    );
  }
}
