
import 'package:flutter/material.dart';
import 'app_colors.dart';

class Themes{
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightThemeBackground,
  );
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkThemeBackground
  );
}