part of 'bloc.dart';

sealed class MedalsEvent {
  const MedalsEvent();
}

final class MedalsLoadRequested extends MedalsEvent {
  const MedalsLoadRequested();
}
