import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tracksu_network/src/rest_cancellation_token.dart';
import 'package:tracksu_network/src/rest_client.dart';
import 'package:tracksu_network/src/rest_client_exception.dart';
import 'package:tracksu_network/src/rest_client_interceptor.dart';
import 'package:tracksu_network/src/rest_client_options.dart';
import 'package:tracksu_network/src/rest_request.dart';
import 'package:tracksu_network/src/rest_response.dart';

final class HttpRestClient implements RestClient {
  factory HttpRestClient({
    required http.Client client,
    required Uri baseUri,
    Iterable<RestClientInterceptor> interceptors =
        const <RestClientInterceptor>[],
  }) {
    return HttpRestClient._(
      client,
      baseUri,
      List<RestClientInterceptor>.unmodifiable(interceptors),
    );
  }

  HttpRestClient._(this._client, this._baseUri, this._interceptors) {
    if (!_baseUri.isScheme('https') || !_baseUri.hasAuthority) {
      throw ArgumentError.value(
        _baseUri,
        'baseUri',
        'An absolute HTTPS URI is required.',
      );
    }
  }

  final http.Client _client;
  final Uri _baseUri;
  final List<RestClientInterceptor> _interceptors;
  var _isClosed = false;

  @override
  Uri get baseUri => _baseUri;

  @override
  Future<RestResponse> get({
    required String path,
    Map<String, String> headers = const <String, String>{},
    Map<String, Object?> queryParameters = const <String, Object?>{},
    RestClientOptions options = const RestClientOptions(),
  }) {
    return _send(
      RestRequest(
        method: RestMethod.get,
        uri: _resolveUri(path, queryParameters),
        headers: headers,
        timeout: options.timeout,
      ),
      options.cancellationToken,
    );
  }

  @override
  Future<RestResponse> post({
    required String path,
    required Map<String, Object?> body,
    RestContentType contentType = RestContentType.json,
    Map<String, String> headers = const <String, String>{},
    Map<String, Object?> queryParameters = const <String, Object?>{},
    RestClientOptions options = const RestClientOptions(),
  }) {
    return _sendWithBody(
      method: RestMethod.post,
      path: path,
      body: body,
      contentType: contentType,
      headers: headers,
      queryParameters: queryParameters,
      options: options,
    );
  }

  @override
  Future<RestResponse> put({
    required String path,
    required Map<String, Object?> body,
    RestContentType contentType = RestContentType.json,
    Map<String, String> headers = const <String, String>{},
    Map<String, Object?> queryParameters = const <String, Object?>{},
    RestClientOptions options = const RestClientOptions(),
  }) {
    return _sendWithBody(
      method: RestMethod.put,
      path: path,
      body: body,
      contentType: contentType,
      headers: headers,
      queryParameters: queryParameters,
      options: options,
    );
  }

  @override
  Future<RestResponse> patch({
    required String path,
    required Map<String, Object?> body,
    RestContentType contentType = RestContentType.json,
    Map<String, String> headers = const <String, String>{},
    Map<String, Object?> queryParameters = const <String, Object?>{},
    RestClientOptions options = const RestClientOptions(),
  }) {
    return _sendWithBody(
      method: RestMethod.patch,
      path: path,
      body: body,
      contentType: contentType,
      headers: headers,
      queryParameters: queryParameters,
      options: options,
    );
  }

  @override
  Future<RestResponse> delete({
    required String path,
    Map<String, String> headers = const <String, String>{},
    Map<String, Object?> queryParameters = const <String, Object?>{},
    RestClientOptions options = const RestClientOptions(),
  }) {
    return _sendWithoutBody(
      method: RestMethod.delete,
      path: path,
      headers: headers,
      queryParameters: queryParameters,
      options: options,
    );
  }

  @override
  Future<RestResponse> head({
    required String path,
    Map<String, String> headers = const <String, String>{},
    Map<String, Object?> queryParameters = const <String, Object?>{},
    RestClientOptions options = const RestClientOptions(),
  }) {
    return _sendWithoutBody(
      method: RestMethod.head,
      path: path,
      headers: headers,
      queryParameters: queryParameters,
      options: options,
    );
  }

