import 'package:flutter/foundation.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu_storage/tracksu_storage.dart';

/// The game mode chosen once in the app bar and carried across pages
/// (ADR-011): rankings and spotlights follow it. A player's or a team's page
/// opens in their own main mode instead and changes only itself.
final class RulesetController extends ValueNotifier<ProfileRuleset> {
  factory RulesetController({required RulesetStore store}) =>
      RulesetController._(store);
  RulesetController._(this._store) : super(ProfileRuleset.osu);
  final RulesetStore _store;
  bool _disposed = false;

  Future<void> restore() async {
    ProfileRuleset restored = ProfileRuleset.osu;
    try {
      final String? stored = await _store.readRuleset();
      restored = ProfileRuleset.values.firstWhere(
        (ProfileRuleset ruleset) => ruleset.apiValue == stored,
        orElse: () => ProfileRuleset.osu,
      );
    } on Object {
      // A preference must not prevent the app from starting.
    }
    if (!_disposed) value = restored;
  }

  /// Applies at once (pages reload in the new mode); saving is best-effort.
  Future<void> select(ProfileRuleset ruleset) async {
    if (_disposed || ruleset == value) return;
    value = ruleset;
    try {
      await _store.writeRuleset(ruleset.apiValue);
    } on Object {
      // Kept for this session even if it could not be saved.
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
