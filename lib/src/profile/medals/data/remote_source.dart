import 'package:tracksu_network/tracksu_network.dart';

/// Official public web bootstrap; no OAuth interceptor/cookie jar on this client.
final class MedalsRemoteSource {
  const MedalsRemoteSource(this.client);
  final RestClient client;
  Future<String> load(int userId, RestCancellationToken token) async {
    if (userId <= 0) throw ArgumentError.value(userId, 'userId');
    final RestResponse response = await client.get(
      path: '/users/$userId',
      options: RestClientOptions(cancellationToken: token),
    );
    if (response.statusCode != 200) {
      throw const FormatException('Medal page unavailable.');
    }
    if (response.bodyText.length > 3000000) {
      throw const FormatException('Medal page is too large.');
    }
    return response.bodyText;
  }
}
