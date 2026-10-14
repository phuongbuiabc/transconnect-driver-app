import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:transconnect_driver_app/core/network/json.dart';
import 'package:transconnect_driver_app/core/errors/api_exception.dart';

class ApiClient {
  ApiClient({required this.client, required this.base});
  final http.Client client;
  final Uri base;
  Future<Json> send(
    String method,
    String path,
    Json? body,
    String? token,
  ) async {
    try {
      final response = await client
          .send(
            http.Request(method, base.resolve(path))
              ..headers.addAll({
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                if (token != null) 'Authorization': 'Bearer $token',
              })
              ..body = body == null ? '' : jsonEncode(body),
          )
          .timeout(const Duration(seconds: 20));
      final raw = await response.stream.bytesToString().timeout(
        const Duration(seconds: 20),
      );
      Json envelope;
      try {
        envelope = jsonDecode(raw) as Json;
      } catch (_) {
        throw ApiException(
          'Máy chủ trả về dữ liệu không hợp lệ.',
          status: response.statusCode,
        );
      }
      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          envelope['succeeded'] != true) {
        final errors = envelope['errors'];
        final details = errors is Map
            ? errors.values.expand((v) => v is List ? v : [v]).join('\n')
            : '';
        throw ApiException(
          details.isNotEmpty
              ? details
              : (envelope['message'] as String? ?? 'Không thể xử lý yêu cầu.'),
          status: response.statusCode,
          code: envelope['errorCode'] as String?,
        );
      }
      return envelope['data'] is Map
          ? Map<String, dynamic>.from(envelope['data'] as Map)
          : {};
    } on TimeoutException {
      throw ApiException('Kết nối quá thời gian. Vui lòng thử lại.');
    } on http.ClientException {
      throw ApiException(
        'Không kết nối được máy chủ. Kiểm tra mạng và thử lại.',
      );
    }
  }
}
