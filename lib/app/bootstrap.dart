import 'package:flutter/material.dart';
import '../core/config/app_config.dart';
import 'session/driver_controller.dart';
import 'driver_app.dart';

void bootstrap() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _DriverBootstrap());
}

class _DriverBootstrap extends StatefulWidget {
  const _DriverBootstrap();
  @override
  State<_DriverBootstrap> createState() => _DriverBootstrapState();
}

class _DriverBootstrapState extends State<_DriverBootstrap> {
  late final DriverController controller;
  @override
  void initState() {
    super.initState();
    controller = DriverController(baseUrl: AppConfig.apiBaseUrl);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DriverApp(api: controller);
}
