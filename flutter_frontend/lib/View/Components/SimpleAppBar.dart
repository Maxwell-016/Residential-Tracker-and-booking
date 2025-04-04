import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/View/Components/theme_button.dart';
import 'package:flutter_frontend/services/firebase_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../constants.dart';
import 'color_button.dart';

class App_Bar extends ConsumerStatefulWidget {
  final ColorSelection colorSelected;
  final void Function(bool useLightMode) changeTheme;
  final void Function(int value) changeColor;
  final String title;
  final Widget? search;

  const App_Bar({
    super.key,
    required this.changeTheme,
    required this.changeColor,
    required this.colorSelected,
    required this.title,
    this.search,
  });
  @override
  ConsumerState<App_Bar> createState() {
    return _StateAppBar();
  }
}

class _StateAppBar extends ConsumerState<App_Bar> {
  @override
  Widget build(BuildContext context) {
    final fb = ref.watch(firebaseServices);
    return

      AppBar(
        elevation: 24,
           iconTheme: IconThemeData(size: 30.0),
        centerTitle: true,
        title: widget.search != null ?
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 20.0,
              children: [
                Text(widget.title),
                widget.search!,
              ],
            )
            :Text(widget.title),
        actions: [
          ThemeButton(changeThemeMode: widget.changeTheme),
          ColorButton(changeColor: widget.changeColor, colorSelected: widget.colorSelected),
          IconButton(
            onPressed: () async {
              fb.signOut(context);
              await Future.delayed(Duration(milliseconds: 1));
              if(!context.mounted)return;
              context.go('/login');
            },
            icon: Icon(Icons.logout_sharp),
          ),
        ],
      );

  }
}
