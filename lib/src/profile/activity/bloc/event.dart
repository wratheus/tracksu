part of 'bloc.dart';

sealed class ProfileActivityEvent {
  const ProfileActivityEvent();
}

final class ProfileActivityStarted extends ProfileActivityEvent {
  const ProfileActivityStarted();
}

final class ProfileActivityRefreshRequested extends ProfileActivityEvent {
  const ProfileActivityRefreshRequested();
}

final class ProfileActivityMoreRequested extends ProfileActivityEvent {
  const ProfileActivityMoreRequested();
}
