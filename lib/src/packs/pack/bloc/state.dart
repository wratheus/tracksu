part of 'bloc.dart';

/// [pack] stays visible while a refresh runs or after it fails.
final class BeatmapPackState {
  const BeatmapPackState({this.pack, this.loading = false, this.failure});
  final BeatmapPack? pack;
  final bool loading;
  final BeatmapPacksFailureKind? failure;
}
