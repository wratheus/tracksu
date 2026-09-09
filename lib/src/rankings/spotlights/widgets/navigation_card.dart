import 'package:flutter/material.dart';

/// Keeps duplicate-navigation state on the tapped card, not on the whole list.
final class SpotlightNavigationCard extends StatefulWidget {
  const SpotlightNavigationCard({
    required this.onOpen,
    required this.builder,
    super.key,
  });
  final Future<void> Function() onOpen;
  final Widget Function(VoidCallback? onTap) builder;
  @override
  State<SpotlightNavigationCard> createState() =>
      _SpotlightNavigationCardState();
}

final class _SpotlightNavigationCardState
    extends State<SpotlightNavigationCard> {
  bool _opening = false;
  Future<void> _open() async {
    if (_opening) return;
    setState(() => _opening = true);
    try {
      await widget.onOpen();
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) => widget.builder(_opening ? null : _open);
}
