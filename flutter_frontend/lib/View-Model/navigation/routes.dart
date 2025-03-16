import 'package:flutter/material.dart';
import 'package:flutter_frontend/View/Screens/demo_page.dart';
import 'package:flutter_frontend/View/Screens/login_page.dart';
import 'package:flutter_frontend/View/Screens/registration_page.dart';
import 'package:go_router/go_router.dart';

import '../../constants.dart';


///what if we move routes to main.dart
class Routes {
   Routes({
    required this.changeTheme,
    required this.changeColor,
    required this.colorSelected,
  });

  final ColorSelection colorSelected;
  final void Function(bool useLightMode) changeTheme;
  final void Function(int value) changeColor;




   GoRouter routeMaker(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    return GoRouter(
      initialLocation: '/login',
      redirect:  _appRedirect,

      routes: [
        GoRoute(
            builder: (context, state) {
              return LayoutBuilder(builder: (context, constraints) {
                if (constraints.maxWidth > 800) {
                  loggedIn=true;
                  return LoginPage(
                    width: deviceWidth / 2,
                  );
                } else {
                  loggedIn=true;
                  return LoginPage(
                    width: deviceWidth / 1.1,
                  );
                }
              });
            },
            path: '/login'),
        GoRoute(
            builder: (context, state) {
              return LayoutBuilder(builder: (context, constraints) {
                if (constraints.maxWidth > 800) {
                  return RegistrationPage(
                    width: deviceWidth / 2,
                  );
                } else {
                  return RegistrationPage(
                    width: deviceWidth / 1.1,
                  );
                }
              });
            },
            path: '/registration'),

        // GoRoute(path: '/forgot-password'),
        // GoRoute(path: '/verify_email'),
        // GoRoute(path: '/student-dashboard'),
        // GoRoute(path: '/landlord-dashboard'),
        // GoRoute(path: '/admin-dashboard')
         GoRoute(
           path: "/demo",
           builder: (context, state) => DashboardScreen(changeTheme: changeTheme, changeColor: changeColor, colorSelected: colorSelected),

         )
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
}
bool loggedIn=false;

Future<String?> _appRedirect(
    BuildContext context, GoRouterState state) async {
  // to be implemented
  if(!loggedIn){
    return '/login';
  }else{
    return '/demo';
  }
    }

