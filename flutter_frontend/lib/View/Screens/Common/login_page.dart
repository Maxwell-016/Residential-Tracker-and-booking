import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/View-Model/utils/app_colors.dart';
import 'package:flutter_frontend/View-Model/utils/savecurrentpage.dart';
import 'package:flutter_frontend/View/Components/login_form.dart';
import 'package:flutter_frontend/services/firebase_services.dart';
import 'package:flutter_frontend/View-Model/utils/validator.dart';
import 'package:flutter_frontend/View/Components/function_button.dart';
import 'package:flutter_frontend/View/Components/google_fonts.dart';
import 'package:flutter_frontend/View/Components/link_button.dart';
import 'package:flutter_frontend/View/Components/password_field.dart';
import 'package:flutter_frontend/View/Components/snackbars.dart';
import 'package:flutter_frontend/View/Components/text_field.dart';
import 'package:flutter_frontend/View/Screens/Common/registration_page.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../View-Model/view_model.dart';
import '../../../security/hashPassword.dart';

class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    saveCurrentPage("/login");
    var widths = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        body: widths > 700 ? largeScreen(context) : LoginForm(),
      ),
    );
  }

  Widget largeScreen(BuildContext context) {
    var width = MediaQuery.of(context).size.width / 2;

    return Stack(children: [
      Container(
        margin: EdgeInsets.only(right: width),
        decoration: const BoxDecoration(
          color: Colors.grey,
          image: DecorationImage(
            image: AssetImage('assets/launch.png'),
            fit: BoxFit.fill,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
      Positioned(
        top: 0,
        bottom: 0,
        right: 0,
        child: SizedBox(
          width: width,
          child: LoginForm(),
        ),
      ),
    ]);
  }
}
