import 'package:tracksu/src/profile/domain/profile_details.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';

final class SearchPlayer {
  const SearchPlayer({
    required this.id,
    required this.username,
    required this.country,
    this.avatarUrl,
    this.ruleset,
    this.team,
    this.isOnline = false,
    this.isSupporter = false,
  });
  final int id;
  final String username;
  final String country;
  final String? avatarUrl;
  final ProfileRuleset? ruleset;

  /// Present when the API includes it in compact users.
  final ProfileTeam? team;
  final bool isOnline;
  final bool isSupporter;
}

final class UserSearchPage {
  UserSearchPage({required List<SearchPlayer> items, required this.total})
    : items = List.unmodifiable(items);
  final List<SearchPlayer> items;
  final int total;
}

enum UserSearchFailureKind { unavailable, invalidResponse, rateLimited }

final class UserSearchFailure implements Exception {
  const UserSearchFailure(this.kind);
  final UserSearchFailureKind kind;
}

abstract interface class UserSearchRepository {
  Future<UserSearchPage> search(String query, {int page = 1});
  Future<SearchPlayer> lookup(String identifier);
  void cancelPending();
}
