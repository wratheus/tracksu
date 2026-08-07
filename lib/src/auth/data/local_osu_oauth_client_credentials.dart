import 'package:tracksu/src/auth/data/oauth_client_credentials.dart';
import 'package:tracksu/src/_core/config/app_environment.dart';

final class LocalOsuOAuthClientCredentials implements OAuthClientCredentials {
  const LocalOsuOAuthClientCredentials();

  @override
  String get clientId => AppEnvironment.osuClientId;

  @override
  String get clientSecret => AppEnvironment.osuClientSecret;
}
