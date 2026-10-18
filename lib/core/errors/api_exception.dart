class ApiException implements Exception {
  final String message;
  final int status;
  final String? code;
  final Map<String, List<String>> fields;
  ApiException(
    this.message, {
    this.status = 0,
    this.code,
    Map<String, List<String>> fields = const {},
  }) : fields = Map.unmodifiable(
         fields.map(
           (key, value) => MapEntry(key, List<String>.unmodifiable(value)),
         ),
       );
  @override
  String toString() =>
      fields.isEmpty ? message : fields.values.expand((v) => v).join('\n');
}
