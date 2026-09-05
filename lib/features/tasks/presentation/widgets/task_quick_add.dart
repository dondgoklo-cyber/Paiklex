import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/di.dart';
import '../../domain/usecases/parse_and_create_task.dart';

/// Widget for quickly adding tasks with NLP parsing
class TaskQuickAdd extends StatefulWidget {
  const TaskQuickAdd({super.key});

  @override
  State<TaskQuickAdd> createState() => _TaskQuickAddState();
}

class _TaskQuickAddState extends State<TaskQuickAdd> {
  final _controller = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: l10n.addTask,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => _submit(),
            ),
          ),
          const SizedBox(width: 8),
          if (_loading)
            const SizedBox(
              width: 48,
              height: 48,
              child: Center(child: CircularProgressIndicator()),
            )
          else
            FloatingActionButton(
              onPressed: _submit,
              child: const Icon(Icons.add),
            ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final text = _controller.text;
    if (text.trim().isEmpty) return;

    setState(() => _loading = true);

    try {
      final result = await getIt<ParseAndCreateTask>()(text);
      result.fold(
        (f) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(f.message)),
          );
        },
        (_) {
          _controller.clear();
        },
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
