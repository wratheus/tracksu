import 'package:tracksu/src/auth/data/oauth_remote_source_exception.dart';
import 'package:tracksu/src/changelog/data/dto.dart';
import 'package:tracksu/src/changelog/data/remote_source.dart';
import 'package:tracksu/src/changelog/domain/changelog.dart';
import 'package:tracksu_network/tracksu_network.dart';

/// One instance per changelog page; a newer read cancels the previous one.
final class ChangelogRepositoryImpl implements ChangelogRepository {
  ChangelogRepositoryImpl({required this._remoteSource});
  final ChangelogRemoteSource _remoteSource;
  RestCancellationToken? _pending;

  @override
  void cancelPending() {
    _pending?.cancel();
    _pending = null;
  }

  @override
  Future<ChangelogPage> load(ChangelogQuery query) async {
    cancelPending();
    final RestCancellationToken token = RestCancellationToken();
    _pending = token;
    try {
      final Map<String, dynamic> json = await _remoteSource.load(
        query,
        options: RestClientOptions(cancellationToken: token),
      );
      if (token.isCancelled) {
        throw const ChangelogFailure(ChangelogFailureKind.cancelled);
      }
      return ChangelogDto.page(json);
    } on ChangelogRemoteException catch (error, stackTrace) {
      Error.throwWithStackTrace(_statusFailure(error.statusCode), stackTrace);
    } on OAuthRemoteSourceException catch (error, stackTrace) {
      Error.throwWithStackTrace(_statusFailure(error.statusCode), stackTrace);
    } on FormatException catch (_, stackTrace) {
      Error.throwWithStackTrace(
        const ChangelogFailure(ChangelogFailureKind.invalidResponse),
        stackTrace,
      );
    } on RestRequestCancelledException catch (_, stackTrace) {
      Error.throwWithStackTrace(
        const ChangelogFailure(ChangelogFailureKind.cancelled),
        stackTrace,
      );
    } on RestClientException catch (_, stackTrace) {
      Error.throwWithStackTrace(
        const ChangelogFailure(ChangelogFailureKind.connection),
        stackTrace,
      );
    } finally {
      if (identical(_pending, token)) _pending = null;
    }
  }

  ChangelogFailure _statusFailure(int status) => ChangelogFailure(
    status == 429
        ? ChangelogFailureKind.rateLimited
        : ChangelogFailureKind.unavailable,
  );
}
