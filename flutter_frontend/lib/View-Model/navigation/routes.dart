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


   GoRouter routeMaker(BuildContext context) {
     double deviceWidth = MediaQuery.of(context).size.width;
     return GoRouter(
       initialLocation: '/login',
       redirect:  appdirect,




       routes: [
         GoRoute(
             builder: (context, state) {
               return LayoutBuilder(builder: (context, constraints) {
                 if (constraints.maxWidth > 800) {
                   //loggedIn=true;
                   return LoginPage(
                     width: deviceWidth / 2,
                   );
                 } else {
                   //loggedIn=true;
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
             builder: (context,state){
               return LayoutBuilder(builder: (context,constraints){
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
             builder: (context,state){
               return LayoutBuilder(builder: (context,constraints){
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
             path: '/verify-email'),
         // GoRoute(path: '/student-dashboard'),
         // GoRoute(path: '/landlord-dashboard'),
         // GoRoute(path: '/admin-dashboard')
         GoRoute(
           path: "/landloaddashboard",
           builder: (context, state) => LandLoardDashboardScreen(changeTheme: changeTheme, changeColor: changeColor, colorSelected: colorSelected),

         ),
         GoRoute(
           path: "/studentdashboard",
           builder: (context, state) => StudentDashboardScreen(changeTheme: changeTheme, changeColor: changeColor, colorSelected: colorSelected),

         ),
         GoRoute(
           path: "/admin_dashboard",
           builder: (context, state) => AdminDashboardScreen(changeTheme: changeTheme, changeColor: changeColor, colorSelected: colorSelected),

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

