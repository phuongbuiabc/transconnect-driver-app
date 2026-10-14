import 'package:flutter/material.dart';
import 'package:transconnect_driver_app/app/session/driver_controller.dart';
import 'package:transconnect_driver_app/core/theme/app_colors.dart';
import 'package:transconnect_driver_app/shared/widgets/panel.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key, required this.api});
  final DriverController api;
  @override
  Widget build(BuildContext context) => Panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.account_circle_outlined, size: 48, color: red),
        const SizedBox(height: 16),
        Text(
          api.user?['fullName'] as String? ?? '',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SelectableText(api.user?['email'] as String? ?? ''),
        const SizedBox(height: 16),
        const Chip(
          avatar: Icon(Icons.verified_outlined),
          label: Text('Email đã xác thực'),
        ),
      ],
    ),
  );
}
