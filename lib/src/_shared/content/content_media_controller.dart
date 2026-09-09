import 'package:flutter/foundation.dart';
import 'package:tracksu_storage/tracksu_storage.dart';

/// Device preference, independent of OAuth identity. Unknown means no requests.
final class ContentMediaController extends ChangeNotifier {
  factory ContentMediaController({required ContentMediaStore store}) =>
      ContentMediaController._(store);
  ContentMediaController._(this._store);
  final ContentMediaStore _store;
  bool? _choice;
  bool _saving = false;
  bool _disposed = false;
  bool? get choice => _choice;
  bool get allowed => _choice == true;
  bool get saving => _saving;

  Future<void> restore() async {
    try {
      _choice = await _store.readPermission();
    } on Object {
      _choice = null; // Fail closed without blocking guest browsing.
    }
  }

  Future<void> select(bool allowed) async {
    if (_saving || _disposed) return;
    _saving = true;
    // Revocation cancels requests immediately, even if persistence fails.
    if (!allowed) _choice = false;
    notifyListeners();
    try {
      await _store.writePermission(allowed);
      if (!_disposed) _choice = allowed;
    } finally {
      _saving = false;
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
