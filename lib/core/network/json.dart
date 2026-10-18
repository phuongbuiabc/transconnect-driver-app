import '../errors/api_exception.dart';

typedef Json = Map<String, dynamic>;
typedef Decoder<T> = T Function(Object? value);

Json decodeObject(Object? value) {
  if (value is Map<String, dynamic>) return value;
  throw ApiException(
    'Máy chủ trả về dữ liệu không đúng định dạng.',
    code: 'INVALID_RESPONSE',
  );
}

List<T> decodeList<T>(Object? value, Decoder<T> decode) {
  if (value is! List) {
    throw ApiException(
      'Máy chủ trả về danh sách không hợp lệ.',
      code: 'INVALID_RESPONSE',
    );
  }
  return List.unmodifiable(value.map(decode));
}

String requiredString(Json json, String key) {
  final value = json[key];
  if (value is String && value.isNotEmpty) return value;
  throw ApiException('Phản hồi thiếu trường $key.', code: 'INVALID_RESPONSE');
}
