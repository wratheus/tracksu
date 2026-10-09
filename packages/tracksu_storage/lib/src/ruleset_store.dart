import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// The app-wide game mode (osu!, taiko, catch, mania) as its API name.
abstract interface class RulesetStore {
  Future<String?> readRuleset();
  Future<void> writeRuleset(String ruleset);
}

final class FlutterSecureRulesetStore implements RulesetStore {
  factory FlutterSecureRulesetStore({required FlutterSecureStorage storage}) =>
      FlutterSecureRulesetStore._(storage);
  FlutterSecureRulesetStore._(this._storage);
  final FlutterSecureStorage _storage;
  static const String _key = 'app_ruleset';

  @override
  Future<String?> readRuleset() => _storage.read(key: _key);

  @override
  Future<void> writeRuleset(String ruleset) =>
      _storage.write(key: _key, value: ruleset);
}
