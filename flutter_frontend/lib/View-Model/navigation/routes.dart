import 'package:flutter/material.dart';
import 'package:flutter_frontend/View/Screens/login_page.dart';
import 'package:flutter_frontend/View/Screens/registration_page.dart';
import 'package:go_router/go_router.dart';

class Routes {
  static GoRouter routeMaker(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    return GoRouter(
      initialLocation: '/login',
      redirect: (context, state) {},
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

        // GoRoute(path: '/forgot-password'),
        // GoRoute(path: '/verify_email'),
        // GoRoute(path: '/student-dashboard'),
        // GoRoute(path: '/landlord-dashboard'),
        // GoRoute(path: '/admin-dashboard')
      ],
    );
  }
}
