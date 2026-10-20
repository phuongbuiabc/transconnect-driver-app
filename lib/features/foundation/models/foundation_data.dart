import '../../../core/network/json.dart';

class Collaboration {
  final String id, organizationId, organizationName;
  final String? acceptedAt, endedAt, revokedAt;
  const Collaboration(
    this.id,
    this.organizationId,
    this.organizationName,
    this.acceptedAt,
    this.endedAt,
    this.revokedAt,
  );
  factory Collaboration.fromJson(Object? value) {
    final json = decodeObject(value);
    return Collaboration(
      requiredString(json, 'id'),
      requiredString(json, 'organizationId'),
      requiredString(json, 'organizationName'),
      json['acceptedAt'] as String?,
      json['endedAt'] as String?,
      json['revokedAt'] as String?,
    );
  }
}

class ReceivedInvitation {
  final String id, organizationName, role, expiresAt;
  final String? acceptedAt, revokedAt;
  const ReceivedInvitation(
    this.id,
    this.organizationName,
    this.role,
    this.expiresAt,
    this.acceptedAt,
    this.revokedAt,
  );
  factory ReceivedInvitation.fromJson(Object? value) {
    final json = decodeObject(value);
    return ReceivedInvitation(
      requiredString(json, 'id'),
      requiredString(json, 'organizationName'),
      requiredString(json, 'role'),
      requiredString(json, 'expiresAt'),
      json['acceptedAt'] as String?,
      json['revokedAt'] as String?,
    );
  }
}

class ProfileReview {
  final String id, status, createdAt;
  final String? note;
  const ProfileReview(this.id, this.status, this.createdAt, this.note);
  factory ProfileReview.fromJson(Object? value) {
    final json = decodeObject(value);
    return ProfileReview(
      requiredString(json, 'id'),
      requiredString(json, 'status'),
      requiredString(json, 'createdAt'),
      json['note'] as String?,
    );
  }
}

class DocumentVersion {
  final String id, status;
  final int version;
  const DocumentVersion(this.id, this.status, this.version);
  factory DocumentVersion.fromJson(Object? value) {
    final json = decodeObject(value),
        file = decodeObject(decodeObject(value)['file']);
    return DocumentVersion(
      requiredString(file, 'id'),
      requiredString(file, 'status'),
      json['versionNumber'] as int,
    );
  }
}

class DriverContact {
  final String? phone, address;
  const DriverContact(this.phone, this.address);
  factory DriverContact.fromJson(Object? value) {
    final json = decodeObject(value);
    return DriverContact(
      json['contactPhone'] as String?,
      json['contactAddress'] as String?,
    );
  }
}
