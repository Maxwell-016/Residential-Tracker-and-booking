import 'package:flutter/material.dart';
import 'package:flutter_frontend/View/Screens/Admin/admin_dash.dart';
import 'package:flutter_frontend/View/Screens/Landlord/add_house.dart';
import 'package:flutter_frontend/View/Screens/Landlord/landloard_dash.dart';
import 'package:flutter_frontend/View/Screens/Common/email_verification_page.dart';
import 'package:flutter_frontend/View/Screens/Common/forgot_password.dart';
import 'package:flutter_frontend/View/Screens/Common/login_page.dart';
import 'package:flutter_frontend/View/Screens/Common/registration_page.dart';
import 'package:flutter_frontend/View/Screens/Landlord/manage_house_listings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../View/Screens/Student/student_dash.dart';
import '../../constants.dart';

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
        GoRoute(builder: (context, state) => LoginPage(), path: '/login'),
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
          path: '/landlord-dashboard',
        ),
        GoRoute(
            builder: (context, state) {
              return ManageHouseListings();
            },
            path: '/manageListings',
            routes: [
              GoRoute(
                path: 'add-house',
                builder: (context, state) => AddHouse(width: deviceWidth / 2),
              )
            ]),
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
}
