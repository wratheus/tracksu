import 'dart:collection';

/// Session-local, bounded snapshots. Consumers always revalidate over the API;
/// errors never replace a successful snapshot. No credentials or disk writes.
final class PageCache {
  PageCache({required int Function() identityRevision})
    : _identityRevision = identityRevision,
      _identity = identityRevision();
  final int Function() _identityRevision;
  final LinkedHashMap<Object, ({Object value, DateTime saved})> _entries =
      LinkedHashMap<Object, ({Object value, DateTime saved})>();
  int _identity;
  int _revision = 0;

  int get revision {
    final int identity = _identityRevision();
    if (identity != _identity) {
      _identity = identity;
      clear();
    }
    return _revision;
  }

  T? read<T extends Object>(Object key) {
    final int current = revision;
    final entry = _entries.remove(key);
    if (entry == null ||
        DateTime.now().difference(entry.saved) > const Duration(minutes: 30)) {
      return null;
    }
    if (current != _revision || entry.value is! T) return null;
    _entries[key] = entry;
    return entry.value as T;
  }

  void write(Object key, Object value, {required int revision}) {
    // Clearing during an in-flight request must not silently repopulate cache.
    if (revision != this.revision) return;
    _entries.remove(key);
    _entries[key] = (value: value, saved: DateTime.now());
    while (_entries.length > 40) {
      _entries.remove(_entries.keys.first);
    }
  }

  void clear() {
    _entries.clear();
    _revision++;
  }
}
