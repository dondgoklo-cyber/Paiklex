import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Widget for displaying error states
class ErrorView extends StatelessWidget {
  final String? message;
  final String? errorCode;
  final VoidCallback? onRetry;
  final IconData? icon;

  const ErrorView({
    super.key,
    this.message,
    this.errorCode,
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final displayMessage = message ?? l10n.error;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              displayMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (errorCode != null && errorCode!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Code: $errorCode',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Full-screen error view with retry
class FullScreenErrorView extends StatelessWidget {
  final String? message;
  final String? errorCode;
  final VoidCallback? onRetry;

  const FullScreenErrorView({
    super.key,
    this.message,
    this.errorCode,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ErrorView(
        message: message,
        errorCode: errorCode,
        onRetry: onRetry,
      ),
    );
  }
}

/// Inline error widget for forms
class InlineErrorWidget extends StatelessWidget {
  final String message;
  final IconData? icon;

  const InlineErrorWidget({
    super.key,
    required this.message,
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
