import 'package:tracksu/src/auth/data/oauth_client_credentials.dart';
import 'package:tracksu/src/authentication.dart' as localAuthentication;

final class LocalOsuOAuthClientCredentials implements OAuthClientCredentials {
  const LocalOsuOAuthClientCredentials();

  @override
  String get clientId => localAuthentication.clientId.toString();

  @override
  String get clientSecret => localAuthentication.clientSecret;
}
