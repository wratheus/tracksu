import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import '../../requests/requests.dart';
import '../../utils/secure_storage.dart';
import '../../models/user.dart';
import '../beatmap_page.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {

  UserCubit() : super(UserInitial());

  Future<void> informInitial() async {
    print('UserPage loaded');
  }

  Future<void> loadUser(String username, mode) async {
    try {
      if (isClosed == false) {
        emit(UserLoadingState());
      }
      final user = await getUser((await UserSecureStorage.getTokenFromStorage())!, username, mode);
      if (isClosed == false) {
        emit(UserLoadedState(user));
      }
      print('User $username loaded');
    } catch (e){
      if (isClosed == false) {
        emit(UserErrorState('Failed User Load $e'));
      }
    }
  }

  Future<void> loadUserMe([String mode="osu!"]) async {
    try {
      if (isClosed == false) {
        emit(UserLoadingState());
      }
      final user = await getUserMe(
          (await UserSecureStorage.getTokenFromStorage())!, mode);
      if (isClosed == false) {
        emit(UserLoadedState(user));
      }
      print('User ME(${user.username}) loaded');
    } catch (e) {
      if (isClosed == false) {
        emit(UserLoadingState());
      }
      final user = await getUser(
          (await UserSecureStorage.getTokenFromStorage())!, "Peppy", mode);
      if (isClosed == false) {
        emit(UserLoadedState(user));
      }
      print('User ME(${user.username}) loaded');
    }
  }

  Future<void> reloadUser() async {
    if (isClosed == false) {
      emit(UserInitial());
    }
  }
 // item is Score type or Beatmap
  Future<void> loadBeatmapFromUser(Object item, BuildContext context) async {
    print(item);
    Navigator.pushReplacement(context,
        MaterialPageRoute(
            builder: (context) => BeatmapPage(item: item)));
  }
}