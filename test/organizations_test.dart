import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:transconnect_driver_app/app/driver_app.dart';
import 'package:transconnect_driver_app/app/session/driver_controller.dart';
import 'helpers/memory_token_store.dart';

const driverId = 'driver-1';
final future = DateTime.now().toUtc().add(const Duration(days: 5));
final past = DateTime.now().toUtc().subtract(const Duration(days: 5));
String server(DateTime value) => value.toIso8601String().replaceFirst('Z', '');

http.Response ok(Object? data) => http.Response(
  jsonEncode({'succeeded': true, 'data': data}),
  200,
  headers: {'content-type': 'application/json; charset=utf-8'},
);
http.Response missing() => http.Response(
  jsonEncode({'succeeded': false, 'message': 'Không tìm thấy.'}),
  404,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

class Backend {
  final String reviewStatus;
  final accepted = <String>[];
  Backend({this.reviewStatus = 'Approved'});

  List<Map<String, Object?>> get collaborations => [
    {
      'id': 'direct-1',
      'organizationId': 'org-a',
      'organizationName': 'Nhà xe Sông Hàn',
      'expiresAt': server(future),
      'acceptedAt': accepted.contains('direct-1') ? server(past) : null,
      'endedAt': null,
      'revokedAt': null,
    },
    {
      'id': 'expired-1',
      'organizationId': 'org-c',
      'organizationName': 'Nhà xe Đèo Cả',
      'expiresAt': server(past),
      'acceptedAt': null,
      'endedAt': null,
      'revokedAt': null,
    },
  ];

  Future<http.Response> handle(http.Request r) async {
    switch ((r.method, r.url.path)) {
      case ('GET', '/auth/me'):
        return ok({
          'accountGroup': 'Operator',
          'email': 'tai.xe@viego.test',
          'fullName': 'Trần Văn Đức',
          'emailVerified': true,
        });
      case ('GET', '/drivers/me'):
        return ok({
          'id': driverId,
          'fullName': 'Trần Văn Đức',
          'reviewStatus': reviewStatus,
          'contactPhone': '0905123456',
          'contactAddress': 'Hải Châu, Đà Nẵng',
        });
      case ('GET', '/drivers/me/collaborations'):
        return ok(collaborations);
      case ('GET', '/operator/invitations'):
        return ok([
          {
            'id': 'email-1',
            'organizationId': 'org-b',
            'organizationName': 'Nhà xe Hải Vân',
            'role': 'Driver',
            'expiresAt': server(future),
            'acceptedAt': null,
            'revokedAt': null,
            'email': 'tai.xe@viego.test',
          },
        ]);
      case ('GET', '/drivers/$driverId/reviews'):
        return ok(<Object?>[]);
      case ('POST', final path)
          when path.startsWith('/drivers/invitations/') &&
              path.endsWith('/accept'):
        accepted.add(path.split('/')[3]);
        return ok({'id': 'engagement', 'organizationId': 'org-a'});
    }
    return missing();
  }
}

Future<DriverController> start(WidgetTester tester, Backend backend) async {
  tester.view.physicalSize = const Size(360, 780);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = 1.3;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  final store = MemoryStore()
    ..value = jsonEncode({
      'accessToken': 'token',
      'refreshToken': 'refresh',
      'accountGroup': 'Operator',
      'emailVerified': true,
      'email': 'tai.xe@viego.test',
      'fullName': 'Trần Văn Đức',
    });
  final api = DriverController(
    baseUrl: 'https://example.test',
    store: store,
    client: MockClient(backend.handle),
  );
  addTearDown(api.dispose);
  await tester.pumpWidget(DriverApp(api: api));
  await tester.pumpAndSettle();
  return api;
}

void main() {
  testWidgets('home names the next step from pending invitations', (
    tester,
  ) async {
    await start(tester, Backend());
    expect(find.text('Bạn có 2 lời mời đang chờ'), findsOneWidget);
    expect(find.text('Xem lời mời'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('driver accepts a listed invitation without a token', (
    tester,
  ) async {
    final backend = Backend();
    await start(tester, backend);
    await tester.tap(find.text('Xem lời mời'));
    await tester.pumpAndSettle();

    expect(find.text('Nhà xe Hải Vân'), findsOneWidget);
    expect(find.text('Nhà xe Sông Hàn'), findsOneWidget);
    expect(find.text('Lời mời đang chờ (2)'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Nhà xe Đèo Cả'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Lịch sử (1)'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Nhà xe Sông Hàn'),
      -200,
      scrollable: find.byType(Scrollable).first,
    );
    final row = find.ancestor(
      of: find.text('Nhà xe Sông Hàn'),
      matching: find.byType(ListTile),
    );
    await tester.tap(find.descendant(of: row, matching: find.text('Nhận')));
    await tester.pumpAndSettle();
    expect(find.text('Nhận lời mời của Nhà xe Sông Hàn?'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Nhận lời mời'));
    await tester.pumpAndSettle();

    expect(backend.accepted, ['direct-1']);
    expect(find.text('Đang cộng tác (1)'), findsOneWidget);
    expect(find.text('Lời mời đang chờ (1)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('unapproved driver cannot accept invitations', (tester) async {
    await start(tester, Backend(reviewStatus: 'Pending'));
    expect(find.text('Hồ sơ đang chờ xét duyệt'), findsOneWidget);
    await tester.tap(find.text('Nhà xe'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Hồ sơ tài xế cần được duyệt trước khi bạn nhận lời mời của nhà xe.',
      ),
      findsOneWidget,
    );
    final buttons = tester.widgetList<FilledButton>(
      find.widgetWithText(FilledButton, 'Nhận'),
    );
    expect(buttons, isNotEmpty);
    expect(buttons.every((b) => b.onPressed == null), isTrue);
  });

  testWidgets('account menu opens driver pages at enlarged text', (
    tester,
  ) async {
    await start(tester, Backend());
    await tester.tap(find.text('Tài khoản'));
    await tester.pumpAndSettle();
    expect(find.text('0905123456'), findsOneWidget);
    await tester.tap(find.text('Thông tin liên hệ'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextFormField, 'Hải Châu, Đà Nẵng'), findsOne);
    expect(tester.takeException(), isNull);
  });
}
