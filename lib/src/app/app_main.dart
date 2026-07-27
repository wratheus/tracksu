import 'package:flutter/material.dart';
import 'package:tracksu/src/_core/dependencies/deps_container.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/utils/color_contrasts.dart' as colors;

final class AppMain extends StatelessWidget {
  const AppMain({required this.dependencies, super.key});

  final DepsContainer dependencies;

  @override
  Widget build(BuildContext context) {
    return DepsScope(
      dependencies: dependencies,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Tracksu',
        theme: ThemeData(
          primarySwatch: colors.Palette.pink,
          scaffoldBackgroundColor: colors.Palette.brown,
        ),
        initialRoute: dependencies.appRouter.initialRoute,
        onGenerateRoute: dependencies.appRouter.onGenerateRoute,
      ),
    );
  }
}
