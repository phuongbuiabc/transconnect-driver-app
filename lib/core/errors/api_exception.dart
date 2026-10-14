class ApiException implements Exception {
  final String message;
  final int status;
  final String? code;
  ApiException(this.message, {this.status = 0, this.code});
  @override
  String toString() => message;
}
