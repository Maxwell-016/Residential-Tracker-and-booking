import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend/View-Model/navigation/routes.dart';
import 'package:flutter_frontend/View/Screens/Admin/add_individuals_page.dart';
import 'package:flutter_frontend/View/Screens/Admin/view_landlords_page.dart';
import 'package:flutter_frontend/View/Screens/Admin/view_students_page.dart';
import 'package:flutter_frontend/View/Screens/Landlord/landlord_profile.dart';
import 'package:flutter_frontend/View/Screens/Landlord/my_wallet.dart';
import 'package:flutter_frontend/View/Screens/Landlord/reviews_and_feedback.dart';
import 'package:flutter_frontend/View/Screens/Landlord/students_bookings.dart';
import 'package:flutter_frontend/View/Screens/Landlord/update_house_status.dart';
import 'package:flutter_frontend/View/Screens/Landlord/view_and_update_listings.dart';
import 'package:flutter_frontend/View/Screens/Student/allstudent.dart';
import 'package:flutter_frontend/View/Screens/Student/mapit.dart';
import 'package:flutter_frontend/View/Screens/Student/testemail.dart';
import 'package:flutter_frontend/constants.dart';
import 'package:flutter_frontend/services/firebase_services.dart';
import 'package:flutter_frontend/components/wallit.dart';
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
import 'View/Screens/Student/chart_screen.dart';
import 'data/payment.dart';
import 'data/providers.dart';
import 'data/testnotification.dart';
import 'firebase_options.dart';
import 'dart:html' as html;

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
  // String initialRoute = await getLastVisitedPage();


  if (kIsWeb && html.Notification.supported) {
    final permission = await html.Notification.requestPermission();
    print("Notification permission status: $permission");
  }


  AwesomeNotifications().initialize(
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

  runApp(ProviderScope(overrides: [
    sharedPreferencesProvider.overrideWithValue(sharedPreferences),
  ], child: ResidentialTrackerAndBooking()));
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

  late final _router = GoRouter(
    initialLocation: "/login",
    redirect: _appRedirect,
    routes: [
      //  GoRoute(builder: (context, state) => LoginPage(), path: '/login'),

      GoRoute(builder: (context, state) => LoginPage(), path: '/login'),
      GoRoute(
          builder: (context, state) => AllBookedHousesMap(),
          path: '/students-location'),

      GoRoute(
          builder: (context, state) => RegistrationPage(),
          path: '/registration'),
      GoRoute(
          builder: (context, state) => ForgotPassword(),
          path: '/forgot-password'),
      GoRoute(
          builder: (context, state) => EmailVerificationPage(),
          path: '/verification'),

      GoRoute(
          builder: (context, state) {
            return LandLordDashboardScreen(
              changeTheme: changeThemeMode,
              changeColor: changeColor,
              colorSelected: colorSelected,
            );
          },
          path: '/landlord-dashboard'),

      GoRoute(
          builder: (context, state) {
            return ManageHouseListings(
              changeTheme: changeThemeMode,
              changeColor: changeColor,
              colorSelected: colorSelected,
            );
          },
          path: '/manageListings',
          routes: [
            GoRoute(
              path: 'add-house',
              builder: (context, state) => AddHouse(
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
              ),
            ),
            GoRoute(
              path: 'update-house-status',
              builder: (context, state) => UpdateHouseStatus(
                changeTheme: changeThemeMode,
                changeColor: changeColor,
                colorSelected: colorSelected,
              ),
            ),
          ]),
      GoRoute(
        path: '/student-bookings',
        builder: (context, state) => StudentsBookings(
          changeTheme: changeThemeMode,
          changeColor: changeColor,
          colorSelected: colorSelected,
        ),
      ),
      GoRoute(
          builder: (context, state) => ReviewsAndFeedback(
                changeTheme: changeThemeMode,
                changeColor: changeColor,
                colorSelected: colorSelected,
              ),
          path: '/tenant-feedback'),
      GoRoute(
          builder: (context, state) => LandlordProfile(
                changeTheme: changeThemeMode,
                changeColor: changeColor,
                colorSelected: colorSelected,
              ),
          path: '/landlord-profile'),
      GoRoute(
          builder: (context, state) => MyWallet(
            changeTheme: changeThemeMode,
            changeColor: changeColor,
            colorSelected: colorSelected,
          ),
          path: '/wallet'),

      GoRoute(
          builder: (context, state) {
            return AdminDashboardScreen(
              changeTheme: changeThemeMode,
              changeColor: changeColor,
              colorSelected: colorSelected,
            );
          },
          path: '/admin-dashboard'),
      GoRoute(
          path: '/view-students',
          builder: (context, state) {
            return ViewStudentsPage(
              changeTheme: changeThemeMode,
              changeColor: changeColor,
              colorSelected: colorSelected,
            );
          }),
      GoRoute(
          path: '/view-landlords',
          builder: (context, state) {
            return ViewLandlordsPage(
              changeTheme: changeThemeMode,
              changeColor: changeColor,
              colorSelected: colorSelected,
            );
          }),
      GoRoute(
          path: '/add-individuals',
          builder: (context, state) {
            return AddIndividualsPage(
              changeTheme: changeThemeMode,
              changeColor: changeColor,
              colorSelected: colorSelected,
            );
          }),

      GoRoute(
          builder: (context, state) {
            return ChatScreen(
              changeTheme: changeThemeMode,
              changeColor: changeColor,
              colorSelected: colorSelected,
            );
          },
          path: '/student-dashboard'),
      // GoRoute(
      //     builder: (context, state) {
      //       return  MapScreen();
      //     },
      //     path: '/mapit'),
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

  Future<String?> _appRedirect(
      BuildContext context, GoRouterState state) async {
    final fb = ref.watch(firebaseServices);
    final loggedIn = fb.loggedIn();
    final isOnLoginPage = state.matchedLocation == '/login';

    // If the user is not logged in, redirect them to login
    if (!loggedIn &&
        !['/login', '/registration', '/forgot-password']
            .contains(state.matchedLocation)) {
      return '/login';
    }

    // If the user is logged in but is on the login page, send them to their dashboard
    if (loggedIn) {
      String? role = await fb.getUserRole();

      if (isOnLoginPage) {
        return getDashboardForRole(role);
      }

      if(!hasPermissionForRoute(role, state.matchedLocation)){
        return getDashboardForRole(role);
      }

    }

    return null;
  }

  String? getDashboardForRole(String? role) {
    switch (role) {
      case 'Student':
        return '/student-dashboard';
      case 'Landlord':
        return '/landlord-dashboard';
      case 'Admin':
        return '/admin-dashboard';
      default:
        return '/login';
    }

  }

  bool hasPermissionForRoute(String? role, String route) {
    const roleRoutes = {
      'Student': [
        '/student-dashboard',
      ],
      'Landlord': [
        '/landlord-dashboard',
        '/manageListings',
        '/manageListings/add-house',
        '/manageListings/view-and-update-listings',
        '/manageListings/update-house-status',
        '/landlord-profile',
        '/student-bookings',
        '/tenant-feedback',
        '/wallet',
      ],
      'Admin': [
        '/admin-dashboard',
        '/view-students',
        '/view-landlords',
        '/add-individuals',
        '/students-location',
      ]
    };
    const commonRoutes = [
      '/login',
      '/registration',
      '/forgot-password',
      '/verification'
    ];

    return commonRoutes.contains(route) ||
        (role != null && roleRoutes[role]!.contains(route));
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
