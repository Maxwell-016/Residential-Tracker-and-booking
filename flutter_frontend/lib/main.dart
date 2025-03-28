import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend/View-Model/navigation/routes.dart';
import 'package:flutter_frontend/View/Screens/Landlord/view_and_update_listings.dart';
import 'package:flutter_frontend/constants.dart';
import 'package:flutter_frontend/services/firebase_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'View-Model/utils/savecurrentpage.dart';
import 'View-Model/view_model.dart';
import 'View/Screens/Admin/admin_dash.dart';
import 'View/Screens/Common/email_verification_page.dart';
import 'View/Screens/Common/forgot_password.dart';
import 'View/Screens/Common/login_page.dart';
import 'View/Screens/Common/registration_page.dart';
import 'View/Screens/Landlord/add_house.dart';
import 'View/Screens/Landlord/landloard_dash.dart';
import 'View/Screens/Landlord/manage_house_listings.dart';
import 'View/Screens/Student/student_dash.dart';
import 'firebase_options.dart';
import 'View/Screens/Admin/admin_settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

// error handling
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Firebase initialisation error: $e');
  }
  String initialRoute = await getLastVisitedPage();
  runApp(ProviderScope(
      child: ResidentialTrackerAndBooking(initialRoute: initialRoute)));
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
  final String initialRoute;
  const ResidentialTrackerAndBooking({super.key, required this.initialRoute});

  @override
  ConsumerState<ResidentialTrackerAndBooking> createState() =>
      _StateResidentialTrackerAndBooking();
}

class _StateResidentialTrackerAndBooking
    extends ConsumerState<ResidentialTrackerAndBooking> {
  ThemeMode themeMode = ThemeMode.light;
  ColorSelection colorSelected = ColorSelection.blue;

//call this to change the theme of the app (dark or light)
  void changeThemeMode(bool useLightMode) {
    setState(() {
      themeMode = useLightMode ? ThemeMode.light : ThemeMode.dark;
    });
  }

  //use it to change the color of the page /you can add any color in the constants.dart
  void changeColor(int value) {
    setState(() {
      colorSelected = ColorSelection.values[value];
    });
  }

  GoRouter routeMaker(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    return GoRouter(
      initialLocation: widget.initialRoute,
      routerNeglect: false,
      redirect: _appRedirect,
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
            path: '/landlord-dashboard'),
        GoRoute(
            builder: (context, state) {
              return ManageHouseListings();
            },
            path: '/manageListings',
            routes: [
              GoRoute(
                path: 'add-house',
                builder: (context, state) => LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    if (constraints.maxWidth > 800) {
                      return AddHouse(width: deviceWidth / 2);
                    } else {
                      return AddHouse(width: deviceWidth / 1.1);
                    }
                  },
                ),
              ),
              GoRoute(
                  path: 'view-and-update-listings',
                  builder: (context, state) => ViewAndUpdateListings())
            ]),
        GoRoute(
            builder: (context, state) {
              return AdminDashboardScreen();
            },
            path: '/admin-dashboard'),
        GoRoute(
          path: '/admin-settings',
          builder: (context, state) => AdminSettingsPage(),
          
        ),
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
    final isOnLoginPage = state.matchedLocation == '/login';

    // If the user is not logged in, redirect them to login
    if (!loggedIn &&
        !['/login', '/registration', '/forgot-password']
            .contains(state.matchedLocation)) {
      return null;
    }

    // If the user is logged in but is on the login page, send them to their dashboard
    if (loggedIn && isOnLoginPage) {
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
      } else {
        return '/login';
      }
    }

    // Stay on the current page
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      scrollBehavior: CustomScrollBehavior(),
      theme:
          ThemeData(colorSchemeSeed: colorSelected.color, useMaterial3: true),
      darkTheme: ThemeData(
          colorSchemeSeed: colorSelected.color,
          useMaterial3: true,
          brightness: Brightness.dark),
      routerConfig: routeMaker(context),
      title: "Residential Tracker and Booking",
    );
  }
}
