import 'package:flutter/material.dart';
import 'edit_account_screen.dart';
import 'package:transconnect_driver_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:transconnect_driver_app/shared/theme/app_colors.dart';
import 'package:transconnect_driver_app/shared/widgets/panel.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key, required this.api});
  final AuthController api;
  @override
  Widget build(BuildContext context) => Panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => EditAccountScreen(api: api),
            ),
          ),
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Sửa thông tin / đổi mật khẩu'),
        ),
        const Icon(Icons.account_circle_outlined, size: 48, color: red),
        const SizedBox(height: 16),
        Text(
          api.user?.fullName ?? '',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SelectableText(api.user?.email ?? ''),
        const SizedBox(height: 16),
        const Chip(
          avatar: Icon(Icons.verified_outlined),
          label: Text('Email đã xác thực'),
        ),
      ],
    ),
  );
}
