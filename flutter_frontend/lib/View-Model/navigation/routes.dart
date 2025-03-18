import 'package:flutter/material.dart';
import 'package:flutter_frontend/View/Screens/admin_dash.dart';
import 'package:flutter_frontend/View/Screens/landloard_dash.dart';
import 'package:flutter_frontend/View/Screens/email_verification_page.dart';
import 'package:flutter_frontend/View/Screens/forgot_password.dart';
import 'package:flutter_frontend/View/Screens/login_page.dart';
import 'package:flutter_frontend/View/Screens/registration_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../View/Screens/student_dash.dart';
import '../../constants.dart';

///what if we move routes to main.dart
class Routes {
  Routes({
    required this.changeTheme,
    required this.changeColor,
    required this.colorSelected,
    required this.appdirect,
  });

  final ColorSelection colorSelected;
  final void Function(bool useLightMode) changeTheme;
  final void Function(int value) changeColor;
  final Future<String?> Function(BuildContext, GoRouterState) appdirect;

  static GoRouter routeMaker(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    return GoRouter(
      initialLocation: '/login',
      // redirect:  ,

      routes: [
        GoRoute(
            builder: (context, state) {
              return LayoutBuilder(builder: (context, constraints) {
                if (constraints.maxWidth > 800) {
                  return LoginPage(
                    width: deviceWidth / 2,
                  );
                } else {
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
              return AdminDashboardScreen();
            },
            path: '/admin-dashboard')

        // GoRoute(
        //   path: "/landloaddashboard",
        //   builder: (context, state) => LandLoardDashboardScreen(changeTheme: changeTheme, changeColor: changeColor, colorSelected: colorSelected),
        //
        // ),
        // GoRoute(
        //   path: "/studentdashboard",
        //   builder: (context, state) => StudentDashboardScreen(changeTheme: changeTheme, changeColor: changeColor, colorSelected: colorSelected),
        //
        // ),
        // GoRoute(
        //   path: "/admin_dashboard",
        //   builder: (context, state) => AdminDashboardScreen(changeTheme: changeTheme, changeColor: changeColor, colorSelected: colorSelected),
        //
        // )
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
