import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:transconnect_driver_app/app/session/driver_controller.dart';
import 'package:transconnect_driver_app/app/theme/app_theme.dart';
import 'package:transconnect_driver_app/app/navigation/driver_shell.dart';

class DriverApp extends StatelessWidget {
  final DriverController api;
  const DriverApp({super.key, required this.api});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'TransConnect Driver',
    debugShowCheckedModeBanner: false,
    locale: const Locale('vi'),
    supportedLocales: const [Locale('vi')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    theme: buildAppTheme(),
    home: DriverShell(api: api),
  );
}
