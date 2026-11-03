import '../../../core/network/json.dart';

class TransportPlace {
  final String id, name, address, type;
  final String? accessInstructions;
  final double? latitude, longitude;
  final int version;
  TransportPlace.fromJson(Object? value)
    : id = requiredString(decodeObject(value), 'id'),
      name = requiredString(decodeObject(value), 'name'),
      address = requiredString(decodeObject(value), 'addressDetail'),
      type = requiredString(decodeObject(value), 'type'),
      accessInstructions = decodeObject(value)['accessInstructions'] as String?,
      latitude = (decodeObject(value)['latitude'] as num?)?.toDouble(),
      longitude = (decodeObject(value)['longitude'] as num?)?.toDouble(),
      version = decodeObject(value)['version'] as int;
  bool get hasCoordinates =>
      latitude != null &&
      longitude != null &&
      latitude!.isFinite &&
      longitude!.isFinite &&
      latitude!.abs() <= 90 &&
      longitude!.abs() <= 180;
}
