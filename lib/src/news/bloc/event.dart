part of 'bloc.dart';

sealed class NewsEvent {
  const NewsEvent();
}

final class NewsStarted extends NewsEvent {
  const NewsStarted();
}

final class NewsRefreshRequested extends NewsEvent {
  const NewsRefreshRequested();
}

final class NewsMoreRequested extends NewsEvent {
  const NewsMoreRequested();
}
