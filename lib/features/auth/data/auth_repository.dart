import '../../../core/network/json.dart';
import '../../../core/session/session_client.dart';
import '../models/current_user.dart';

class AuthRepository {
  final SessionClient session;
  AuthRepository(this.session);
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
