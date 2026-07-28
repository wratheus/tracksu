import 'package:tracksu_network/src/rest_client_options.dart';
import 'package:tracksu_network/src/rest_request.dart';
import 'package:tracksu_network/src/rest_response.dart';

abstract interface class RestClient {
  Uri get baseUri;

  Future<RestResponse> get({
    required String path,
    Map<String, String> headers,
    Map<String, Object?> queryParameters,
    RestClientOptions options,
  });

  Future<RestResponse> post({
    required String path,
    required Map<String, Object?> body,
    RestContentType contentType,
    Map<String, String> headers,
    Map<String, Object?> queryParameters,
    RestClientOptions options,
  });

  Future<RestResponse> put({
    required String path,
    required Map<String, Object?> body,
    RestContentType contentType,
    Map<String, String> headers,
    Map<String, Object?> queryParameters,
    RestClientOptions options,
  });

  Future<RestResponse> patch({
    required String path,
    required Map<String, Object?> body,
    RestContentType contentType,
    Map<String, String> headers,
    Map<String, Object?> queryParameters,
    RestClientOptions options,
  });

  Future<RestResponse> delete({
    required String path,
    Map<String, String> headers,
    Map<String, Object?> queryParameters,
    RestClientOptions options,
  });

  Future<RestResponse> head({
    required String path,
    Map<String, String> headers,
    Map<String, Object?> queryParameters,
    RestClientOptions options,
  });

  Future<RestResponse> options({
    required String path,
    Map<String, String> headers,
    Map<String, Object?> queryParameters,
    RestClientOptions options,
  });

  void close();
}
