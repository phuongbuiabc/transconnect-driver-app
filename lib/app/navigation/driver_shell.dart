import 'package:flutter/material.dart';
import 'package:transconnect_driver_app/app/session/driver_controller.dart';
import 'package:transconnect_driver_app/features/account/presentation/screens/account_screen.dart';
import 'package:transconnect_driver_app/features/auth/presentation/screens/auth_screen.dart';
import 'package:transconnect_driver_app/features/foundation/presentation/screens/contact_screen.dart';
import 'package:transconnect_driver_app/features/foundation/presentation/screens/documents_screen.dart';
import 'package:transconnect_driver_app/features/foundation/presentation/screens/organizations_screen.dart';
import 'package:transconnect_driver_app/features/foundation/presentation/screens/review_history_screen.dart';
import 'package:transconnect_driver_app/features/home/presentation/screens/home_screen.dart';
import 'package:transconnect_driver_app/features/invitations/presentation/screens/invitation_screen.dart';
import 'package:transconnect_driver_app/features/places/data/places_repository.dart';
import 'package:transconnect_driver_app/features/places/presentation/controllers/places_controller.dart';
import 'package:transconnect_driver_app/features/places/presentation/screens/places_screen.dart';
import 'package:transconnect_driver_app/shared/theme/app_colors.dart';
import 'package:transconnect_driver_app/shared/widgets/adaptive_scaffold.dart';
import 'package:transconnect_driver_app/shared/widgets/brand.dart';
import 'package:transconnect_driver_app/shared/widgets/notice.dart';

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
  late final places = PlacesController(PlacesRepository(widget.api.session));
  @override
  void initState() {
    super.initState();
    widget.api.addListener(changed);
    restore();
  }

  @override
  void dispose() {
    places.dispose();
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

  void push(Widget Function(BuildContext) builder) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: builder));

  void enterCode() => push(
    (_) => InvitationScreen(
      api: widget.api.invitations,
      canAccept: widget.api.canAccept,
      onAccepted: reload,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final api = widget.api;
    if (starting) return const SplashScreen();
    if (!api.signedIn) return AuthScreen(api: api);
    return AdaptiveScaffold(
      selectedIndex: tab,
      onSelected: (value) => setState(() => tab = value),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          label: 'Trang chủ',
        ),
        NavigationDestination(
          icon: Icon(Icons.directions_bus_outlined),
          label: 'Nhà xe',
        ),
        NavigationDestination(
          icon: Icon(Icons.travel_explore),
          label: 'Địa điểm',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          label: 'Tài khoản',
        ),
      ],
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: RefreshIndicator(
              onRefresh: reload,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                children: [
                  const Align(alignment: Alignment.centerLeft, child: Brand()),
                  const SizedBox(height: 24),
                  if (error != null) ...[
                    Notice(error!, failure: true),
                    const SizedBox(height: 20),
                  ],
                  _tab(api),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tab(DriverController api) {
    if (tab == 2) return PlacesScreen(controller: places);
    if (tab == 3) return _account(api);
    if (!api.profileLoaded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Notice('Chưa tải được hồ sơ. Vui lòng thử lại.'),
          TextButton(onPressed: reload, child: const Text('Tải lại')),
        ],
      );
    }
    if (tab == 0) {
      return HomeScreen(
        api: api,
        profiles: api.profiles,
        foundation: api.foundation,
        onOpenOrganizations: () => setState(() => tab = 1),
        onEnterCode: enterCode,
        onChanged: reload,
      );
    }
    if (!api.verified || api.driver == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Notice(
            !api.verified
                ? 'Xác thực email ở Trang chủ trước khi xem lời mời của nhà xe.'
                : 'Gửi hồ sơ tài xế ở Trang chủ trước khi xem lời mời của nhà xe.',
          ),
          TextButton(
            onPressed: () => setState(() => tab = 0),
            child: const Text('Về Trang chủ'),
          ),
        ],
      );
    }
    return OrganizationsScreen(
      controller: api.foundation,
      driverId: api.driver!.id,
      approved: api.driver!.isApproved,
      onEnterCode: enterCode,
    );
  }

  Widget _account(DriverController api) {
    final driver = api.driver;
    return AccountScreen(
      api: api,
      onLogout: logout,
      entries: [
        if (api.verified && driver != null) ...[
          AccountMenuEntry(
            Icons.call_outlined,
            'Thông tin liên hệ',
            () => push(
              (_) => ContactScreen(
                controller: api.foundation,
                driverId: driver.id,
              ),
            ),
            subtitle: api.foundation.contact?.phone ?? 'Chưa có số liên hệ',
          ),
          AccountMenuEntry(
            Icons.badge_outlined,
            'Giấy phép lái xe',
            () => push(
              (_) => DocumentsScreen(
                controller: api.foundation,
                driverId: driver.id,
              ),
            ),
            subtitle: 'Bản demo, chưa xác minh',
          ),
          AccountMenuEntry(
            Icons.history,
            'Lịch sử xét duyệt hồ sơ',
            () => push((_) => ReviewHistoryScreen(controller: api.foundation)),
          ),
        ],
      ],
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
    setState(() => tab = 0);
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

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    backgroundColor: red,
    body: SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.route, color: gold, size: 56),
            SizedBox(height: 16),
            Text(
              'VieGo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 44,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Tài xế · Kết nối hành trình Việt',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            SizedBox(height: 40),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
