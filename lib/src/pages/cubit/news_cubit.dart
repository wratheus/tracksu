import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../requests/requests.dart';
import '../../utils/secure_storage.dart';
import '../../models/news.dart';

part 'news_state.dart';

class NewsCubit extends Cubit<NewsState> {
  NewsCubit() : super(NewsInitial());

  Future<void> informInitial() async {
    print('NewsPage loading');
  }

  Future<void> loadNews() async {
    try{
      if (isClosed == false) {
        emit(NewsLoadedState(await getNews((await UserSecureStorage
            .getTokenFromStorage())!)));
      } // request news
      print('News loaded');
    }catch (e){
      if (isClosed == false) {
        emit(NewsErrorState('Failed News Load $e'));
      }
    }
  }

  Future<void> reloadNews() async {
    if (isClosed == false) {
      emit(NewsInitial());
    }
  }

}
