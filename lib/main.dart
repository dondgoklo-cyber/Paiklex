import 'package:flutter/material.dart';
import 'app/app.dart';
import 'app/di.dart';
import 'app/error_boundary.dart';

/// Application entry point
Future<void> main() async {
  AppErrorBoundary.setup();
  await AppErrorBoundary.run(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await setupDependencies();
    
    // Initialize notification service
    final notificationService = getIt.get<NotificationService>();
    await notificationService.init();
    
    runApp(const MonolithApp());
  });
}
