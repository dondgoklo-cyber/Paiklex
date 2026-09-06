import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../core/utils/undo_manager.dart';

/// Shows an undo snackbar with the ability to undo the last action
class UndoSnackBar {
  /// Show snackbar with undo option
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> show({
    required BuildContext context,
    required String actionId,
    required String message,
    Duration duration = const Duration(seconds: 5),
    String? undoLabel,
  }) {
    final l10n = AppLocalizations.of(context)!;
    
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: SnackBarAction(
          label: undoLabel ?? l10n.undo,
          textColor: Theme.of(context).colorScheme.primary,
          onPressed: () {
            undoManager.undo(actionId);
          },
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
        dismissDirection: DismissDirection.up,
      ),
    );
  }

  /// Show delete undo snackbar
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showDelete({
    required BuildContext context,
    required String actionId,
    String? itemName,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final message = itemName != null
        ? l10n.undoDeleteItem(itemName)
        : l10n.undoDelete;
    
    return show(
      context: context,
      actionId: actionId,
      message: message,
      undoLabel: l10n.undo,
    );
  }

  /// Show archive undo snackbar
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showArchive({
    required BuildContext context,
    required String actionId,
    String? itemName,
    bool archived = true,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final message = archived
        ? (itemName != null ? l10n.undoArchiveItem(itemName) : l10n.undoArchive)
        : (itemName != null ? l10n.undoUnarchiveItem(itemName) : l10n.undoUnarchive);
    
    return show(
      context: context,
      actionId: actionId,
      message: message,
      undoLabel: l10n.undo,
    );
  }

  /// Show complete undo snackbar
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showComplete({
    required BuildContext context,
    required String actionId,
    String? itemName,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final message = itemName != null
        ? l10n.undoCompleteItem(itemName)
        : l10n.undoComplete;
    
    return show(
      context: context,
      actionId: actionId,
      message: message,
      undoLabel: l10n.undo,
    );
  }
}
