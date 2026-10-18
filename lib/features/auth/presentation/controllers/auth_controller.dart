import 'package:flutter/foundation.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../core/network/json.dart';
import '../../../../core/session/session_client.dart';
import '../../data/auth_repository.dart';
import '../../models/current_user.dart';

class AuthController extends ChangeNotifier {
  final SessionClient session;
  late final AuthRepository auth = AuthRepository(session);
  CurrentUser? _user;
  CurrentUser? get user => _user;
  bool profileLoaded = false;
  bool _disposed = false;
  AuthController(this.session) {
    session.addListener(sessionChanged);
  }
  bool get signedIn => session.signedIn;
  bool get verified => user?.emailVerified == true;
  @protected
  void changed() {
    if (!_disposed) notifyListeners();
  }

  @protected
  void sessionChanged() {
    if (!signedIn) {
      _user = null;
      profileLoaded = false;
    }
    changed();
  }

  Future<void> restore() async {
    await session.restore();
    if (signedIn) await load();
  }

  Future<void> load() async {
    final started = session.generation;
    final current = await auth.currentUser();
    if (started != session.generation) return;
    if (current.accountGroup != session.accountGroup) {
      await clear();
      throw ApiException('Tài khoản không đúng nhóm.', status: 403);
    }
    _user = current;
    profileLoaded = true;
    changed();
  }

  Future<void> authenticate(String action, Json body) async {
    await auth.authenticate(action, body);
    if (signedIn) await load();
  }

  Future<void> publicAction(String action, Json body) =>
      auth.publicAction(action, body);
  Future<void> verify(String code) async {
    final started = session.generation;
    await publicAction('verify-email', {'email': user!.email, 'code': code});
    if (started == session.generation && signedIn) await load();
  }

  Future<void> logout() => session.logout();
  Future<void> clear() => session.clear();

  @override
  void dispose() {
    _disposed = true;
    session.removeListener(sessionChanged);
    session.dispose();
    super.dispose();
  }
}
