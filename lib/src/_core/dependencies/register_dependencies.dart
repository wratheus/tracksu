import 'package:tracksu/src/_core/dependencies/deps_container.dart';
import 'package:tracksu/src/_core/router/app_router.dart';

Future<DepsContainer> registerDependencies() {
  return Future<DepsContainer>.value(
    const DepsContainer(appRouter: TracksuAppRouter()),
  );
}
