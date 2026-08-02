import 'package:tracksu_network/tracksu_network.dart';

final class OsuApiHeadersInterceptor implements RestClientInterceptor {
  const OsuApiHeadersInterceptor();

  static const apiResponseVersion = '20220705';

  @override
  Future<RestRequest> onRequest(RestRequest request) {
    final Map<String, String> headers = Map<String, String>.from(
      request.headers,
    );
    if (!_hasHeader(headers, 'accept')) {
      headers['accept'] = 'application/json';
    }
    if (!_hasHeader(headers, 'x-api-version')) {
      headers['x-api-version'] = apiResponseVersion;
    }

    return Future<RestRequest>.value(request.copyWith(headers: headers));
  }

  @override
  Future<RestResponse> onResponse({
    required RestRequest request,
    required RestResponse response,
  }) {
    return Future<RestResponse>.value(response);
  }

  bool _hasHeader(Map<String, String> headers, String name) {
    return headers.keys.any(
      (String headerName) => headerName.toLowerCase() == name,
    );
  }
}
