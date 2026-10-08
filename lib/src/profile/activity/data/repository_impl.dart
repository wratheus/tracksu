import 'package:tracksu/src/_shared/events/domain/osu_event.dart';
import 'package:tracksu/src/auth/data/oauth_remote_source_exception.dart';
import 'package:tracksu/src/_shared/events/data/osu_event_dto.dart';
import 'package:tracksu/src/profile/activity/data/remote_source.dart';
import 'package:tracksu/src/profile/activity/domain/activity.dart';
import 'package:tracksu_network/tracksu_network.dart';

/// One instance per profile; a newer read cancels the previous one.
final class ProfileActivityRepositoryImpl implements ProfileActivityRepository {
  ProfileActivityRepositoryImpl({required this._remoteSource});

  /// osu-web returns nothing past this offset.
  static const int maxResults = 100;

  final ProfileActivityRemoteSource _remoteSource;
  RestCancellationToken? _pending;

  @override
  void cancelPending() {
    _pending?.cancel();
    _pending = null;
  }

  @override
  Future<ProfileActivityPage> load(ProfileActivityQuery query) async {
    cancelPending();
    final RestCancellationToken token = RestCancellationToken();
    _pending = token;
    try {
      final List<dynamic> payload = await _remoteSource.load(
        query,
        options: RestClientOptions(cancellationToken: token),
      );
      if (token.isCancelled) {
        throw const ProfileActivityFailure(
          ProfileActivityFailureKind.cancelled,
        );
      }
      final List<OsuEvent> items = <OsuEvent>[];
      for (final Object? item in payload) {
        if (item is! Map<String, dynamic>) {
          throw const FormatException('Expected an event object.');
        }
        if (OsuEventDto.fromJson(item) case final OsuEvent a) {
          items.add(a);
        }
      }
      final int next = query.offset + payload.length;
      return ProfileActivityPage(
        items: items,
        nextOffset: payload.length == query.limit && next < maxResults
            ? next
            : null,
      );
    } on ProfileActivityRemoteException catch (error, stackTrace) {
      Error.throwWithStackTrace(_statusFailure(error.statusCode), stackTrace);
    } on OAuthRemoteSourceException catch (error, stackTrace) {
      Error.throwWithStackTrace(_statusFailure(error.statusCode), stackTrace);
    } on FormatException catch (_, stackTrace) {
      Error.throwWithStackTrace(
        const ProfileActivityFailure(
          ProfileActivityFailureKind.invalidResponse,
        ),
        stackTrace,
      );
    } on RestRequestCancelledException catch (_, stackTrace) {
      Error.throwWithStackTrace(
        const ProfileActivityFailure(ProfileActivityFailureKind.cancelled),
        stackTrace,
      );
    } on RestClientException catch (_, stackTrace) {
      Error.throwWithStackTrace(
        const ProfileActivityFailure(ProfileActivityFailureKind.connection),
        stackTrace,
      );
    } finally {
      if (identical(_pending, token)) _pending = null;
    }
  }

  ProfileActivityFailure _statusFailure(int status) =>
      ProfileActivityFailure(switch (status) {
        404 => ProfileActivityFailureKind.notFound,
        429 => ProfileActivityFailureKind.rateLimited,
        _ => ProfileActivityFailureKind.unavailable,
      });
}
