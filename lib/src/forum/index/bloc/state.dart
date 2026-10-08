part of 'bloc.dart';

/// [forums] stays visible while a refresh runs or after it fails.
final class ForumIndexState {
  const ForumIndexState({this.forums, this.loading = false, this.failure});
  final List<ForumNode>? forums;
  final bool loading;
  final ForumFailureKind? failure;
}
