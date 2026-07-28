import 'dart:async';

final class RestCancellationToken {
  RestCancellationToken();

  final Completer<void> _abortCompleter = Completer<void>();

  bool get isCancelled => _abortCompleter.isCompleted;

  Future<void> get whenCancelled => _abortCompleter.future;

  void cancel() {
    if (!_abortCompleter.isCompleted) {
      _abortCompleter.complete();
    }
  }
}
