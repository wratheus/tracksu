import 'package:tracksu_network/src/rest_request.dart';
import 'package:tracksu_network/src/rest_response.dart';

/// Proposes one replacement request after a completed response.
///
/// The transport permits at most one retry for an original request. Returning
/// `null` preserves the response without retrying it.
abstract interface class RestClientRetryInterceptor {
  Future<RestRequest?> retryRequest({
    required RestRequest request,
    required RestResponse response,
  });
}
