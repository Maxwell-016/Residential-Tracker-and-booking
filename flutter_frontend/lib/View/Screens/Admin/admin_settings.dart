import 'package:flutter/material.dart';

import '../../../constants.dart';
import '../../Components/SimpleAppBar.dart';

class AdminSettingsPage extends StatelessWidget {
  const AdminSettingsPage({
    super.key,
    required this.changeTheme,
    required this.changeColor,
    required this.colorSelected,
  });


  final ColorSelection colorSelected;
  final void Function(bool useLightMode) changeTheme;
  final void Function(int value) changeColor;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:PreferredSize(
        preferredSize: Size.fromHeight(60),
        child:App_Bar(
            changeTheme: changeTheme,
            changeColor: changeColor,
            colorSelected: colorSelected,
            title:"Admin Settings"),
      ),




      body: const Center(
        child: Text(
          'This is the Admin Settings Page',
          style: TextStyle(fontSize: 18),
          ),
      ),
    );
  }
}