import 'package:flutter/material.dart';
import 'package:transconnect_driver_app/core/theme/app_colors.dart';

ThemeData buildAppTheme() => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: red,
    primary: red,
    secondary: gold,
  ),
  scaffoldBackgroundColor: const Color(0xFFF2F2F7),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFF8F9FA),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    contentPadding: const EdgeInsets.all(17),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size(double.infinity, 52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  ),
);