  @override
  Future<RestResponse> options({
    required String path,
    Map<String, String> headers = const <String, String>{},
    Map<String, Object?> queryParameters = const <String, Object?>{},
    RestClientOptions options = const RestClientOptions(),
  }) {
    return _sendWithoutBody(
      method: RestMethod.options,
      path: path,
      headers: headers,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<RestResponse> _sendWithBody({
    required RestMethod method,
    required String path,
    required Map<String, Object?> body,
    required RestContentType contentType,
    required Map<String, String> headers,
    required Map<String, Object?> queryParameters,
    required RestClientOptions options,
  }) {
    return _send(
      RestRequest(
        method: method,
        uri: _resolveUri(path, queryParameters),
        headers: headers,
        body: switch (contentType) {
          RestContentType.json => RestJsonBody(body),
          RestContentType.form => RestFormBody(body),
        },
        timeout: options.timeout,
      ),
      options.cancellationToken,
    );
  }

  Future<RestResponse> _sendWithoutBody({
    required RestMethod method,
    required String path,
    required Map<String, String> headers,
    required Map<String, Object?> queryParameters,
    required RestClientOptions options,
  }) {
    return _send(
      RestRequest(
        method: method,
        uri: _resolveUri(path, queryParameters),
        headers: headers,
        timeout: options.timeout,
      ),
      options.cancellationToken,
    );
  }

  Future<RestResponse> _send(
    RestRequest request,
    RestCancellationToken? cancellationToken,
  ) async {
    if (_isClosed) {
      throw StateError('Rest client has already been closed.');
    }

    RestRequest interceptedRequest = request;
    for (final RestClientInterceptor interceptor in _interceptors) {
      interceptedRequest = await interceptor.onRequest(interceptedRequest);
    }

    if (cancellationToken?.isCancelled ?? false) {
      throw RestRequestCancelledException(
        uri: interceptedRequest.uri,
        cause: StateError('Request was cancelled before it was sent.'),
        stackTrace: StackTrace.current,
      );
    }

    final http.AbortableRequest httpRequest = _createHttpRequest(
      request: interceptedRequest,
      abortTrigger: cancellationToken?.whenCancelled,
    );

    try {
      final http.StreamedResponse streamedResponse = await _client
          .send(httpRequest)
          .timeout(interceptedRequest.timeout);
      final http.Response response = await http.Response.fromStream(
        streamedResponse,
      );
      RestResponse restResponse = RestResponse(
        statusCode: response.statusCode,
        headers: response.headers,
        bodyBytes: response.bodyBytes,
      );

      for (final RestClientInterceptor interceptor in _interceptors) {
        restResponse = await interceptor.onResponse(
          request: interceptedRequest,
          response: restResponse,
        );
      }

      return restResponse;
    } on http.RequestAbortedException catch (error, stackTrace) {
      throw RestRequestCancelledException(
        uri: interceptedRequest.uri,
        cause: error,
        stackTrace: stackTrace,
      );
    } on TimeoutException catch (error, stackTrace) {
      throw RestRequestTimeoutException(
        uri: interceptedRequest.uri,
        cause: error,
        stackTrace: stackTrace,
      );
    } on Object catch (error, stackTrace) {
      throw RestTransportException(
        uri: interceptedRequest.uri,
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  void close() {
    if (_isClosed) {
      return;
    }

    _isClosed = true;
    _client.close();
  }

  http.AbortableRequest _createHttpRequest({
    required RestRequest request,
    required Future<void>? abortTrigger,
  }) {
    final http.AbortableRequest httpRequest = http.AbortableRequest(
      _methodName(request.method),
      request.uri,
      abortTrigger: abortTrigger,
    );
    httpRequest.headers.addAll(request.headers);

    switch (request.body) {
      case null:
        break;
      case RestFormBody(:final Map<String, Object?> value):
        httpRequest.bodyFields = _formFields(value);
      case RestJsonBody(:final Map<String, Object?> value):
        httpRequest.headers.putIfAbsent(
          'content-type',
          () => 'application/json; charset=utf-8',
        );
        httpRequest.body = jsonEncode(value);
    }

    return httpRequest;
  }

  String _methodName(RestMethod method) {
    return switch (method) {
      RestMethod.get => 'GET',
      RestMethod.post => 'POST',
      RestMethod.put => 'PUT',
      RestMethod.patch => 'PATCH',
      RestMethod.delete => 'DELETE',
      RestMethod.head => 'HEAD',
      RestMethod.options => 'OPTIONS',
    };
  }

  Uri _resolveUri(String path, Map<String, Object?> queryParameters) {
    final Uri pathUri = Uri.parse(path);
    if (pathUri.hasScheme || pathUri.hasAuthority || pathUri.hasQuery) {
      throw ArgumentError.value(
        path,
        'path',
        'A relative path without query is required.',
      );
    }

    final String normalizedPath = path.startsWith('/') ? path : '/$path';
    final Map<String, String> normalizedQueryParameters = <String, String>{};
    for (final MapEntry<String, Object?> entry in queryParameters.entries) {
      final Object? value = entry.value;
      if (value != null) {
        normalizedQueryParameters[entry.key] = _scalarValue(
          value,
          'queryParameters',
        );
      }
    }

    return _baseUri.replace(
      path: _joinPaths(_baseUri.path, normalizedPath),
      queryParameters: normalizedQueryParameters.isEmpty
          ? null
          : normalizedQueryParameters,
    );
  }

  Map<String, String> _formFields(Map<String, Object?> body) {
    return Map<String, String>.fromEntries(
      body.entries.map(
        (MapEntry<String, Object?> entry) => MapEntry<String, String>(
          entry.key,
          _scalarValue(entry.value, 'form body'),
        ),
      ),
    );
  }

  String _scalarValue(Object? value, String parameterName) {
    if (value case String() || num() || bool()) {
      return value.toString();
    }

    throw ArgumentError.value(
      value,
      parameterName,
      'Only String, num, and bool values are supported.',
    );
  }

  String _joinPaths(String basePath, String path) {
    final String normalizedBasePath = basePath.endsWith('/')
        ? basePath.substring(0, basePath.length - 1)
        : basePath;
    return '$normalizedBasePath$path';
  }
}
