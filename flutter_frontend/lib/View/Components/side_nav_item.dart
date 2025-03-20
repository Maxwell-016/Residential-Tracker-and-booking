import 'package:flutter/material.dart';

import 'google_fonts.dart';

class SideNavItem extends StatelessWidget {
  final String text;
  const SideNavItem({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(20.0),
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(
            color: isDark ? Colors.white : Colors.black54, width: 1.0),),
      ),
      child: UseFont(text: text, myFont: 'Open Sans', size: 20,color: Colors.blue,),
    );
  }
}
