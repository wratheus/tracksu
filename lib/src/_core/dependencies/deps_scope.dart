import 'package:flutter/widgets.dart';
import 'package:tracksu/src/_core/dependencies/deps_container.dart';

final class DepsScope extends InheritedWidget {
  const DepsScope({
    required this.dependencies,
    required super.child,
    super.key,
  });

  final DepsContainer dependencies;

  static DepsContainer of(BuildContext context) {
    final DepsScope? scope = context
        .dependOnInheritedWidgetOfExactType<DepsScope>();

    if (scope == null) {
      throw StateError('DepsScope is not available in this BuildContext.');
    }

    return scope.dependencies;
  }

  @override
  bool updateShouldNotify(DepsScope oldWidget) => false;
}
