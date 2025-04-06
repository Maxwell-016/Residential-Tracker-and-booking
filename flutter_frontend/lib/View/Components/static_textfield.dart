import 'package:flutter/material.dart';

import '../../View-Model/utils/app_colors.dart';

class StaticTextfield extends StatelessWidget {
  final String label;
  final String text;
  final double width;
  final Icon icon;

  const StaticTextfield({super.key, required this.label, required this.text, required this.width, required this.icon});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color borderColor =
    isDark ? AppColors.lightThemeBackground : AppColors.darkThemeBackground;

    return Column(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Container(
          decoration: BoxDecoration(
              border: Border.all(
                color: borderColor,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(10.0)),
          width: width,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                icon,
                Text(text),
              ],
            ),
          )
        ),
      ],
    );
  }
}
