import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import '../../../../core/utils/logger.dart';

/// Service for managing application theme mode
class ThemeService extends ChangeNotifier {
  static const _key = 'theme_mode';
  ThemeMode _mode = ThemeMode.system;
  final Logger _logger = Logger('ThemeService');

  /// Current theme mode
  ThemeMode get themeMode => _mode;

  /// Initializes the service by loading saved theme mode
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getString(_key);
      if (value != null) {
        _mode = ThemeMode.values.firstWhere(
          (m) => m.name == value,
          orElse: () => ThemeMode.system,
        );
        notifyListeners();
      }
    } catch (e, s) {
      _logger.e('Failed to load theme mode', error: e, stackTrace: s);
    }
  }

  /// Sets the theme mode and saves it to preferences
  Future<void> setMode(ThemeMode mode) async {
    try {
      _mode = mode;
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, mode.name);
    } catch (e, s) {
      _logger.e('Failed to save theme mode', error: e, stackTrace: s);
    }
  }
}
