import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import '../../../../app/di.dart';
import '../../../../features/settings/data/theme_service.dart';
import '../../../../features/settings/data/locale_service.dart';
import '../../../../features/sync/data/sync_service.dart';

/// Settings screen with theme switcher, language switcher, and export/import
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final logger = Logger('SettingsScreen');
    final themeService = getIt<ThemeService>();
    final localeService = getIt<LocaleService>();
    final syncService = getIt<SyncService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: ListView(
        children: [
          // Theme Section
          _SettingsSection(
            title: AppLocalizations.of(context)!.appearance,
            children: [
              _ThemeTile(
                current: themeService.themeMode,
                onChanged: (m) async {
                  logger.d('Theme changed to: $m');
                  await themeService.setMode(m);
                },
              ),
            ],
          ),

          // Language Section
          _SettingsSection(
            title: AppLocalizations.of(context)!.language,
            children: [
              _LocaleTile(
                currentLocale: localeService.locale,
                onChanged: (l) async {
                  logger.d('Locale changed to: $l');
                  await localeService.setLocale(l);
                },
              ),
            ],
          ),

          // Data Section
          _SettingsSection(
            title: AppLocalizations.of(context)!.data,
            children: [
              ListTile(
                leading: const Icon(Icons.upload),
                title: Text(AppLocalizations.of(context)!.exportData),
                subtitle: Text(AppLocalizations.of(context)!.exportDesc),
                onTap: () async {
                  try {
                    final success = await syncService.exportAndShare();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? AppLocalizations.of(context)!.exportSuccess
                              : AppLocalizations.of(context)!.exportFailed,
                        ),
                      ),
                    );
                  } catch (e) {
                    logger.e('Export failed', error: e);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppLocalizations.of(context)!.exportFailed,
                        ),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.download),
                title: Text(AppLocalizations.of(context)!.importData),
                subtitle: Text(AppLocalizations.of(context)!.importDesc),
                onTap: () async {
                  try {
                    final success = await syncService.importFromFile();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? AppLocalizations.of(context)!.importSuccess
                              : AppLocalizations.of(context)!.importFailed,
                        ),
                      ),
                    );
                  } catch (e) {
                    logger.e('Import failed', error: e);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppLocalizations.of(context)!.importFailed,
                        ),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    );
                  }
                },
              ),
            ],
          ),

          // About Section
          _SettingsSection(
            title: AppLocalizations.of(context)!.about,
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(AppLocalizations.of(context)!.aboutTitle),
                subtitle: Text(AppLocalizations.of(context)!.aboutDesc),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A section in settings with a title and children tiles
class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        ...children,
      ],
    );
  }
}

/// Tile for theme selection
class _ThemeTile extends StatelessWidget {
  final ThemeMode current;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemeTile({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RadioListTile<ThemeMode>(
          title: Text(AppLocalizations.of(context)!.system),
          value: ThemeMode.system,
          groupValue: current,
          onChanged: onChanged,
        ),
        RadioListTile<ThemeMode>(
          title: Text(AppLocalizations.of(context)!.light),
          value: ThemeMode.light,
          groupValue: current,
          onChanged: onChanged,
        ),
        RadioListTile<ThemeMode>(
          title: Text(AppLocalizations.of(context)!.dark),
          value: ThemeMode.dark,
          groupValue: current,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

/// Tile for locale selection
class _LocaleTile extends StatelessWidget {
  final Locale currentLocale;
  final ValueChanged<Locale> onChanged;

  const _LocaleTile({required this.currentLocale, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RadioListTile<Locale>(
          title: const Text('English'),
          value: const Locale('en'),
          groupValue: currentLocale,
          onChanged: onChanged,
        ),
        RadioListTile<Locale>(
          title: const Text('Русский'),
          value: const Locale('ru'),
          groupValue: currentLocale,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
