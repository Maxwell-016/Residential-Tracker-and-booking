import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend/View-Model/navigation/routes.dart';
import 'package:flutter_frontend/View/Screens/Landlord/landlord_profile.dart';
import 'package:flutter_frontend/View/Screens/Landlord/students_bookings.dart';
import 'package:flutter_frontend/View/Screens/Landlord/view_and_update_listings.dart';
import 'package:flutter_frontend/View/Screens/Student/mapit.dart';
import 'package:flutter_frontend/constants.dart';
import 'package:flutter_frontend/services/firebase_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart';
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
import 'View/Screens/Student/chart_screen.dart';
import 'View/Screens/Student/student_dash.dart';
import 'data/payment.dart';
import 'data/providers.dart';
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

  //Request permission for notifications


  await AwesomeNotifications
  ().initialize(
    null,
    [
      NotificationChannel(
          channelKey: "app_status",
          channelName: "booking",
          channelDescription: "Booking status")
    ],
    debug: true,
  );

  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: ResidentialTrackerAndBooking()));
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
//  final String initialRoute;
  const ResidentialTrackerAndBooking({super.key});

  @override
  ConsumerState<ResidentialTrackerAndBooking> createState() =>
      _StateResidentialTrackerAndBooking();
}

class _StateResidentialTrackerAndBooking
    extends ConsumerState<ResidentialTrackerAndBooking> {
  ThemeMode themeMode = ThemeMode.light;

  ColorSelection colorSelected = ColorSelection.blue;

  void changeThemeMode(bool useLightMode) {
    setState(() {
      themeMode = useLightMode ? ThemeMode.light : ThemeMode.dark;
    });
  }

  void changeColor(int value) {
    setState(() {
      colorSelected = ColorSelection.values[value];
    });
  }


                changeTheme: changeThemeMode,
                changeColor: changeColor,
                colorSelected: colorSelected,
              ),
            ),
            GoRoute(
                path: 'view-and-update-listings',
                builder: (context, state) => ViewAndUpdateListings(
                      changeTheme: changeThemeMode,
                      changeColor: changeColor,
                      colorSelected: colorSelected,
                    ))
          ]),
      GoRoute(
          path: '/student-bookings',
          builder: (context, state) => StudentsBookings(
                changeTheme: changeThemeMode,
                changeColor: changeColor,
                colorSelected: colorSelected,
              )),
      GoRoute(
          builder: (context, state) => LandlordProfile(
                changeTheme: changeThemeMode,
                changeColor: changeColor,
                colorSelected: colorSelected,

          ),
        ),
      );
    },
  );

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
      themeMode: themeMode,
      theme:
          ThemeData(colorSchemeSeed: colorSelected.color, useMaterial3: true),
      darkTheme: ThemeData(
          colorSchemeSeed: colorSelected.color,
          useMaterial3: true,
          brightness: Brightness.dark),
      routerConfig: _router,
      title: "Residential Tracker and Booking",
    );
  }
}
