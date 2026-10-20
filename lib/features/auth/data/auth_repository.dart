import '../../../core/network/json.dart';
import '../../../core/session/session_client.dart';
import '../models/current_user.dart';

class AuthRepository {
  final SessionClient session;
  AuthRepository(this.session);
  Future<void> uploadAvatar(List<int> bytes, String fileName) =>
      session.request<void>(
        'POST',
        'auth/me/avatar',
        fileBytes: bytes,
        fileName: fileName,
        decode: (_) {},
      );
  Future<CurrentUser> updateProfile(String name, String phone) =>
      session.request(
        'PUT',
        'auth/me',
        body: {'fullName': name, 'phoneNumber': phone.isEmpty ? null : phone},
        decode: CurrentUser.fromJson,
      );
  Future<void> changePassword(String current, String next) =>
      session.request<void>(
        'POST',
        'auth/change-password',
        body: {'currentPassword': current, 'newPassword': next},
        decode: (_) {},
      );
  Future<CurrentUser> currentUser() =>
      session.request('GET', 'auth/me', decode: CurrentUser.fromJson);
  Future<void> authenticate(String action, Json body) =>
      session.authenticate(action, body);
  Future<void> publicAction(String action, Json body) => session.request<void>(
    'POST',
    'auth/$action',
    body: {...body, 'accountGroup': session.accountGroup},
    authenticated: false,
    decode: (_) {},
  );
}
