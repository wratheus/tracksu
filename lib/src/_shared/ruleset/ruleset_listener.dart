import 'package:flutter/widgets.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/_shared/ruleset/ruleset_controller.dart';
import 'package:tracksu/src/profile/domain/profile_ruleset.dart';

/// Calls [onChanged] when the app-wide game mode changes (not on first
/// build: the page's Bloc already starts in it).
final class RulesetListener extends StatefulWidget {
  const RulesetListener({
    required this.onChanged,
    required this.child,
    super.key,
  });
  final ValueChanged<ProfileRuleset> onChanged;
  final Widget child;

  @override
  State<RulesetListener> createState() => _RulesetListenerState();
}

final class _RulesetListenerState extends State<RulesetListener> {
  RulesetController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final RulesetController controller = DepsScope.of(context)
        .rulesetController;
    if (identical(controller, _controller)) return;
    _controller?.removeListener(_changed);
    _controller = controller..addListener(_changed);
  }

  void _changed() => widget.onChanged(_controller!.value);

  @override
  void dispose() {
    _controller?.removeListener(_changed);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
