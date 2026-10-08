import 'package:tracksu/src/_shared/events/data/osu_event_dto.dart';
import 'package:tracksu/src/_shared/events/domain/osu_event.dart';
import 'package:tracksu/src/auth/data/oauth_remote_source_exception.dart';
import 'package:tracksu_network/tracksu_network.dart';

/// One page of the global osu! feed (`GET /events`, scope public): 50 newest
/// first; [cursor] continues to older events, null at the end.
final class OsuEventsPage {
  OsuEventsPage({required List<OsuEvent> items, this.cursor})
    : items = List<OsuEvent>.unmodifiable(items);
  final List<OsuEvent> items;
  final String? cursor;
}

enum OsuEventsFailureKind {
  cancelled,
  rateLimited,
  connection,
  invalidResponse,
  unavailable,
}

final class OsuEventsFailure implements Exception {
  const OsuEventsFailure(this.kind);
  final OsuEventsFailureKind kind;
}

/// A newer read cancels the previous one.
final class OsuEventsRepository {
  OsuEventsRepository({required RestClient restClient}) : _client = restClient;
  final RestClient _client;
  RestCancellationToken? _pending;

  void cancelPending() {
    _pending?.cancel();
    _pending = null;
  }

  Future<OsuEventsPage> load({String? cursor}) async {
    cancelPending();
    final RestCancellationToken token = RestCancellationToken();
    _pending = token;
    try {
      final RestResponse response = await _client.get(
        path: '/events',
        queryParameters: <String, Object?>{'cursor_string': ?cursor},
        options: RestClientOptions(cancellationToken: token),
      );
      if (token.isCancelled) {
        throw const OsuEventsFailure(OsuEventsFailureKind.cancelled);
      }
      if (response.statusCode != 200) throw _status(response.statusCode);
      final Map<String, dynamic> json = response.payload.asMap();
      final List<OsuEvent> items = <OsuEvent>[];
      for (final Object? item in json['events'] as List<dynamic>? ?? const []) {
        if (item is! Map<String, dynamic>) {
          throw const FormatException('Expected an event object.');
        }
        if (OsuEventDto.fromJson(item) case final OsuEvent event) {
          items.add(event);
        }
      }
      final Object? next = json['cursor_string'];
      return OsuEventsPage(
        items: items,
        cursor: next is String && next.isNotEmpty ? next : null,
      );
    } on OAuthRemoteSourceException catch (error, stackTrace) {
      Error.throwWithStackTrace(_status(error.statusCode), stackTrace);
    } on FormatException catch (_, stackTrace) {
      Error.throwWithStackTrace(
        const OsuEventsFailure(OsuEventsFailureKind.invalidResponse),
        stackTrace,
      );
    } on TypeError catch (_, stackTrace) {
      Error.throwWithStackTrace(
        const OsuEventsFailure(OsuEventsFailureKind.invalidResponse),
        stackTrace,
      );
    } on RestRequestCancelledException catch (_, stackTrace) {
      Error.throwWithStackTrace(
        const OsuEventsFailure(OsuEventsFailureKind.cancelled),
        stackTrace,
      );
    } on RestClientException catch (_, stackTrace) {
      Error.throwWithStackTrace(
        const OsuEventsFailure(OsuEventsFailureKind.connection),
        stackTrace,
      );
    } finally {
      if (identical(_pending, token)) _pending = null;
    }
  }

  static OsuEventsFailure _status(int status) => OsuEventsFailure(
    status == 429
        ? OsuEventsFailureKind.rateLimited
        : OsuEventsFailureKind.unavailable,
  );
}
