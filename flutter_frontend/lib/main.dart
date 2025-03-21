import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend/View-Model/navigation/routes.dart';
import 'package:flutter_frontend/constants.dart';
import 'package:flutter_frontend/services/firebase_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'View-Model/view_model.dart';
import 'View/Screens/Admin/admin_dash.dart';
import 'View/Screens/Common/email_verification_page.dart';
import 'View/Screens/Common/forgot_password.dart';
import 'View/Screens/Common/login_page.dart';
import 'View/Screens/Common/registration_page.dart';
import 'View/Screens/Landlord/landloard_dash.dart';
import 'View/Screens/Landlord/manage_house_listings.dart';
import 'View/Screens/Student/student_dash.dart';
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







   GoRouter routeMaker(BuildContext context) {
     double deviceWidth = MediaQuery
         .of(context)
         .size
         .width;
     return GoRouter(
       initialLocation: '/login',
       redirect: _appRedirect,

       routes: [
         GoRoute(
             builder: (context, state) => LoginPage(),
             path: '/login'),
         GoRoute(
             builder: (context, state) => RegistrationPage(),
             path: '/registration'),

         GoRoute(
             builder: (context, state) {
               return LayoutBuilder(builder: (context, constraints) {
                 if (constraints.maxWidth > 800) {
                   return ForgotPassword(
                     width: deviceWidth / 2,
                   );
                 } else {
                   return ForgotPassword(
                     width: deviceWidth / 1.1,
                   );
                 }
               });
             },
             path: '/forgot-password'),
         GoRoute(
             builder: (context, state) {
               return LayoutBuilder(builder: (context, constraints) {
                 if (constraints.maxWidth > 800) {
                   return EmailVerificationPage(
                     width: deviceWidth / 2,
                   );
                 } else {
                   return EmailVerificationPage(
                     width: deviceWidth / 1.1,
                   );
                 }
               });
             },
             path: '/verification'),
         GoRoute(
             builder: (context, state) {
               return StudentDashboardScreen();
             },
             path: '/student-dashboard'),
         GoRoute(
             builder: (context, state) {
               return LandLoardDashboardScreen();
             },
             path: '/landlord-dashboard'),
         GoRoute(
             builder: (context, state) {
               return ManageHouseListings();
             },
             path: '/manageListings'),


         GoRoute(
             builder: (context, state) {
               return AdminDashboardScreen();
             },
             path: '/admin-dashboard')
       ],
       errorPageBuilder: (context, state) {
         return MaterialPage(
           key: state.pageKey,
           child: Scaffold(
             body: Center(
               child: Text("404 error:${state.error}"),
             ),
           ),
         );
       },
     );
   }

  Future<String?> _appRedirect(
      BuildContext context, GoRouterState state) async {
    final fb = ref.watch(firebaseServices);
    final loggedIn = fb.loggedIn();


    // final loggedIn = await _auth.loggedIn;
    final isOnLoginPage = state.matchedLocation == '/login';


    // Go to /login if the user is not signed in
    if (!loggedIn) {
      return '/login';
    }

    else if (loggedIn && isOnLoginPage) {
      String? role = await fb.getUserRole();
      if (role != null) {
        switch (role) {
          case 'Student':
            return '/student-dashboard';
          case 'Landlord':
            return '/landlord-dashboard';
          case 'Admin':
            return '/admin-dashboard';
        }
      }
      else {
        return '/login';
      }
    }
      // no redirect
      return null;

  }






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

      routerConfig: routeMaker(context),





      title: "Residential Tracker and Booking",
    );
  }
}


