import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:transconnect_driver_app/core/errors/api_exception.dart';
import 'package:transconnect_driver_app/core/network/api_client.dart';
import 'package:transconnect_driver_app/core/session/session_client.dart';
import 'package:transconnect_driver_app/core/storage/token_store.dart';

class Store implements TokenStore {
  String? value;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String next) async {
    value = next;
  }

  @override
  Future<void> clear() async {
    value = null;
  }
}

Map<String, Object?> tokens(String value) => {
  'accessToken': value,
  'refreshToken': 'refresh-$value',
  'accountGroup': 'Customer',
};
http.Response ok(Object? data) =>
    http.Response(jsonEncode({'succeeded': true, 'data': data}), 200);
void main() {
  test(
    'multipart recreates the payload after refresh and retains the same account',
    () async {
      var uploads = 0, refreshes = 0;
      final store = Store()..value = jsonEncode(tokens('old'));
      final session = SessionClient(
        accountGroup: 'Customer',
        store: store,
        transport: ApiClient(
          baseUrl: 'http://localhost:5267',
          client: MockClient((request) async {
            if (request.url.path == '/auth/refresh') {
              refreshes++;
              return ok(tokens('new'));
            }
            uploads++;
            expect(
              request.headers['content-type'],
              startsWith('multipart/form-data; boundary='),
            );
            expect(request.body, contains('ABC'));
            expect(request.body, contains('SyntheticDataConfirmed'));
            return request.headers['Authorization'] == 'Bearer old'
                ? http.Response(jsonEncode({'succeeded': false}), 401)
                : ok({'id': 'saved'});
          }),
        ),
      );
      addTearDown(session.dispose);
      await session.restore();
      await session.request<void>(
        'POST',
        'upload',
        fileBytes: [65, 66, 67],
        fileName: 'demo.png',
        fields: {'SyntheticDataConfirmed': 'true'},
        decode: (_) {},
      );
      expect(uploads, 2);
      expect(refreshes, 1);
      expect(session.signedIn, isTrue);
    },
  );
  test(
    'private binary payload stays bytes and forbidden JSON stays an API error',
    () async {
      var forbidden = false;
      final transport = ApiClient(
        baseUrl: 'http://localhost:5267',
        client: MockClient((request) async {
          expect(request.headers['Authorization'], 'Bearer private');
          return forbidden
              ? http.Response(
                  jsonEncode({'succeeded': false, 'message': 'Denied'}),
                  403,
                )
              : http.Response.bytes([0, 255, 10], 200);
        }),
      );
      addTearDown(transport.dispose);
      expect(
        await transport.send('GET', 'download', null, 'private', binary: true),
        [0, 255, 10],
      );
      forbidden = true;
      await expectLater(
        transport.send('GET', 'download', null, 'private', binary: true),
        throwsA(isA<ApiException>().having((e) => e.status, 'status', 403)),
      );
    },
  );
}
