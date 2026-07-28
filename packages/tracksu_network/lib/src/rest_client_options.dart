import 'package:meta/meta.dart';
import 'package:tracksu_network/src/rest_cancellation_token.dart';

@immutable
final class RestClientOptions {
  const RestClientOptions({
    this.timeout = const Duration(seconds: 20),
    this.cancellationToken,
  });

  final Duration timeout;
  final RestCancellationToken? cancellationToken;
}
