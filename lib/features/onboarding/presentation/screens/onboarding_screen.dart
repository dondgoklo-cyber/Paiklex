import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Onboarding screen with 3 pages
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final logger = Logger('OnboardingScreen');

  @override
  void initState() {
    super.initState();
    _checkOnboardingDone();
  }

  Future<void> _checkOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    final done = prefs.getBool('onboarding_done') ?? false;
    if (done && mounted) {
      context.pushReplacement('/tasks');
    }
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    logger.d('Onboarding completed');
    if (mounted) {
      context.pushReplacement('/tasks');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _currentPage = i),
              children: [
                _OnboardingPage(
                  icon: Icons.list_alt,
                  title: AppLocalizations.of(context)!.organize,
                  subtitle: AppLocalizations.of(context)!.organizeDesc,
                ),
                _OnboardingPage(
                  icon: Icons.offline_bolt,
                  title: AppLocalizations.of(context)!.offlineFirst,
                  subtitle: AppLocalizations.of(context)!.offlineFirstDesc,
                ),
                _OnboardingPage(
                  icon: Icons.sync,
                  title: AppLocalizations.of(context)!.syncViaFile,
                  subtitle: AppLocalizations.of(context)!.syncViaFileDesc,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (i) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: i == _currentPage
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 48, left: 24, right: 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _currentPage == 2 ? _completeOnboarding : () {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.ease,
                  );
                },
                child: Text(
                  _currentPage == 2
                      ? AppLocalizations.of(context)!.getStarted
                      : AppLocalizations.of(context)!.next,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A single onboarding page
class _OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 32),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
