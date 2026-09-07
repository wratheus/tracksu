import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/l10n/localizations_context.dart';
import 'package:tracksu/src/beatmap/domain/repository.dart';
import 'package:tracksu_ui/tracksu_ui.dart';

final class BeatmapFailureView extends StatelessWidget {
  const BeatmapFailureView({
    required this.failure,
    required this.onRetry,
    super.key,
  });
  final BeatmapFailureKind failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => UiContentState.error(
    title: switch (failure) {
      BeatmapFailureKind.notFound => context.t.beatmapNotFound,
      BeatmapFailureKind.accessDenied => context.t.beatmapAccessDenied,
      BeatmapFailureKind.rateLimited => context.t.profileRateLimited,
      BeatmapFailureKind.connection => context.t.profileConnectionFailed,
      BeatmapFailureKind.invalidResponse => context.t.beatmapInvalidResponse,
      BeatmapFailureKind.unavailable => context.t.beatmapUnavailable,
    },
    actionLabel: context.t.retry,
    onAction: onRetry,
  );
}
