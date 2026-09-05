import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../core/utils/logger.dart';

/// Global error boundary for the application
class AppErrorBoundary {
  static final Logger _logger = AppLogger.instance;

  /// Sets up global error handlers
  static void setup() {
    FlutterError.onError = (details) {
      _logger.e(
        'Flutter error',
        error: details.exception,
        stackTrace: details.stack,
      );
      // In debug mode, let Flutter show the error
      FlutterError.presentError(details);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      _logger.e(
        'Platform error',
        error: error,
        stackTrace: stack,
      );
      return true; // Prevents the error from propagating
    };
  }

  /// Runs the app with error boundary
  static Future<void> run(Future<void> Function() runner) async {
    await runZonedGuarded(
      runner,
      (e, s) {
        _logger.e(
          'Zone error',
          error: e,
          stackTrace: s,
        );
      },
    );
  }
}
