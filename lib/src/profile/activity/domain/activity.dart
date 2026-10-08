import 'package:tracksu/src/_shared/events/domain/osu_event.dart';
import 'package:tracksu/src/profile/domain/profile_user_reference.dart';

final class ProfileActivityQuery {
  ProfileActivityQuery({required this.user, this.limit = 20, this.offset = 0}) {
    if (limit < 1 || limit > 100 || offset < 0) {
      throw ArgumentError('Expected limit 1..100 and a non-negative offset.');
    }
  }
  final ProfileUserId user;
  final int limit;
  final int offset;
}

final class ProfileActivityPage {
  ProfileActivityPage({required List<OsuEvent> items, this.nextOffset})
    : items = List<OsuEvent>.unmodifiable(items);
  final List<OsuEvent> items;
  final int? nextOffset;
}

enum ProfileActivityFailureKind {
  cancelled,
  notFound,
  rateLimited,
  connection,
  invalidResponse,
  unavailable,
}

final class ProfileActivityFailure implements Exception {
  const ProfileActivityFailure(this.kind);
  final ProfileActivityFailureKind kind;
}

abstract interface class ProfileActivityRepository {
  Future<ProfileActivityPage> load(ProfileActivityQuery query);
  void cancelPending();
}
