import 'dart:collection';

import 'package:meta/meta.dart';

enum RestMethod { get, post, put, patch, delete, head, options }

enum RestContentType { json, form }

sealed class RestBody {
  const RestBody();
}

final class RestJsonBody extends RestBody {
  RestJsonBody(Map<String, Object?> value)
    : value = UnmodifiableMapView<String, Object?>(value);

  final Map<String, Object?> value;
}

final class RestFormBody extends RestBody {
  RestFormBody(Map<String, Object?> value)
    : value = UnmodifiableMapView<String, Object?>(value);

  final Map<String, Object?> value;
}

@immutable
final class RestRequest {
  RestRequest({
    required this.method,
    required this.uri,
    Map<String, String> headers = const <String, String>{},
    this.body,
    this.timeout = const Duration(seconds: 20),
  }) : headers = UnmodifiableMapView<String, String>(headers);

  final RestMethod method;
  final Uri uri;
  final Map<String, String> headers;
  final RestBody? body;
  final Duration timeout;

  RestRequest copyWith({
    Map<String, String>? headers,
    RestBody? body,
    Duration? timeout,
  }) {
    return RestRequest(
      method: method,
      uri: uri,
      headers: headers ?? this.headers,
      body: body ?? this.body,
      timeout: timeout ?? this.timeout,
    );
  }
}
