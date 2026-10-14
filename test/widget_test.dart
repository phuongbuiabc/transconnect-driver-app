import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transconnect_driver_app/app/session/driver_controller.dart';
import 'package:transconnect_driver_app/core/storage/token_store.dart';
import 'package:transconnect_driver_app/app/driver_app.dart';

class MemoryStore implements TokenStore {
  String? value;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String v) async {
    value = v;
  }

  @override
  Future<void> clear() async {
    value = null;
  }
}

void main() {
  testWidgets('auth supports Vietnamese onboarding at phone width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final api = DriverController(
      baseUrl: 'https://example.test',
      store: MemoryStore(),
    );
    addTearDown(api.dispose);
    await tester.pumpWidget(DriverApp(api: api));
    await tester.pumpAndSettle();
    expect(find.text('Chào mừng trở lại'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Chưa có tài khoản? Đăng ký tài xế'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('Chưa có tài khoản? Đăng ký tài xế'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chưa có tài khoản? Đăng ký tài xế'));
    await tester.pumpAndSettle();
    expect(find.text('Tạo tài khoản tài xế'), findsOneWidget);
    expect(find.text('Họ và tên'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
