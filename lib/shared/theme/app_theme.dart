import 'package:flutter/material.dart';

const red = Color(0xFFD3171E);
const gold = Color(0xFFFFC72C);
ThemeData buildAppTheme({Brightness brightness = Brightness.light}) {
  final dark = brightness == Brightness.dark;
  final surface = dark ? const Color(0xFF202329) : Colors.white;
  final foreground = dark ? const Color(0xFFF2F3F5) : const Color(0xFF202329);
  final muted = dark ? const Color(0xFFC6C9D0) : const Color(0xFF545A65);
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      brightness: brightness,
      seedColor: red,
      primary: dark ? const Color(0xFFFFB4AB) : red,
      secondary: dark ? const Color(0xFFFFB4AB) : red,
      secondaryContainer: dark
          ? const Color(0xFF34373D)
          : const Color(0xFFF5F6F8),
      onSecondaryContainer: foreground,
      surface: surface,
      onSurface: foreground,
      onSurfaceVariant: muted,
      surfaceContainerLowest: dark ? const Color(0xFF17191E) : Colors.white,
      surfaceContainerLow: dark
          ? const Color(0xFF272A30)
          : const Color(0xFFF5F6F8),
      surfaceContainer: dark
          ? const Color(0xFF2C2F35)
          : const Color(0xFFEEF0F3),
      surfaceContainerHigh: dark
          ? const Color(0xFF31343B)
          : const Color(0xFFE8EBF0),
      surfaceContainerHighest: dark
          ? const Color(0xFF383C43)
          : const Color(0xFFE1E4EA),
      outlineVariant: dark ? const Color(0xFF454953) : const Color(0xFFD7DAE0),
    ),
    scaffoldBackgroundColor: surface,
    appBarTheme: AppBarTheme(
      centerTitle: false,
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surface,
      indicatorColor: red,
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected) ? Colors.white : muted,
        ),
      ),
      height: 80,
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: surface,
      indicatorColor: red,
      selectedIconTheme: const IconThemeData(color: Colors.white),
      unselectedIconTheme: IconThemeData(color: muted),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: dark ? const Color(0xFF292C33) : Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.all(16),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
    ),
  );
}
