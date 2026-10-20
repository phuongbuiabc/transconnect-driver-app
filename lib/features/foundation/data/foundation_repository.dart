import '../../../core/session/session_client.dart';
import '../models/foundation_data.dart';

class FoundationRepository {
  final SessionClient session;
  FoundationRepository(this.session);
  Future<List<T>> _list<T>(String path, T Function(Object?) decode) =>
      session.request(
        'GET',
        path,
        decode: (value) {
          if (value is! List) {
            throw const FormatException('Danh sách không hợp lệ.');
          }
          return value.map(decode).toList(growable: false);
        },
      );
  Future<List<Collaboration>> collaborations() =>
      _list('drivers/me/collaborations', Collaboration.fromJson);
  Future<List<ReceivedInvitation>> invitations() =>
      _list('operator/invitations', ReceivedInvitation.fromJson);
  Future<List<ProfileReview>> reviews(String id) =>
      _list('drivers/$id/reviews', ProfileReview.fromJson);
  Future<List<DocumentVersion>> documents(String id) => _list(
    'compliance/demo/profile-documents/Driver/$id/DriverLicense',
    DocumentVersion.fromJson,
  );
  Future<DriverContact> contact() =>
      session.request('GET', 'drivers/me', decode: DriverContact.fromJson);
  Future<void> updateContact(String phone, String address) =>
      session.request<void>(
        'PUT',
        'drivers/me/profile',
        body: {'contactPhone': phone, 'contactAddress': address},
        decode: (_) {},
      );
  Future<void> end(Collaboration item) => session.request<void>(
    'DELETE',
    'organizations/${item.organizationId}/drivers/${item.id}',
    decode: (_) {},
  );
  Future<void> upload(String id, List<int> bytes, String fileName) =>
      session.request<void>(
        'POST',
        'compliance/demo/profile-documents/Driver/$id/DriverLicense',
        fileBytes: bytes,
        fileName: fileName,
        fields: {'SyntheticDataConfirmed': 'true'},
        decode: (_) {},
      );
  Future<void> documentAction(
    String id,
    String action,
  ) => session.request<void>(
    action == 'delete' ? 'DELETE' : 'POST',
    'compliance/demo/profile-documents/versions/$id${action == 'delete' ? '' : '/$action'}',
    body: action == 'delete'
        ? null
        : action == 'simulate'
        ? <String, Object?>{'scenario': 'Success'}
        : <String, Object?>{'approved': true},
    decode: (_) {},
  );
  Future<List<int>> preview(String id) => session.request(
    'GET',
    'compliance/demo/profile-documents/versions/$id/download',
    binary: true,
    decode: (value) => (value as List<int>),
  );
}
