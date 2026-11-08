import 'package:flutter/material.dart';
import 'edit_account_screen.dart';
import 'package:transconnect_driver_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:transconnect_driver_app/shared/widgets/status_pill.dart';

class AccountMenuEntry {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  const AccountMenuEntry(this.icon, this.title, this.onTap, {this.subtitle});
}

class AccountScreen extends StatelessWidget {
  const AccountScreen({
    super.key,
    required this.api,
    required this.onLogout,
    this.entries = const [],
  });
  final AuthController api;
  final List<AccountMenuEntry> entries;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final user = api.user;
    final scheme = Theme.of(context).colorScheme;
    final name = user?.fullName ?? '';
    final avatar = user?.avatarUrl;
    Widget row(AccountMenuEntry entry) => ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(entry.icon, size: 22, color: scheme.onSurfaceVariant),
      title: Text(entry.title),
      subtitle: entry.subtitle == null
          ? null
          : Text(
              entry.subtitle!,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
      trailing: const Icon(Icons.chevron_right),
      onTap: entry.onTap,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: scheme.surfaceContainerHigh,
              foregroundImage: avatar == null ? null : NetworkImage(avatar),
              child: Text(
                name.isEmpty ? '?' : name.trim().split(' ').last[0],
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user?.email ?? '',
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8),
                  StatusPill(
                    api.verified ? 'Email đã xác thực' : 'Email chưa xác thực',
                    tone: api.verified
                        ? StatusTone.positive
                        : StatusTone.waiting,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        for (final entry in entries) ...[row(entry), const Divider(height: 1)],
        row(
          AccountMenuEntry(
            Icons.manage_accounts_outlined,
            'Tài khoản và mật khẩu',
            () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => EditAccountScreen(api: api),
              ),
            ),
            subtitle: 'Họ tên, số điện thoại, ảnh đại diện',
          ),
        ),
        const Divider(height: 1),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: scheme.error),
            onPressed: onLogout,
            icon: const Icon(Icons.logout),
            label: const Text('Đăng xuất'),
          ),
        ),
      ],
    );
  }
}
