import 'package:package_info_plus/package_info_plus.dart';
import 'package:tracksu/src/about/domain/build_info.dart';

Future<AppBuildInfo> readBuildInfo() async {
  final PackageInfo info = await PackageInfo.fromPlatform().timeout(
    const Duration(seconds: 5),
  );
  if (info.version.isEmpty ||
      info.buildNumber.isEmpty ||
      info.packageName.isEmpty) {
    throw const FormatException('Incomplete installed package metadata.');
  }
  return AppBuildInfo(
    version: info.version,
    buildNumber: info.buildNumber,
    packageName: info.packageName,
  );
}
