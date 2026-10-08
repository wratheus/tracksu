import 'package:tracksu_network/tracksu_network.dart';

/// Common osu! API headers. `Accept-Language` follows the app language, so
/// texts the API localizes (osu-web `SetLocaleApi`) match the interface; a
/// signed-in user's osu! profile language is used only when it is absent.
final class OsuApiHeadersInterceptor implements RestClientInterceptor {
  const OsuApiHeadersInterceptor({this.languageCode});

  /// Current app language (`en`, `ru`, …); null sends no header.
  final String? Function()? languageCode;

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
    final String? language = languageCode?.call();
    if (language != null && !_hasHeader(headers, 'accept-language')) {
      headers['accept-language'] = language;
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
