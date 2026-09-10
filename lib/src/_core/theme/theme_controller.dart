import 'package:flutter/material.dart';
import 'package:tracksu_storage/tracksu_storage.dart';

final class ThemeController extends ValueNotifier<ThemeMode> {
  factory ThemeController({required ThemeStore store}) =>
      ThemeController._(store);
  ThemeController._(this._store) : super(ThemeMode.system);
  final ThemeStore _store;
  bool _saving = false;
  bool _disposed = false;

  Future<void> restore() async {
    ThemeMode restored = ThemeMode.system;
    try {
      restored = switch (await _store.readMode()) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
    } on Object {
      // A cosmetic preference must not prevent the app from starting.
    }
    if (!_disposed) value = restored;
  }

  Future<void> select(ThemeMode mode) async {
    if (_saving || _disposed || mode == value) return;
    _saving = true;
    try {
      await _store.writeMode(mode.name);
      if (!_disposed) value = mode;
    } finally {
      _saving = false;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
