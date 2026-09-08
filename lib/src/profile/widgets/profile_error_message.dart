import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/profile/bloc/bloc.dart';
import 'package:tracksu/src/profile/domain/profile_failure.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

final class ProfileErrorMessage extends StatelessWidget {
  const ProfileErrorMessage({
    required this.failure,
    this.refreshing = false,
    this.onRetry,
    super.key,
  });
  final ProfileFailureKind failure;
  final bool refreshing;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => UiContentState.error(
    title: switch (failure) {
      ProfileFailureKind.notFound => context.t.profileNotFound,
      ProfileFailureKind.accessDenied => context.t.profileAccessDenied,
      ProfileFailureKind.rateLimited => context.t.profileRateLimited,
      ProfileFailureKind.connection => context.t.profileConnectionFailed,
      ProfileFailureKind.invalidResponse => context.t.profileInvalidResponse,
      ProfileFailureKind.unavailable => context.t.profileUnavailable,
    },
    message: refreshing ? context.t.profileShowingPreviousData : null,
    actionLabel: context.t.retry,
    onAction:
        onRetry ??
        () => context.read<ProfileBloc>().add(const ProfileRefreshRequested()),
  );
}
