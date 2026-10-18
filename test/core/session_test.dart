import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:transconnect_driver_app/core/network/api_client.dart';
import 'package:transconnect_driver_app/core/network/json.dart';
import 'package:transconnect_driver_app/core/session/session_client.dart';
import 'package:transconnect_driver_app/core/errors/api_exception.dart';
import '../helpers/memory_token_store.dart';

Json tokens(String token) => {
  'accountGroup': 'Operator',
  'accessToken': token,
  'refreshToken': 'r-$token',
};
http.Response ok(Object? data) =>
    http.Response(jsonEncode({'succeeded': true, 'data': data}), 200);
http.Response failure(int status) =>
    http.Response(jsonEncode({'succeeded': false}), status);

void main() {
  test('second 401 clears session and only retries once', () async {
    var calls = 0;
    final store = MemoryStore()..value = jsonEncode(tokens('old'));
    final session = SessionClient(
      accountGroup: 'Operator',
      store: store,
      transport: ApiClient(
        baseUrl: 'http://localhost:5267',
        client: MockClient((request) async {
          if (request.url.path == '/auth/refresh') return ok(tokens('new'));
          calls++;
          return failure(401);
        }),
      ),
    );
    addTearDown(session.dispose);
    await session.restore();
    await expectLater(
      session.request('GET', 'resource', decode: decodeObject),
      throwsA(isA<ApiException>()),
    );
    expect(calls, 2);
    expect(session.signedIn, false);
    expect(store.value, isNull);
  });
  test('temporary refresh failure preserves saved session', () async {
    final store = MemoryStore()..value = jsonEncode(tokens('old'));
    final session = SessionClient(
      accountGroup: 'Operator',
      store: store,
      transport: ApiClient(
        baseUrl: 'http://localhost:5267',
        client: MockClient(
          (request) async =>
              failure(request.url.path == '/auth/refresh' ? 503 : 401),
        ),
      ),
    );
    addTearDown(session.dispose);
    await session.restore();
    await expectLater(
      session.request('GET', 'resource', decode: decodeObject),
      throwsA(isA<ApiException>()),
    );
    expect(session.signedIn, true);
    expect(jsonDecode(store.value!)['accessToken'], 'old');
  });
  test(
    'new account refresh is independent from previous in-flight refresh',
    () async {
      final entered = Completer<void>(), release = Completer<void>();
      var refreshes = 0;
      final store = MemoryStore()..value = jsonEncode(tokens('old'));
      final session = SessionClient(
        accountGroup: 'Operator',
        store: store,
        transport: ApiClient(
          baseUrl: 'http://localhost:5267',
          client: MockClient((request) async {
            if (request.url.path == '/auth/login') return ok(tokens('new'));
            if (request.url.path == '/auth/refresh') {
              refreshes++;
              if (jsonDecode(request.body)['refreshToken'] == 'r-old') {
                entered.complete();
                await release.future;
                return ok(tokens('old-rotated'));
              }
              return ok(tokens('new-rotated'));
            }
            return request.headers['Authorization'] == 'Bearer new-rotated'
                ? ok({'new': true})
                : failure(401);
          }),
        ),
      );
      addTearDown(session.dispose);
      await session.restore();
      final old = session.request('GET', 'resource', decode: decodeObject);
      final rejected = expectLater(old, throwsA(isA<ApiException>()));
      await entered.future;
      await session.authenticate('login', {
        'email': 'new@example.test',
        'password': 'test-only',
      });
      expect(await session.request('GET', 'resource', decode: decodeObject), {
        'new': true,
      });
      release.complete();
      await rejected;
      expect(refreshes, 2);
      expect(jsonDecode(store.value!)['accessToken'], 'new-rotated');
    },
  );
}
