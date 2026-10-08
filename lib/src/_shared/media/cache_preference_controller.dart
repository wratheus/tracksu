import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:tracksu/src/_core/cache/page_cache.dart';
import 'package:tracksu/src/_shared/audio/audio_playback_controller.dart';
import 'package:tracksu/src/_shared/media/data/media_cache_repository.dart';
import 'package:tracksu_storage/tracksu_storage.dart';

/// One switch for every cache: session page snapshots and the disk media
/// cache. On by default; off drops what is stored right away.
final class CachePreferenceController extends ChangeNotifier {
  CachePreferenceController({
    required CachePreferenceStore store,
    required PageCache pageCache,
    required MediaCacheRepository mediaCache,
    required AudioPlaybackController audio,
  }) : _store = store,
       _pageCache = pageCache,
       _mediaCache = mediaCache,
       _audio = audio;

  final CachePreferenceStore _store;
  final PageCache _pageCache;
  final MediaCacheRepository _mediaCache;
  final AudioPlaybackController _audio;
  bool _enabled = true;
  bool _saving = false;

  bool get enabled => _enabled;
  bool get saving => _saving;

  Future<void> restore() async {
    try {
      _enabled = await _store.readEnabled() ?? true;
    } on Object {
      _enabled = true;
    }
    _apply();
    if (!_enabled) await _mediaCache.setDiskCacheEnabled(false);
  }

  Future<void> select(bool enabled) async {
    if (_saving || enabled == _enabled) return;
    _saving = true;
    _enabled = enabled;
    _apply();
    notifyListeners();
    try {
      if (!enabled) {
        // Same order as "Clear cache": stop playback, then drop files.
        await _audio.stop();
        PaintingBinding.instance.imageCache.clear();
      }
      await _mediaCache.setDiskCacheEnabled(enabled);
      await _store.writeEnabled(enabled);
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  void _apply() => _pageCache.enabled = _enabled;
}
