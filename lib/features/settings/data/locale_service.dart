import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import '../../../../core/utils/logger.dart';

/// Service for managing application locale
class LocaleService extends ChangeNotifier {
  static const _key = 'locale';
  Locale _locale = const Locale('ru');
  final Logger _logger = AppLogger.forService('LocaleService');

  /// Current locale
  Locale get locale => _locale;

  /// Initializes the service by loading saved locale
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_key);
      if (code != null) {
        _locale = Locale(code);
        notifyListeners();
      }
    } catch (e, s) {
      _logger.e('Failed to load locale', error: e, stackTrace: s);
    }
  }

  /// Sets the locale and saves it to preferences
  Future<void> setLocale(Locale locale) async {
    try {
      _locale = locale;
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, locale.languageCode);
    } catch (e, s) {
      _logger.e('Failed to save locale', error: e, stackTrace: s);
    }
  }
}
