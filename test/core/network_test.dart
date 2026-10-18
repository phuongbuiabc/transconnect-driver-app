import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:transconnect_driver_app/core/config/app_config.dart';
import 'package:transconnect_driver_app/core/errors/api_exception.dart';
import 'package:transconnect_driver_app/core/network/api_client.dart';
import 'package:transconnect_driver_app/core/network/json.dart';
import 'package:transconnect_driver_app/core/network/paged_result.dart';

void main() {
  test('transport preserves object, list, null and paged data', () async {
    for (final data in [
      <String, Object?>{'id': 'one'},
      [
        {'id': 'one'},
      ],
      null,
      {
        'items': [
          {'id': 'one'},
        ],
        'pageNumber': 1,
        'pageSize': 20,
        'totalRecords': 1,
        'totalPages': 1,
      },
    ]) {
      final api = ApiClient(
        baseUrl: 'http://localhost:5267',
        client: MockClient((request) async {
          expect(request.url.path, '/resource');
          expect(request.headers['Authorization'], 'Bearer token');
          return http.Response(
            jsonEncode({'succeeded': true, 'data': data}),
            200,
          );
        }),
      );
      addTearDown(api.dispose);
      expect(await api.send('GET', 'resource', null, 'token'), data);
    }
  });
  test(
    'repository decoders reject wrong shapes rather than empty fallbacks',
    () {
      expect(() => decodeObject([]), throwsA(isA<ApiException>()));
      expect(() => decodeList({}, decodeObject), throwsA(isA<ApiException>()));
      final page = PagedResult.fromJson({
        'items': [
          {'id': 'one'},
        ],
        'pageNumber': 1,
        'pageSize': 20,
        'totalRecords': 1,
        'totalPages': 1,
      }, decodeObject);
      expect(page.items.single['id'], 'one');
      expect(() => page.items.clear(), throwsUnsupportedError);
    },
  );
  test('field errors retain field names and general message', () async {
    final api = ApiClient(
      baseUrl: 'http://localhost:5267',
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({
            'succeeded': false,
            'message': 'Invalid',
            'errorCode': 'VALIDATION_ERROR',
            'errors': {
              'email': ['Required'],
              'name': ['Too long'],
            },
          }),
          400,
        ),
      ),
    );
    addTearDown(api.dispose);
    await expectLater(
      api.send('POST', 'auth/login', {}, null),
      throwsA(
        isA<ApiException>()
            .having((e) => e.message, 'message', 'Invalid')
            .having((e) => e.fields['email'], 'email', ['Required'])
            .having((e) => e.status, 'status', 400),
      ),
    );
  });
  test('non JSON response is an API failure with original status', () async {
    final api = ApiClient(
      baseUrl: 'http://localhost:5267',
      client: MockClient((_) async => http.Response('bad gateway', 502)),
    );
    addTearDown(api.dispose);
    await expectLater(
      api.send('GET', 'resource', null, null),
      throwsA(isA<ApiException>().having((e) => e.status, 'status', 502)),
    );
  });
  test('absolute API paths cannot send the bearer to another host', () async {
    final api = ApiClient(
      baseUrl: 'http://localhost:5267',
      client: MockClient((_) async {
        fail('No network request expected');
      }),
    );
    addTearDown(api.dispose);
    await expectLater(
      api.send('GET', 'https://another.example/resource', null, 'token'),
      throwsArgumentError,
    );
  });
  test('local backend defaults distinguish Android native from web', () {
    expect(
      AppConfig.resolveBaseUrl(
        override: '',
        isWeb: false,
        platform: TargetPlatform.android,
      ),
      'http://10.0.2.2:5267',
    );
    expect(
      AppConfig.resolveBaseUrl(
        override: '',
        isWeb: true,
        platform: TargetPlatform.android,
      ),
      'http://localhost:5267',
    );
    expect(
      AppConfig.resolveBaseUrl(
        override: 'http://192.168.1.10:5267',
        isWeb: false,
        platform: TargetPlatform.android,
      ),
      'http://192.168.1.10:5267',
    );
  });
}
