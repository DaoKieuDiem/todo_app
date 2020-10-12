import 'package:flutter/material.dart';

class AppTheme {
  static const primaryColor = Color(0xffd6769b);
  AppTheme();

  static ThemeData build() {
    return ThemeData(
      primaryColor: primaryColor,
      accentColor: primaryColor,
      fontFamily: 'GoogleSans',
      unselectedWidgetColor: Colors.white,
    );
  }
}
