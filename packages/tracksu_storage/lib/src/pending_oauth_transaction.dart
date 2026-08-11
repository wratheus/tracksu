final class PendingOAuthTransaction {
  const PendingOAuthTransaction({required this.state, required this.startedAt});

  final String state;
  final DateTime startedAt;
}
