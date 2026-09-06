import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../features/settings/data/locale_service.dart';
import '../features/settings/data/theme_service.dart';
import 'di.dart';
import 'router.dart';

/// Main application widget
class MonolithApp extends StatefulWidget {
  const MonolithApp({super.key});

  @override
  State<MonolithApp> createState() => _MonolithAppState();
}

class _MonolithAppState extends State<MonolithApp> {
  late final LocaleService _localeService;
  late final ThemeService _themeService;

  @override
  void initState() {
    super.initState();
    _localeService = getIt<LocaleService>();
    _themeService = getIt<ThemeService>();
    _localeService.addListener(_onChanged);
    _themeService.addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _localeService.removeListener(_onChanged);
    _themeService.removeListener(_onChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Monolith Tasks',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      themeMode: _themeService.themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      locale: _localeService.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
