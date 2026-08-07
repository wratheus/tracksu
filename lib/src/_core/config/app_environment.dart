import 'package:envied/envied.dart';

part 'app_environment.g.dart';

@Envied(path: '.env')
abstract final class AppEnvironment {
  @EnviedField(varName: 'OSU_CLIENT_ID', obfuscate: true)
  static final String osuClientId = _AppEnvironment.osuClientId;

  @EnviedField(varName: 'OSU_CLIENT_SECRET', obfuscate: true)
  static final String osuClientSecret = _AppEnvironment.osuClientSecret;
}
