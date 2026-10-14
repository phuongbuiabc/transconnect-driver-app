import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:transconnect_driver_app/app/session/driver_controller.dart';
import 'package:transconnect_driver_app/shared/widgets/brand.dart';
import 'package:transconnect_driver_app/shared/widgets/notice.dart';
import 'package:transconnect_driver_app/features/auth/presentation/screens/auth_screen.dart';
import 'package:transconnect_driver_app/features/auth/presentation/screens/email_verification_screen.dart';
import 'package:transconnect_driver_app/features/driver_profile/presentation/screens/driver_profile_screen.dart';
import 'package:transconnect_driver_app/features/invitations/presentation/screens/invitation_screen.dart';
import 'package:transconnect_driver_app/features/account/presentation/screens/account_screen.dart';

class DriverShell extends StatefulWidget {
  final DriverController api;
  const DriverShell({super.key, required this.api});
  @override
  State<DriverShell> createState() => _DriverShellState();
}

class _DriverShellState extends State<DriverShell> {
  bool starting = true;
  String? error;
  int tab = 0;
  @override
  void initState() {
    super.initState();
    widget.api.addListener(changed);
    restore();
  }

  @override
  void dispose() {
    widget.api.removeListener(changed);
    super.dispose();
  }

  void changed() {
    if (mounted) setState(() {});
  }

  Future<void> restore() async {
    try {
      await widget.api.restore();
    } catch (e) {
      error = e.toString();
    }
    if (mounted) setState(() => starting = false);
  }

  Future<void> reload() async {
    try {
      await widget.api.load();
      if (mounted) setState(() => error = null);
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final api = widget.api;
    if (starting) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!api.signedIn) return AuthScreen(api: api);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: RefreshIndicator(
              onRefresh: reload,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Row(
                    children: [
                      const Brand(),
                      const Spacer(),
                      IconButton(
                        onPressed: reload,
                        tooltip: 'Làm mới',
                        icon: const Icon(Icons.refresh),
                      ),
                      IconButton(
                        onPressed: logout,
                        tooltip: 'Đăng xuất',
                        icon: const Icon(Icons.logout),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  if (error != null) ...[
                    Notice(error!, failure: true),
                    const SizedBox(height: 20),
                  ],
                  if (!api.profileLoaded) ...[
                    const Notice('Chưa tải được hồ sơ. Vui lòng thử lại.'),
                    TextButton(onPressed: reload, child: const Text('Tải lại')),
                  ] else if (!api.verified)
                    EmailVerificationScreen(api: api)
                  else if (tab == 0)
                    DriverProfileScreen(api: api)
                  else if (tab == 1)
                    InvitationScreen(api: api)
                  else
                    AccountScreen(api: api),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: NavigationBar(
                backgroundColor: Colors.white.withValues(alpha: .90),
                selectedIndex: tab,
                onDestinationSelected: (v) => setState(() => tab = v),
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.badge_outlined),
                    label: 'Hồ sơ',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.mail_outline),
                    label: 'Lời mời',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person_outline),
                    label: 'Tài khoản',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Đăng xuất?'),
        content: const Text('Bạn có thể đăng nhập lại để theo dõi hồ sơ.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Ở lại'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await widget.api.logout();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Đã xóa phiên trên thiết bị. Chưa xác nhận thu hồi phiên ở máy chủ.',
            ),
          ),
        );
      }
    }
  }
}
