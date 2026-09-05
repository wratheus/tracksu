import 'package:tracksu/src/news/domain/news.dart';
import 'package:tracksu_network/tracksu_network.dart';

abstract interface class NewsRemoteSource {
  Future<Map<String, dynamic>> list({
    String? cursor,
    required RestClientOptions options,
  });
  Future<Map<String, dynamic>> article(
    NewsArticleParams params, {
    required RestClientOptions options,
  });
}

final class OsuNewsRemoteSource implements NewsRemoteSource {
  const OsuNewsRemoteSource({required RestClient restClient})
    : _client = restClient;
  final RestClient _client;
  @override
  Future<Map<String, dynamic>> list({
    String? cursor,
    required RestClientOptions options,
  }) async {
    final RestResponse response = await _client.get(
      path: '/news',
      queryParameters: <String, Object?>{'limit': 12, 'cursor_string': ?cursor},
      options: options,
    );
    if (response.statusCode != 200) {
      throw NewsRemoteException(response.statusCode);
    }
    return response.payload.asMap();
  }

  @override
  Future<Map<String, dynamic>> article(
    NewsArticleParams params, {
    required RestClientOptions options,
  }) async {
    final RestResponse response = await _client.get(
      path: '/news/${params.id}',
      queryParameters: <String, Object?>{'key': 'id'},
      options: options,
    );
    if (response.statusCode != 200) {
      throw NewsRemoteException(response.statusCode);
    }
    return response.payload.asMap();
  }
}

final class NewsRemoteException implements Exception {
  const NewsRemoteException(this.statusCode);
  final int statusCode;
}
