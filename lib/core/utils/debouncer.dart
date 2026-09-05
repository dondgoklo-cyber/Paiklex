import 'dart:async';

/// A debouncer utility that delays function calls until a certain amount of time
/// has passed since the last time it was called.
/// Useful for search inputs, window resizing, and other rapid events.
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(milliseconds: 300)});

  /// Call the provided function after the delay has passed since the last call.
  /// If this is called again before the delay has passed, the previous call is cancelled.
  void debounce(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  /// Call the provided async function after the delay has passed since the last call.
  /// If this is called again before the delay has passed, the previous call is cancelled.
  void debounceAsync(Future<void> Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, () async {
      await action();
    });
  }

  /// Cancel any pending debounced call.
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Check if there's a pending debounced call.
  bool get isPending => _timer?.isActive ?? false;

  /// Dispose the debouncer and cancel any pending calls.
  void dispose() {
    cancel();
  }
}

/// A debouncer that can be used globally for search operations
final searchDebouncer = Debouncer(delay: const Duration(milliseconds: 500));

/// A debouncer for general UI operations
final uiDebouncer = Debouncer(delay: const Duration(milliseconds: 100));
