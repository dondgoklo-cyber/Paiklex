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
    
    // Initialize notification service and restore scheduled notifications
    final notificationService = getIt.get<NotificationService>();
    await notificationService.init();
    
    // Restore all notifications from database
    final reminderRepo = getIt.get<ReminderRepository>();
    if (reminderRepo is ReminderRepositoryImpl) {
      await reminderRepo.restoreAllNotifications();
    }
    
    runApp(const MonolithApp());
  });
}
