import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tracksu/src/pages/authorization_page.dart';
import 'package:tracksu/src/pages/home_page_desktop.dart';
import 'home_page.dart';

import '../models/user.dart';
import '../requests/requests.dart';
import '../utils/color_contrasts.dart' as my_colors;
import '../utils/secure_storage.dart';

// only login as guest supported now
class LoginPageWidget extends StatefulWidget {
  @override
  State<LoginPageWidget> createState() => _LoginPageWidget();
}

class _LoginPageWidget extends State<LoginPageWidget> {
  bool userPeppyLoaded = false;

  @override
  void initState() {
    super.initState();
  }

  void initLoginAsGuest() async {
    await getTokenAsGuestWithClientCredential();
    final User userMeInstance = await getUser(
        (await UserSecureStorage.getTokenFromStorage())!, "Peppy");
    await UserSecureStorage.setUserMeAvatarFromStorage(userMeInstance.avatarURL);
    await UserSecureStorage.setUserMeUsernameFromStorage(userMeInstance.username);
    setState((){
      userPeppyLoaded = true;
    });
    print("$userPeppyLoaded");
    if (await userPeppyLoaded == true) navigateToHomePage();
  }

  void navigateToHomePage() {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => (Platform.isAndroid || Platform.isIOS == true ) ? HomePage() : HomePageDesktop()));
  }
  void initLoginAsUser() {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: my_colors.Palette.brown,
      appBar: AppBar(
        flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.topRight,
                    colors: [my_colors.Palette.brown.withOpacity(0.6), my_colors.Palette.brown.shade400.withOpacity(0.6)]))),
        title: Text("Welcome to Tracksu!", style: TextStyle(
          fontSize: 22.0,
          color: Colors.white,
          fontFamily: 'Exo 2',
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: my_colors.Palette.hotPink.shade900.withOpacity(0.25),
              offset: Offset(7, 5),
              blurRadius: 10,
            )
          ],
        ),
        ),
        backgroundColor: my_colors.Palette.purple,
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.topRight,
                colors: [my_colors.Palette.brown.withOpacity(0.25), my_colors.Palette.purple.withOpacity(0.25)]),
            image: (Platform.isWindows == true)
                ? DecorationImage(image: AssetImage('assets/utils/transparent_trigen.png'),
                opacity: 1,
                fit: BoxFit.fill,
                scale: 1)
            : DecorationImage(
                image: AssetImage('assets/utils/transparent_trigen_phone.png'),
              opacity: 1,
              fit: BoxFit.fill,
              scale: 1
            )
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    width: 150,
                    height: 60,
                    child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(my_colors.Palette.purple)
                      ),
                      onPressed: initLoginAsUser,
                      child: Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Exo 2',
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: my_colors.Palette.hotPink.shade900.withOpacity(0.25),
                              blurRadius: 10,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15,),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaY: 15, sigmaX: 15),
                  child: Container(
                    width: 230,
                    height: 70,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(my_colors.Palette.purple)
                      ),
                      onPressed: initLoginAsGuest,
                      child: Text(
                        "Continue as guest",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Exo 2',
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: my_colors.Palette.hotPink.shade900.withOpacity(0.25),
                              blurRadius: 10,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
