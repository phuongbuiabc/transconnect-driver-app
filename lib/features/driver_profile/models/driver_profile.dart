import '../../../core/network/json.dart';

class DriverProfile {
  final String id, fullName, reviewStatus;
  final String? reviewNote;
  const DriverProfile({
    required this.id,
    required this.fullName,
    required this.reviewStatus,
    this.reviewNote,
  });
  bool get isApproved => reviewStatus == 'Approved';
  factory DriverProfile.fromJson(Object? value) {
    final json = decodeObject(value);
    return DriverProfile(
      id: requiredString(json, 'id'),
      fullName: requiredString(json, 'fullName'),
      reviewStatus: requiredString(json, 'reviewStatus'),
      reviewNote: json['reviewNote'] as String?,
    );
  }
}
