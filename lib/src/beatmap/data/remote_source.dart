import 'package:tracksu_network/tracksu_network.dart';

final class BeatmapRemoteSource {
  factory BeatmapRemoteSource({required RestClient restClient}) =>
      BeatmapRemoteSource._(restClient);
  const BeatmapRemoteSource._(this._restClient);
  final RestClient _restClient;

  Future<Map<String, dynamic>> loadDifficulty(
    int id,
    RestClientOptions options,
  ) => _get('/beatmaps/$id', options);
  Future<Map<String, dynamic>> loadSet(int id, RestClientOptions options) =>
      _get('/beatmapsets/$id', options);

  Future<Map<String, dynamic>> _get(
    String path,
    RestClientOptions options,
  ) async {
    final RestResponse response = await _restClient.get(
      path: path,
      options: options,
    );
    if (response.statusCode != 200) {
      throw BeatmapRemoteException(response.statusCode);
    }
    return response.payload.asMap();
  }
}

final class BeatmapRemoteException implements Exception {
  const BeatmapRemoteException(this.statusCode);
  final int statusCode;
}
