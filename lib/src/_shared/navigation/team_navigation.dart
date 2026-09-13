import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';

/// Navigation stays outside display-only player/flag compositions.
final class TeamNavigation extends StatefulWidget {
  const TeamNavigation({
    required this.teamId,
    required this.builder,
    super.key,
  });
  final int? teamId;
  final Widget Function(VoidCallback? openTeam) builder;
  @override
  State<TeamNavigation> createState() => _TeamNavigationState();
}

final class _TeamNavigationState extends State<TeamNavigation> {
  bool _opening = false;
  Future<void> _open() async {
    final int? id = widget.teamId;
    if (_opening || id == null) return;
    setState(() => _opening = true);
    try {
      await DepsScope.of(context).appRouter.openTeam(context, id);
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(widget.teamId == null || _opening ? null : _open);
}
