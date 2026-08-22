import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:tracksu_network/src/rest_response_payload.dart';

@immutable
final class RestResponse {
  RestResponse({
    required this.statusCode,
    required Map<String, String> headers,
    required Uint8List bodyBytes,
  }) : headers = UnmodifiableMapView<String, String>(headers),
       bodyBytes = Uint8List.fromList(bodyBytes);

  final int statusCode;
  final Map<String, String> headers;
  final Uint8List bodyBytes;

  String get bodyText => utf8.decode(bodyBytes);

  late final RestResponsePayload payload = RestResponsePayload(bodyText);
}
