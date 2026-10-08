import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/wiki/bloc/wiki_article_bloc.dart';
import 'package:tracksu/src/wiki/data/wiki_repository.dart';
import 'package:tracksu/src/wiki/domain/wiki.dart';
import 'package:tracksu/src/wiki/widgets/wiki_screen.dart';

/// One osu! wiki article page (P52).
final class WikiMain extends StatelessWidget {
  const WikiMain({required this.params, super.key});
  final WikiParams params;

  @override
  Widget build(BuildContext context) => BlocProvider<WikiArticleBloc>(
    create: (_) => WikiArticleBloc(
      repository: WikiRepository(
        restClient: DepsScope.of(context).publicRestClient,
      ),
      cache: DepsScope.of(context).pageCache,
      params: params,
      appLocale: () =>
          DepsScope.of(context).localeController.effectiveLanguageCode,
    )..add(const WikiArticleRequested()),
    child: const WikiScreen(),
  );
}
