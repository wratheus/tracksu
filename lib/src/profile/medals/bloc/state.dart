part of 'bloc.dart';

sealed class MedalsState {
  const MedalsState();
}

final class MedalsLoading extends MedalsState {
  const MedalsLoading();
}

final class MedalsError extends MedalsState {
  const MedalsError();
}

final class MedalsLoaded extends MedalsState {
  const MedalsLoaded(
    this.medals, {
    this.refreshing = false,
    this.refreshFailed = false,
  });
  final List<EarnedMedal> medals;
  final bool refreshing;
  final bool refreshFailed;
}
