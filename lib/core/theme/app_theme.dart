import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color secondaryBlue = Color(0xFF1E88E5);
  static const Color background = Color(0xFFF4F8FF);

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
      primary: primaryBlue,
      secondary: secondaryBlue,
    ),
  );
}
