import 'package:package_info_plus/package_info_plus.dart';
import 'package:tracksu/src/_core/config/pubspec.yaml.g.dart';
import 'package:tracksu/src/about/domain/build_info.dart';

Future<AppBuildInfo> readBuildInfo() async {
  final PackageInfo info = await PackageInfo.fromPlatform().timeout(
    const Duration(seconds: 5),
  );
  if (info.packageName.isEmpty) {
    throw const FormatException('Incomplete installed package metadata.');
  }
  return AppBuildInfo(
    version: Pubspec.version.canonical.split('+').first,
    buildNumber: Pubspec.version.build.join('.'),
    packageName: info.packageName,
  );
}
