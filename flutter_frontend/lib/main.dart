import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend/View-Model/navigation/routes.dart';
import 'package:flutter_frontend/View-Model/utils/themes.dart';
import 'package:flutter_frontend/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  // WidgetsFlutterBinding.ensureInitialized();



  runApp(
      ProviderScope(
          child:  ResidentialTrackerAndBooking()));
}



class CustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad
  };
}

class ResidentialTrackerAndBooking extends StatefulWidget {
  const ResidentialTrackerAndBooking({super.key});

  @override
  State<StatefulWidget> createState()=>_StateResidentialTrackerAndBooking();

}

class _StateResidentialTrackerAndBooking extends   State<StatefulWidget>{


  ThemeMode themeMode =ThemeMode.light;
  ColorSelection colorSelectied=ColorSelection.blue;



//call this to change the theme of the app (dark or light)
  void changeThemeMode(bool useLightMode){
    setState(() {
      themeMode=useLightMode ?ThemeMode.light:ThemeMode.dark;
    });
  }

  //use it to change the color of the page /you can add any color in the constants.dart
  void changeColor(int value){
    setState(() {
      colorSelectied=ColorSelection.values[value];
    });
  }


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var routes =   Routes(changeTheme: changeThemeMode, changeColor: changeColor, colorSelected: colorSelectied);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      scrollBehavior: CustomScrollBehavior(),

      theme: ThemeData(
        colorSchemeSeed: colorSelectied.color,
        useMaterial3: true
      ),

      darkTheme: ThemeData(
        colorSchemeSeed: colorSelectied.color,
      useMaterial3: true,
      brightness: Brightness.dark
    ),

      routerConfig: routes.routeMaker(context),
      title: "Residential Tracker and Booking",
    );
  }
}
