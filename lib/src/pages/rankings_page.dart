import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracksu/src/pages/home_page.dart';
import 'package:tracksu/src/pages/home_page_desktop.dart';

import '../pages/error_page.dart';
import '../pages/rankings_tab_page.dart';
import '../widgets/rankings_widgets/rankings_search_filters.dart';
import '../pages/cubit/rankings_cubit.dart';
import '../utils/color_contrasts.dart' as my_colors;
import '../widgets/rankings_widgets/rankings_widget.dart';

class RankingsPage extends StatelessWidget {
  final String? mode;
  const RankingsPage({Key? key, this.mode})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RankingsCubit(),
      child: new _RankingsPage(mode: mode),
    );
  }
}

class _RankingsPage extends StatelessWidget {
  final String? mode;
  const _RankingsPage({Key? key, this.mode})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RankingsCubit, RankingsState>(builder: (context, state){
      if(state is RankingsInitial){ // run Circular progress bar while rankings is loading
        context.read<RankingsCubit>().informInitial();
        context.read<RankingsCubit>().loadRankings(state.countryValue, state.filterValue, state.page, mode);
        return Scaffold(
            body: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.topRight,
                        colors: [my_colors.Palette.brown.withOpacity(0.65), my_colors.Palette.purple.withOpacity(0.65)])),
                child: Center(child: CircularProgressIndicator(),)),
            backgroundColor: my_colors.Palette.brown.shade100
        );
    };

      if(state is RankingsErrorState){ //// Throw error if state is RankingsError
        return ErrorPage(exceptionPageName: RankingsTabPage(), errorMessage: state.errorMessage);
      }
      if(state is RankingsLoadedState){ //// Reload rankings if state is RankingsReload (wheel page down)
        return RefreshIndicator(
          backgroundColor: my_colors.Palette.brown.shade100,
          child: Scaffold(
            backgroundColor: my_colors.Palette.brown.shade200,
            body: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.topRight,
                      colors: [my_colors.Palette.brown.withOpacity(0.65), my_colors.Palette.purple.withOpacity(0.65)])),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    RankingsSearchFiltersWidget(state.filterValue, mode, state.countryList, state.countryValue, state.page),
                    ListView.builder(
                      padding: EdgeInsets.all(0.0),
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: state.rankingsList.length,
                      itemBuilder: (context, index){
                      return InkWell(
                        onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => (Platform.isAndroid || Platform.isIOS == true) ? HomePage(pageIndex: 1, username: state.rankingsList[index].username) : HomePageDesktop(pageIndex: 1, username: state.rankingsList[index].username))),
                        child: RankingsWidget(item: state.rankingsList[index])
                    );}
                  ),
                  ],
                ),
              ),
            ),
          ),
          onRefresh: () => context.read<RankingsCubit>().reloadRankings(state.filterValue, state.page, mode!, state.countryValue),
        );
      }
      return Container();
    });
  }
}

