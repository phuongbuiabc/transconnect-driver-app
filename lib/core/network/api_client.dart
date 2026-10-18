import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../errors/api_exception.dart';
import 'json.dart';

/// Transport only. Authentication and rotation belong to SessionClient.
class ApiClient {
  final http.Client client;
  final Uri base;
  final Duration timeout;
  ApiClient({
    required String baseUrl,
    http.Client? client,
    this.timeout = const Duration(seconds: 20),
  }) : client = client ?? http.Client(),
       base = Uri.parse(baseUrl.endsWith('/') ? baseUrl : '$baseUrl/') {
    if (!base.hasAuthority ||
        !['http', 'https'].contains(base.scheme) ||
        base.hasQuery ||
        base.hasFragment ||
        base.userInfo.isNotEmpty) {
      throw ArgumentError(
        'API_BASE_URL must be an absolute HTTP(S) URL without credentials, query or fragment.',
      );
    }
  }
  Future<Object?> send(
    String method,
    String path,
    Json? body,
    String? token,
  ) async {
    final relative = Uri.parse(path);
    if (relative.hasScheme || relative.hasAuthority || relative.hasFragment) {
      throw ArgumentError(
        'API path must be relative to the configured backend.',
      );
    }
    try {
      final response = await client
          .send(
            http.Request(method, base.resolve(path))
              ..headers.addAll({
                'Accept': 'application/json',
                if (body != null) 'Content-Type': 'application/json',
                if (token != null) 'Authorization': 'Bearer $token',
              })
              ..body = body == null ? '' : jsonEncode(body),
          )
          .timeout(timeout);
      final raw = await response.stream.bytesToString().timeout(timeout);
      Json envelope;
      try {
        envelope = decodeObject(jsonDecode(raw));
      } catch (_) {
        throw ApiException(
          'Máy chủ trả về dữ liệu không hợp lệ.',
          status: response.statusCode,
          code: 'INVALID_RESPONSE',
        );
      }
      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          envelope['succeeded'] != true) {
        final fields = <String, List<String>>{};
        final errors = envelope['errors'];
        if (errors is Map) {
          for (final entry in errors.entries) {
            if (entry.key is String && entry.value is List) {
              fields[entry.key as String] = (entry.value as List)
                  .whereType<String>()
                  .toList();
            }
          }
        }
        throw ApiException(
          envelope['message'] is String
              ? envelope['message'] as String
              : 'Không thể xử lý yêu cầu.',
          status: response.statusCode,
          code: envelope['errorCode'] as String?,
          fields: fields,
        );
      }
      if (!envelope.containsKey('data')) {
        throw ApiException('Phản hồi thiếu dữ liệu.', code: 'INVALID_RESPONSE');
      }
      return envelope['data'];
    } on TimeoutException {
      throw ApiException('Kết nối quá thời gian. Vui lòng thử lại.');
    } on http.ClientException {
      throw ApiException(
        'Không kết nối được máy chủ. Kiểm tra mạng và thử lại.',
      );
    }
  }

  void dispose() => client.close();
}
