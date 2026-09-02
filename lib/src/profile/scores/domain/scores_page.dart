import 'package:tracksu/src/_shared/scores/domain/score.dart';

final class ProfileScoresPage {
  ProfileScoresPage({required List<OsuScore> items, required this.nextOffset})
    : items = List<OsuScore>.unmodifiable(items);

  final List<OsuScore> items;

  /// A full page suggests another read; the endpoint supplies no total/cursor.
  final int? nextOffset;
}
