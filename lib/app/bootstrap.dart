import 'package:flutter/material.dart';
import 'package:transconnect_driver_app/app/driver_app.dart';
import 'package:transconnect_driver_app/app/session/driver_controller.dart';
import 'package:transconnect_driver_app/core/config/app_config.dart';

void bootstrap() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(DriverApp(api: DriverController(baseUrl: AppConfig.apiBaseUrl)));
}
