import 'package:tracksu/src/auth/data/oauth_tokens_dto.dart';

abstract interface class OAuthRemoteSource {
  Future<OAuthTokensDto> exchangeAuthorizationCode({required String code});
}
