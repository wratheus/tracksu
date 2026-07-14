import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../pages/user_tab_page.dart';
import '../pages/cubit/user_cubit.dart';
import '../utils/color_contrasts.dart' as my_colors;
import '../pages/error_page.dart';
import '../widgets/user_widgets/user_widget.dart';
import '../widgets/user_widgets/user_list_tile_elements.dart';

class UserPage extends StatelessWidget {
  final username;
  final String? mode;
  const UserPage({Key? key, this.username, this.mode})
      :super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UserCubit(),
      child: new _UserPage(username: username, mode: mode));
  }
}

class _UserPage extends StatelessWidget {
  final username;
  final String? mode;
  const _UserPage({Key? key, this.username, this.mode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
  return BlocBuilder<UserCubit, UserState>(builder: (context, state) {
      if (state is UserInitial) {
        if (username != null) {
          context.read<UserCubit>().loadUser(username!, mode!);
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.topRight,
                      colors: [my_colors.Palette.brown.withOpacity(0.65), my_colors.Palette.purple.withOpacity(0.65)])),
              child: Center(
                  child: CircularProgressIndicator()),
            ),
            backgroundColor: my_colors.Palette.brown.shade100,
          );
        }
        else {
          context.read<UserCubit>().loadUserMe(mode!);
          return RefreshIndicator(child:
            Scaffold(
              body: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.topRight,
                        colors: [my_colors.Palette.brown.withOpacity(0.65), my_colors.Palette.purple.withOpacity(0.65)])),
                child: Center(
                    child: CircularProgressIndicator()),
              ),
              backgroundColor: my_colors.Palette.brown.shade100,
            ),
            onRefresh: () => context.read<UserCubit>().reloadUser(),
          );
        }
      }
      if (state is UserErrorState) { // Throw error if state is UserError
        return ErrorPage(
            exceptionPageName: UserTabPage(), errorMessage: state.errorMessage);
      }
      if (state is UserLoadingState) {
        print("Loading User");
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.topRight,
                    colors: [my_colors.Palette.brown.withOpacity(0.65), my_colors.Palette.purple.withOpacity(0.65)])),
            child: Center(
                child: CircularProgressIndicator()),
          ),
          backgroundColor: my_colors.Palette.brown.shade100,
        );
      }
      if (state is UserLoadedState) {// Reload News if state is UserReload (wheel page down)
        print("${state.userInstance.username} is loaded");
        return DefaultTabController(
          length: 4,
          child: RefreshIndicator(
            backgroundColor: my_colors.Palette.brown.shade100,
            child:
            Scaffold(
              backgroundColor: my_colors.Palette.brown.shade100,
              body: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.topRight,
                        colors: [my_colors.Palette.brown.withOpacity(0.65), my_colors.Palette.purple.withOpacity(0.65)])),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      UserInfoWidget(user: state.userInstance),
                      UserListTilesElements(userInstance: state.userInstance, mode: mode!),
                    ],
                  ),
                ),
              ),
            ),
            onRefresh: () => context.read<UserCubit>().reloadUser(),
          ),
        );
      }
      else
        return Container();
    }
    );
  }
}