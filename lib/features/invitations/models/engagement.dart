import '../../../core/network/json.dart';

class Engagement {
  final String id, organizationId;
  const Engagement({required this.id, required this.organizationId});
  factory Engagement.fromJson(Object? value) {
    final json = decodeObject(value);
    return Engagement(
      id: requiredString(json, 'id'),
      organizationId: requiredString(json, 'organizationId'),
    );
  }
}
