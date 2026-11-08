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
  const driverStatus = String.fromEnvironment('PREVIEW_DRIVER');
  final accepted = <String>{};
  final now = DateTime.now().toUtc();
  String server(DateTime value) =>
      value.toIso8601String().replaceFirst('Z', '');
  final later = server(now.add(const Duration(days: 6)));
  final earlier = server(now.subtract(const Duration(days: 20)));
  final api = DriverController(
    baseUrl: 'https://preview.invalid',
    store: PreviewStore(
      const bool.fromEnvironment('PREVIEW_SIGNED_IN', defaultValue: true)
          ? jsonEncode(identity)
          : null,
    ),
    client: MockClient((request) async {
      Object? data = identity;
      final path = request.url.path;
      if (path == '/drivers/me') {
        if (driverStatus.isEmpty) {
          return http.Response(
            jsonEncode({'succeeded': false, 'message': 'Chưa có hồ sơ'}),
            404,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        data = {
          'id': 'fixture-driver',
          'fullName': identity['fullName'],
          'reviewStatus': driverStatus,
          'reviewNote': driverStatus == 'Rejected'
              ? 'Họ tên chưa khớp với giấy phép lái xe.'
              : null,
          'contactPhone': '0900000000',
          'contactAddress': 'Địa chỉ minh họa',
        };
      }
      if (path == '/drivers/me/collaborations') {
        data = [
          {
            'id': 'fixture-direct',
            'organizationId': 'fixture-org-1',
            'organizationName': 'Nhà xe minh họa A',
            'expiresAt': later,
            'acceptedAt': accepted.contains('fixture-direct') ? earlier : null,
            'endedAt': null,
            'revokedAt': null,
          },
          {
            'id': 'fixture-ended',
            'organizationId': 'fixture-org-3',
            'organizationName': 'Nhà xe minh họa C',
            'expiresAt': earlier,
            'acceptedAt': earlier,
            'endedAt': earlier,
            'revokedAt': null,
          },
        ];
      }
      if (path == '/operator/invitations') {
        data = [
          {
            'id': 'fixture-email',
            'organizationId': 'fixture-org-2',
            'organizationName': 'Nhà xe minh họa B',
            'role': 'Driver',
            'expiresAt': later,
            'acceptedAt': accepted.contains('fixture-email') ? earlier : null,
            'revokedAt': null,
            'email': identity['email'],
          },
        ];
      }
      if (path.endsWith('/reviews')) data = <Object?>[];
      if (path.startsWith('/compliance/')) data = <Object?>[];
      if (request.method == 'POST' && path.endsWith('/accept')) {
        accepted.add(path.split('/')[3]);
        data = {'id': 'fixture-engagement', 'organizationId': 'fixture-org'};
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
