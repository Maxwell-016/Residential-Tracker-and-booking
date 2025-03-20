import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/View/Components/color_button.dart';
import 'package:flutter_frontend/View/Components/theme_button.dart';

import '../../../constants.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({
    super.key,
    // required this.changeTheme,
    // required this.changeColor,
    // required this.colorSelected,
  });

  // final ColorSelection? colorSelected;
  // final void Function(bool useLightMode)? changeTheme;
  // final void Function(int value)? changeColor;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
appBar: AppBar(
  title: Text("Student Dashboard"),
  // actions: [
  //   ThemeButton(changeThemeMode: changeTheme),
  //   ColorButton(changeColor: changeColor, colorSelected: colorSelected)
  // ],
),

    );
  }
}