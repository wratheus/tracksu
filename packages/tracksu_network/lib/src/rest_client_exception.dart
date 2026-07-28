sealed class RestClientException implements Exception {
  const RestClientException({
    required this.uri,
    required this.cause,
    required this.stackTrace,
  });

  final Uri uri;
  final Object cause;
  final StackTrace stackTrace;
}

final class RestRequestCancelledException extends RestClientException {
  const RestRequestCancelledException({
    required super.uri,
    required super.cause,
    required super.stackTrace,
  });
}

final class RestRequestTimeoutException extends RestClientException {
  const RestRequestTimeoutException({
    required super.uri,
    required super.cause,
    required super.stackTrace,
  });
}

final class RestTransportException extends RestClientException {
  const RestTransportException({
    required super.uri,
    required super.cause,
    required super.stackTrace,
  });
}
