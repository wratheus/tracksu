import 'package:flutter/foundation.dart';
import 'package:tracksu/src/_shared/media/data/media_cache_repository.dart';
import 'package:tracksu_storage/tracksu_storage.dart';

/// Device preference, independent of OAuth identity. Images load by default.
final class ContentMediaController extends ChangeNotifier {
  factory ContentMediaController({
    required ContentMediaStore store,
    required MediaCacheRepository repository,
  }) => ContentMediaController._(store, repository);
  ContentMediaController._(this._store, this.repository);
  final ContentMediaStore _store;
  final MediaCacheRepository repository;
  bool? _choice;
  bool _saving = false;
  bool _disposed = false;
  bool? get choice => _choice;
  bool get allowed => _choice != false;
  bool get saving => _saving;

  Future<void> restore() async {
    try {
      _choice = await _store.readPermission();
    } on Object {
      _choice =
          null; // Keep the product default if preferences are unavailable.
    }
    repository.setImagesAllowed(allowed);
  }

  Future<void> select(bool allowed) async {
    if (_saving || _disposed) return;
    _saving = true;
    // Revocation cancels requests immediately, even if persistence fails.
    if (!allowed) {
      _choice = false;
      repository.setImagesAllowed(false);
    }
    notifyListeners();
    try {
      await _store.writePermission(allowed);
      if (!_disposed) {
        _choice = allowed;
        repository.setImagesAllowed(allowed);
      }
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
