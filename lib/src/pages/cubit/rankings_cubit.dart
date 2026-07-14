import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import '../../models/country.dart';
import '../../requests/requests.dart';
import '../../utils/secure_storage.dart';
import '../../models/rankings.dart';

part 'rankings_state.dart';

class RankingsCubit extends Cubit<RankingsState> {
  RankingsCubit() : super(RankingsInitial("all", "1", null));

  Future<void> informInitial() async {
    print('RankingsPage loading');
  }

  Future<void> loadRankings(Country? countryValue, String filterValue, String page, String? mode) async {
    try {
      if (isClosed == false) {
        emit(RankingsLoadedState(
            await getRankings((await UserSecureStorage.getTokenFromStorage())!, filterValue, page, mode, countryValue),
            filterValue,
            page,
            countryValue,
            await generateCountriesList())
        );
      }
      print('Rankings loaded');
    } catch (e) {
      if (isClosed == false) {
        emit(RankingsErrorState('Failed Rankings Load $e'));
      }
    }
  }

  Future<void> reloadRankings(String filterFriendsValue, page, String mode, Country? country) async {
    if (isClosed == false) {
      emit(RankingsInitial(filterFriendsValue, page, country));
    }
  }

}