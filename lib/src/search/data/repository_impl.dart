import 'package:tracksu/src/profile/domain/profile_details.dart';
import 'package:tracksu/src/_core/serialization/json_map_reader.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';
import 'package:tracksu/src/profile/domain/profile_user_reference.dart';
import 'package:tracksu/src/search/data/remote_source.dart';
import 'package:tracksu/src/search/domain/user_search.dart';
import 'package:tracksu_network/tracksu_network.dart';

final class UserSearchRepositoryImpl implements UserSearchRepository {
  UserSearchRepositoryImpl({required this._source});
  final UserSearchRemoteSource _source;
  RestCancellationToken? _pending;
  RestCancellationToken? _lookup;

  @override
  void cancelPending() {
    _pending?.cancel();
    _lookup?.cancel();
  }

  Future<T> _request<T>(
    Future<T> Function(RestCancellationToken) load, {
    bool lookup = false,
  }) async {
    final RestCancellationToken token = RestCancellationToken();
    if (lookup) {
      _lookup?.cancel();
      _lookup = token;
    } else {
      _pending?.cancel();
      _pending = token;
    }
    try {
      return await load(token);
    } on RestRequestCancelledException {
      rethrow;
    } on UserSearchRemoteException catch (error, stack) {
      Error.throwWithStackTrace(
        UserSearchFailure(
          error.status == 429
              ? UserSearchFailureKind.rateLimited
              : UserSearchFailureKind.unavailable,
        ),
        stack,
      );
    } on FormatException catch (_, stack) {
      Error.throwWithStackTrace(
        const UserSearchFailure(UserSearchFailureKind.invalidResponse),
        stack,
      );
    } on Object catch (_, stack) {
      Error.throwWithStackTrace(
        const UserSearchFailure(UserSearchFailureKind.unavailable),
        stack,
      );
    }
  }

  @override
  Future<SearchPlayer> lookup(String identifier) => _request(
    (token) async => decodePlayer(await _source.lookup(identifier, token)),
    lookup: true,
  );

  @override
  Future<UserSearchPage> search(String query, {int page = 1}) => _request((
    token,
  ) async {
    // Explicit names and numeric IDs retain their unambiguous lookup semantics.
    if (query.startsWith('@') || RegExp(r'^[+-]?[0-9]+$').hasMatch(query)) {
      try {
        final ProfileUserReference reference = ProfileUserReference.fromInput(
          query,
        );
        final SearchPlayer player = decodePlayer(
          await _source.lookup(reference.apiValue, token),
        );
        return UserSearchPage(items: [player], total: 1);
      } on UserSearchRemoteException catch (error) {
        if (error.status != 404) rethrow;
        return UserSearchPage(items: [], total: 0);
      } on ArgumentError {
        return UserSearchPage(items: [], total: 0);
      }
    }
    return decode(await _source.search(query, page, token));
  });

  static SearchPlayer decodePlayer(Map<String, dynamic> raw) {
    final JsonMapReader reader = JsonMapReader(raw);
    final String? mode = reader.optionalString('playmode');
    final String? avatar = reader.optionalString('avatar_url');
    final Uri? uri = avatar == null ? null : Uri.tryParse(avatar);
    return SearchPlayer(
      id: reader.requiredInt('id', positive: true),
      username: reader.requiredString('username'),
      country: reader.requiredString('country_code'),
      avatarUrl: uri != null && uri.scheme == 'https' && uri.host.isNotEmpty
          ? avatar
          : null,
      ruleset: ProfileRuleset.values
          .where((value) => value.apiValue == mode)
          .firstOrNull,
      team: _team(reader.optionalMap('team')),
      isOnline: reader.optionalBool('is_online') ?? false,
      isSupporter: reader.optionalBool('is_supporter') ?? false,
    );
  }

  /// Optional decoration: a malformed team never hides the player.
  static ProfileTeam? _team(Map<String, dynamic>? raw) {
    if (raw == null) return null;
    try {
      final JsonMapReader reader = JsonMapReader(raw);
      final String? flag = reader.optionalString('flag_url');
      final Uri? flagUri = flag == null ? null : Uri.tryParse(flag);
      return ProfileTeam(
        id: reader.requiredInt('id', positive: true),
        name: reader.requiredString('name'),
        shortName: reader.requiredString('short_name'),
        flagUri: flagUri != null && flagUri.isScheme('https') ? flagUri : null,
      );
    } on FormatException {
      return null;
    }
  }

  static UserSearchPage decode(Map<String, dynamic> raw) {
    final JsonMapReader reader = JsonMapReader(
      JsonMapReader.asMap(raw['user']),
    );
    final int total = reader.requiredInt('total');
    if (total < 0) throw const FormatException('Negative user count');
    final Map<int, SearchPlayer> unique = {};
    for (final Object? row in reader.requiredList('data')) {
      final SearchPlayer player = decodePlayer(JsonMapReader.asMap(row));
      unique[player.id] = player;
    }
    return UserSearchPage(items: unique.values.toList(), total: total);
  }
}
