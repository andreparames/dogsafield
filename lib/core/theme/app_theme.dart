import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF9E8E7A),
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(0xFFF6F5F0),
  );
}
