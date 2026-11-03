// Isolated visual fixture entrypoint; production main.dart never imports this file.
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:transconnect_driver_app/app/driver_app.dart';
import 'package:transconnect_driver_app/app/session/driver_controller.dart';
import 'package:transconnect_driver_app/core/storage/token_store.dart';

class PreviewStore implements TokenStore {
  String? value;
  PreviewStore(this.value);
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

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final identity = {
    'accountGroup': 'Operator',
    'accessToken': 'fixture-only',
    'refreshToken': 'fixture-only',
    'fullName': 'Người dùng xem trước',
    'email': 'preview@example.invalid',
    'emailVerified': true,
  };
  final points = [
    {
      'id': 'fixture-1',
      'name': 'Bến xe Miền Đông mới',
      'addressDetail': 'Đường Hoàng Hữu Nam, TP. Hồ Chí Minh',
      'type': 'BusStation',
      'latitude': 10.879,
      'longitude': 106.814,
      'version': 1,
      'accessInstructions': 'Dữ liệu minh họa để kiểm tra giao diện.',
    },
    {
      'id': 'fixture-2',
      'name': 'Bến xe Miền Tây',
      'addressDetail': 'Đường Kinh Dương Vương, TP. Hồ Chí Minh',
      'type': 'BusStation',
      'latitude': 10.740,
      'longitude': 106.619,
      'version': 1,
    },
  ];
  final api = DriverController(
    baseUrl: 'https://preview.invalid',
    store: PreviewStore(
      const bool.fromEnvironment('PREVIEW_SIGNED_IN', defaultValue: true)
          ? jsonEncode(identity)
          : null,
    ),
    client: MockClient((request) async {
      Object? data = identity;
      if (request.url.path == '/drivers/me') {
        return http.Response(
          jsonEncode({'succeeded': false, 'message': 'Chưa có hồ sơ'}),
          404,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }
      if (request.url.path == '/locations/shared') {
        final query = (request.url.queryParameters['search'] ?? '')
            .toLowerCase();
        final filtered = points
            .where((p) => p['name'].toString().toLowerCase().contains(query))
            .toList();
        data = {
          'items': filtered,
          'pageNumber': 1,
          'pageSize': 20,
          'totalRecords': filtered.length,
          'totalPages': filtered.isEmpty ? 0 : 1,
        };
      }
      return http.Response(
        jsonEncode({'succeeded': true, 'data': data}),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    }),
  );
  runApp(DriverApp(api: api));
}
