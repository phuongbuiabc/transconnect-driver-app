import 'json.dart';
import '../errors/api_exception.dart';

class PagedResult<T> {
  final List<T> items;
  final int pageNumber, pageSize, totalRecords, totalPages;
  const PagedResult({
    required this.items,
    required this.pageNumber,
    required this.pageSize,
    required this.totalRecords,
    required this.totalPages,
  });
  factory PagedResult.fromJson(Object? value, Decoder<T> decode) {
    final json = decodeObject(value);
    int number(String key, int minimum) {
      final n = json[key];
      if (n is int && n >= minimum) return n;
      throw ApiException(
        'Thông tin phân trang không hợp lệ.',
        code: 'INVALID_RESPONSE',
      );
    }

    return PagedResult(
      items: decodeList(json['items'], decode),
      pageNumber: number('pageNumber', 1),
      pageSize: number('pageSize', 1),
      totalRecords: number('totalRecords', 0),
      totalPages: number('totalPages', 0),
    );
  }
}
