import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/_core/dependencies/deps_scope.dart';
import 'package:tracksu/src/news/bloc/bloc.dart';
import 'package:tracksu/src/news/data/remote_source.dart';
import 'package:tracksu/src/news/data/repository_impl.dart';
import 'package:tracksu/src/news/domain/news.dart';
import 'package:tracksu/src/news/widgets/screen.dart';

final class NewsMain extends StatelessWidget {
  const NewsMain({this.params, super.key});
  final NewsArticleParams? params;
  @override
  Widget build(BuildContext context) => BlocProvider<NewsBloc>(
    create: (_) => NewsBloc(
      params: params,
      repository: NewsRepositoryImpl(
        remoteSource: OsuNewsRemoteSource(
          restClient: DepsScope.of(context).publicRestClient,
        ),
      ),
    )..add(const NewsStarted()),
    child: const NewsScreen(),
  );
}
