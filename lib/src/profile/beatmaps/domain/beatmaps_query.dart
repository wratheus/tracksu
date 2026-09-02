import 'package:tracksu/src/profile/domain/profile_user_reference.dart';

enum ProfileBeatmapsType {
  mostPlayed,
  favourite,
  ranked,
  pending,
  graveyard,
  loved,
  guest,
  nominated,
}

final class ProfileBeatmapsQuery {
  ProfileBeatmapsQuery({
    required this.user,
    required this.type,
    this.limit = 20,
    this.offset = 0,
  }) {
    if (limit < 1 || limit > 100 || offset < 0) {
      throw ArgumentError('Expected limit 1..100 and a non-negative offset.');
    }
  }

  final ProfileUserId user;
  final ProfileBeatmapsType type;
  final int limit;
  final int offset;
}
