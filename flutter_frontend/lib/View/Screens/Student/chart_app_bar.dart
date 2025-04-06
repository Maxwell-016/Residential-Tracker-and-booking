import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/View-Model/view_model.dart';
import 'package:flutter_frontend/View/Components/theme_button.dart';
import 'package:flutter_frontend/services/firebase_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../constants.dart';
import '../../../data/providers.dart';
import '../../Components/color_button.dart';

class Chat_Bar extends ConsumerStatefulWidget {
  final ColorSelection colorSelected;
  final void Function(bool useLightMode) changeTheme;
  final void Function(int value) changeColor;
  final title;

  const Chat_Bar({
    super.key,
    required this.changeTheme,
    required this.changeColor,
    required this.colorSelected,
    required this.title,
  });
  @override
  ConsumerState<Chat_Bar> createState() => _StateAppBar();
}

class _StateAppBar extends ConsumerState<Chat_Bar> {
  @override
  Widget build(BuildContext context) {
    final fb = ref.watch(firebaseServices);

    return AppBar(
      title: Text(widget.title),
      elevation: 24,
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () {
          ref.read(toggleMenu.notifier).state = !ref.read(toggleMenu);
        },
      ),
      actions: [
        ThemeButton(changeThemeMode: widget.changeTheme),
        ColorButton(
            changeColor: widget.changeColor,
            colorSelected: widget.colorSelected),
        IconButton(
          onPressed: () async {
            fb.signOut(context);
            await Future.delayed(Duration(milliseconds: 1));
            context.go('/login');
          },
          icon: Icon(Icons.logout_sharp),
        ),
      ],
    );
  }
}
