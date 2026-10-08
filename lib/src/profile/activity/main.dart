import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/profile/activity/bloc/bloc.dart';
import 'package:tracksu/src/profile/activity/data/remote_source.dart';
import 'package:tracksu/src/profile/activity/data/repository_impl.dart';
import 'package:tracksu/src/profile/domain/profile_user_reference.dart';

/// Owns the Activity tab's Bloc for one player. Lazy: the feed loads when the
/// tab is first opened, unlike Results and Maps which are prefetched (P42).
final class ProfileActivityProvider extends StatelessWidget {
  const ProfileActivityProvider({
    required this.userId,
    required this.child,
    super.key,
  });
  final int userId;
  final Widget child;

  @override
  Widget build(BuildContext context) => BlocProvider<ProfileActivityBloc>(
    key: ValueKey<int>(userId),
    create: (_) => ProfileActivityBloc(
      cache: DepsScope.of(context).pageCache,
      repository: ProfileActivityRepositoryImpl(
        remoteSource: OsuProfileActivityRemoteSource(
          restClient: DepsScope.of(context).publicRestClient,
        ),
      ),
      user: ProfileUserId(userId),
    )..add(const ProfileActivityStarted()),
    child: child,
  );
}
