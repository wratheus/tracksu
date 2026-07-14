import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tracksu/src/pages/home_page_desktop.dart';
import '../../pages/home_page.dart';
import '../../utils/color_contrasts.dart' as my_colors;

class UserSearchWidget extends StatelessWidget {

  final textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery
        .of(context)
        .size
        .height;
    final double width = MediaQuery
        .of(context)
        .size
        .width;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: width/1.99,
          height: height/20,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [my_colors.Palette.brown.shade100.withOpacity(0.6), my_colors.Palette.brown.shade200.withOpacity(0.6)]),
        ),
          child: TextField(
            textAlign: TextAlign.left,
            textAlignVertical: TextAlignVertical.bottom,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: my_colors.Palette.brown.shade200.withOpacity(0.3)),

              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: my_colors.Palette.brown.shade200.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: my_colors.Palette.brown.shade200.withOpacity(0.3)),
              ),
              labelText: "Search",
              labelStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Exo 2',
                  color: Colors.white),
              prefixIcon: Image.asset('assets/utils/search.png', scale: 4,),
              hintText: "Enter username",
              hintStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Exo 2',
                  color: Colors.white54),
            ),
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                fontFamily: 'Exo 2',
                color: Colors.white),
            keyboardType: TextInputType.text,
            controller: textController,
            // onSubmitted: (_) => context.read<UserCubit>().loadUser(textController.text, 'osu'),
            onSubmitted: (_) => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => (Platform.isAndroid || Platform.isIOS == true) ? HomePage(pageIndex: 1, username: textController.text.trim()) : HomePageDesktop(pageIndex: 1, username: textController.text.trim()))),
          )
      )
    ]
    );
  }
}
