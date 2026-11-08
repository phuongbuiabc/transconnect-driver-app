// The backend serialises UTC DateTime values without an offset, so treat a
// bare timestamp as UTC instead of device-local time.
DateTime? parseServerTime(String? value) {
  if (value == null || value.isEmpty) return null;
  final hasZone = RegExp(r'(Z|[+-]\d{2}:?\d{2})$').hasMatch(value);
  return DateTime.tryParse(hasZone ? value : '${value}Z')?.toLocal();
}

String formatDate(String? value) {
  final time = parseServerTime(value);
  if (time == null) return '—';
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(time.day)}/${two(time.month)}/${time.year}';
}
