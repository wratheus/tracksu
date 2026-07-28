import 'package:tracksu_network/src/rest_request.dart';
import 'package:tracksu_network/src/rest_response.dart';

/// A narrow policy hook for shared headers and response observation.
///
/// Endpoint-specific mapping belongs in a feature's remote source. Interceptors
/// must not log credentials or response bodies.
abstract interface class RestClientInterceptor {
  Future<RestRequest> onRequest(RestRequest request) {
    return Future<RestRequest>.value(request);
  }

  Future<RestResponse> onResponse({
    required RestRequest request,
    required RestResponse response,
  }) {
    return Future<RestResponse>.value(response);
  }
}
