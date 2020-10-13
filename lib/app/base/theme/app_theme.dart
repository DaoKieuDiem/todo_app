import 'package:flutter/material.dart';

class AppTheme {
  //d6769b
  static const Color primaryColor = Color(0xff3a5ad3);
  AppTheme();

  static ThemeData build() {
    return ThemeData(
      primaryColor: primaryColor,
      accentColor: primaryColor,
      fontFamily: 'GoogleSans',
      colorScheme: const ColorScheme.light().copyWith(
        primary: primaryColor,
      ),
    );
  }
}
