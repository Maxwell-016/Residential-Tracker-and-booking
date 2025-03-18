import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend/View-Model/navigation/routes.dart';
import 'package:flutter_frontend/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'View-Model/view_model.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

// error handling
  try{
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
  );
  } catch(e){
    print('Firebase initialisation error: $e');
  }


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

class ResidentialTrackerAndBooking extends ConsumerStatefulWidget {
  const ResidentialTrackerAndBooking({super.key});

  @override
  ConsumerState<ResidentialTrackerAndBooking> createState()=>_StateResidentialTrackerAndBooking();

}

class _StateResidentialTrackerAndBooking extends   ConsumerState<ResidentialTrackerAndBooking>{


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


  // Future<String?> _appRedirect(
  //     BuildContext context, GoRouterState state) async {
  //   final userDao = ref.watch(userDaoProvider);
  //   final loggedIn=userDao.isLoggedIn();
  //
  //
  //   // final loggedIn = await _auth.loggedIn;
  //   final isOnLoginPage = state.matchedLocation == '/login';
  //
  //
  //
  //   // Go to /login if the user is not signed in
  //   if (!loggedIn) {
  //     return '/login';
  //   }
  //
  //
  //   else if (loggedIn && isOnLoginPage) {
  //     return '/studentdashboard';
  //
  //   }
  //
  //   // no redirect
  //   return null;
  //
  //
  // }


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
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

      routerConfig: Routes.routeMaker(context),
      title: "Residential Tracker and Booking",
    );
  }
}
