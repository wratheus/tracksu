import 'package:flutter/material.dart';

import '../pages/home_page.dart';
import '../utils/color_contrasts.dart' as my_colors;

// ignore: must_be_immutable
class ErrorDialogBox extends StatelessWidget {
  String _errorMessage;
  final Widget _exceptionPageName;
  ErrorDialogBox({Key? key, required Widget exceptionPageName, required String errorMessage}):
        _exceptionPageName = exceptionPageName,
        _errorMessage = errorMessage,
        super(key: key);
  @override
  Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor:my_colors.Palette.brown.shade100,
        body: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.topRight,
                  colors: [my_colors.Palette.brown.withOpacity(0.65), my_colors.Palette.purple.withOpacity(0.65)])),
          child: AlertDialog(
            elevation: 24,
            backgroundColor:my_colors.Palette.purple,
              title: Text(_errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Exo 2',
                  shadows: [
                    Shadow(
                      color: my_colors.Palette.hotPink.shade900.withOpacity(0.25),
                      offset: Offset(7, 5),
                      blurRadius: 10,
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => toPreviousPage(context),
                  child: Text("OK", style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Exo 2',
                    shadows: [
                      Shadow(
                          color: my_colors.Palette.hotPink.shade900.withOpacity(0.25),
                          offset: Offset(7, 5),
                          blurRadius: 10
                        )
                      ]
                    )
                  ),
                  style: ButtonStyle(
                    alignment: Alignment.center,
                    backgroundColor: MaterialStateProperty.all<Color>(my_colors.Palette.pink.shade100),
                    elevation: MaterialStateProperty.all<double>(20.0),
                  ),
                ),
              ],
          ),
        ),
      );
    }
  toPreviousPage(context) {

    if (_exceptionPageName == "LastNewsPage"){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage(pageIndex: 0)));
    }
    if (_exceptionPageName == "UserTabPage"){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage(pageIndex: 1)));
    }
    if (_exceptionPageName == "RankingsTabPage"){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage(pageIndex: 2)));
    }
    else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage(pageIndex: 1,)));
    }
  }
}

