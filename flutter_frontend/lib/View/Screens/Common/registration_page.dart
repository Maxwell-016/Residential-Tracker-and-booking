import 'package:flutter/material.dart';
import 'package:flutter_frontend/View/Components/reg_form.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../View-Model/utils/savecurrentpage.dart';

class RegistrationPage extends ConsumerStatefulWidget {
  const RegistrationPage({super.key});

  @override
  ConsumerState<RegistrationPage> createState() => _StateRegistrationPage();
}

class _StateRegistrationPage extends ConsumerState<RegistrationPage> {
  @override
  void initState() {
    super.initState();
    saveCurrentPage('/registration');
  }

  @override
  Widget build(BuildContext context) {
    var widths = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        body: widths > 700 ? largeScreen(context) : RegForm(),
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
          child: RegForm(),
        ),
      ),
    ]);
  }
}
