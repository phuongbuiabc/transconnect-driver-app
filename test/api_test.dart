import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:transconnect_driver_app/app/session/driver_controller.dart';
import 'package:transconnect_driver_app/core/network/json.dart';
import 'package:transconnect_driver_app/core/errors/api_exception.dart';
import 'widget_test.dart' show MemoryStore;

Json session(String token) => {
  'accessToken': token,
  'refreshToken': 'refresh-' + token,
  'accountGroup': 'Operator',
  'emailVerified': true,
  'email': 'driver@example.test',
  'fullName': 'Tài xế',
};
http.Response ok(Json data) => http.Response(
  jsonEncode({'succeeded': true, 'data': data}),
  200,
  headers: {'content-type': 'application/json; charset=utf-8'},
);
http.Response failure(int status) => http.Response(
  jsonEncode({'succeeded': false, 'message': 'Failure'}),
  status,
);
void main() {
  test('simultaneous unauthorized requests rotate refresh once', () async {
    final store = MemoryStore()..value = jsonEncode(session('old'));
    var refreshes = 0;
    final gate = Completer<void>();
    final api = DriverController(
      baseUrl: 'https://example.test',
      store: store,
      client: MockClient((r) async {
        if (r.url.path == '/auth/me') return ok(session('old'));
        if (r.url.path == '/drivers/me') return failure(404);
        if (r.url.path == '/auth/refresh') {
          refreshes++;
          await gate.future;
          return ok(session('new'));
        }
        return r.headers['Authorization'] == 'Bearer old'
            ? failure(401)
            : ok({'value': true});
      }),
    );
    addTearDown(api.dispose);
    await api.restore();
    final a = api.request('GET', 'protected');
    final b = api.request('GET', 'protected');
    await Future<void>.delayed(const Duration(milliseconds: 20));
    gate.complete();
    await Future.wait([a, b]);
    expect(refreshes, 1);
    expect(jsonDecode(store.value!)['refreshToken'], 'refresh-new');
  });
  test('logout refreshes expired access and revokes rotated refresh', () async {
    final store = MemoryStore()..value = jsonEncode(session('old'));
    final revoked = <String>[];
    final api = DriverController(
      baseUrl: 'https://example.test',
      store: store,
      client: MockClient((r) async {
        if (r.url.path == '/auth/me') return ok(session('old'));
        if (r.url.path == '/drivers/me') return failure(404);
        if (r.url.path == '/auth/refresh') return ok(session('new'));
        if (r.url.path == '/auth/logout') {
          if (r.headers['Authorization'] == 'Bearer old') return failure(401);
          revoked.add(jsonDecode(r.body)['refreshToken'] as String);
          return ok({});
        }
        return failure(500);
      }),
    );
    addTearDown(api.dispose);
    await api.restore();
    await api.logout();
    expect(revoked, ['refresh-new']);
    expect(store.value, isNull);
    expect(api.signedIn, isFalse);
  });
  test('missing driver is distinct from failed driver load', () async {
    for (final status in [404, 500]) {
      final store = MemoryStore()..value = jsonEncode(session('old'));
      final api = DriverController(
        baseUrl: 'https://example.test',
        store: store,
        client: MockClient(
          (r) async =>
              r.url.path == '/auth/me' ? ok(session('old')) : failure(status),
        ),
      );
      if (status == 404) {
        await api.restore();
        expect(api.profileLoaded, isTrue);
        expect(api.driver, isNull);
      } else {
        await expectLater(api.restore(), throwsA(isA<ApiException>()));
        expect(api.profileLoaded, isFalse);
      }
      api.dispose();
    }
  });
  test('late refresh cannot restore a cleared session', () async {
    final store = MemoryStore()..value = jsonEncode(session('old'));
    final gate = Completer<void>();
    final entered = Completer<void>();
    final api = DriverController(
      baseUrl: 'https://example.test',
      store: store,
      client: MockClient((r) async {
        if (r.url.path == '/auth/me') return ok(session('old'));
        if (r.url.path == '/drivers/me') return failure(404);
        if (r.url.path == '/auth/refresh') {
          entered.complete();
          await gate.future;
          return ok(session('new'));
        }
        return failure(401);
      }),
    );
    addTearDown(api.dispose);
    await api.restore();
    final request = api.request('GET', 'protected');
    final assertion = expectLater(request, throwsA(isA<ApiException>()));
    await entered.future;
    await api.clear();
    gate.complete();
    await assertion;
    expect(api.signedIn, isFalse);
    expect(store.value, isNull);
  });
}
