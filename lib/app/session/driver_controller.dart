import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:transconnect_driver_app/core/errors/api_exception.dart';
import 'package:transconnect_driver_app/core/network/json.dart';
import 'package:transconnect_driver_app/core/network/api_client.dart';
import 'package:transconnect_driver_app/core/storage/token_store.dart';
import 'package:transconnect_driver_app/core/storage/secure_token_store.dart';
import 'package:transconnect_driver_app/features/auth/data/auth_repository.dart';
import 'package:transconnect_driver_app/features/driver_profile/data/driver_profile_repository.dart';
import 'package:transconnect_driver_app/features/invitations/data/invitation_repository.dart';

class DriverController extends ChangeNotifier {
  final http.Client client;
  final TokenStore store;
  final Uri base;
  late final ApiClient transport = ApiClient(client: client, base: base);
  late final AuthRepository auth = AuthRepository(request);
  late final DriverProfileRepository profiles = DriverProfileRepository(
    request,
  );
  late final InvitationRepository invitations = InvitationRepository(request);
  Json? _session;
  Json? user;
  Json? driver;
  Json? receipt;
  bool profileLoaded = false;
  int _generation = 0;
  Future<void>? _refreshing;
  Future<void> _storageQueue = Future.value();
  DriverController({
    required String baseUrl,
    http.Client? client,
    TokenStore? store,
  }) : base = Uri.parse(baseUrl.endsWith('/') ? baseUrl : '$baseUrl/'),
       client = client ?? http.Client(),
       store = store ?? SecureTokenStore() {
    if (!base.hasAuthority ||
        !['https', 'http'].contains(base.scheme) ||
        base.hasQuery ||
        base.hasFragment) {
      throw ArgumentError(
        'API_BASE_URL must be an absolute HTTP(S) URL without query or fragment.',
      );
    }
  }
  bool get signedIn => _session != null;
  bool get verified => user?['emailVerified'] == true;
  bool get canAccept => verified && driver?['reviewStatus'] == 'Approved';

  Future<void> _persist(int epoch) {
    final task = _storageQueue.catchError((Object _) {}).then((_) async {
      if (epoch != _generation) return;
      if (_session == null) {
        await store.clear();
      } else {
        await store.write(jsonEncode(_session));
      }
    });
    _storageQueue = task;
    return task;
  }

  Future<Json> _send(String method, String path, Json? body, String? token) =>
      transport.send(method, path, body, token);

  Future<Json> request(
    String method,
    String path, {
    Json? body,
    bool authenticated = true,
  }) async {
    final epoch = _generation;
    final token = _session?['accessToken'] as String?;
    if (authenticated && token == null) {
      throw ApiException('Vui lòng đăng nhập.', status: 401);
    }
    try {
      final result = await _send(
        method,
        path,
        body,
        authenticated ? token : null,
      );
      if (authenticated && epoch != _generation) {
        throw ApiException('Phiên đăng nhập đã thay đổi.');
      }
      return result;
    } on ApiException catch (error) {
      if (!authenticated || error.status != 401 || epoch != _generation) {
        rethrow;
      }
      if (_session?['accessToken'] == token) await _refresh(epoch);
      if (epoch != _generation || _session == null) {
        throw ApiException('Phiên đăng nhập đã kết thúc.', status: 401);
      }
      final result = await _send(
        method,
        path,
        body,
        _session!['accessToken'] as String,
      );
      if (epoch != _generation) {
        throw ApiException('Phiên đăng nhập đã thay đổi.');
      }
      return result;
    }
  }

  Future<void> _refresh(int epoch) async {
    if (_refreshing != null) return _refreshing;
    final future = () async {
      try {
        final refresh = _session?['refreshToken'];
        if (refresh == null) {
          throw ApiException('Vui lòng đăng nhập lại.', status: 401);
        }
        final next = await _send('POST', 'auth/refresh', {
          'refreshToken': refresh,
        }, null);
        _validateSession(next);
        if (epoch != _generation) return;
        _session = next;
        await _persist(epoch);
      } on ApiException catch (error) {
        if (epoch == _generation && [400, 401, 403].contains(error.status)) {
          await clear();
        }
        rethrow;
      }
    }();
    _refreshing = future;
    try {
      await future;
    } finally {
      if (identical(_refreshing, future)) _refreshing = null;
    }
  }

  void _validateSession(Json data) {
    if (data['accountGroup'] != 'Operator' ||
        data['accessToken'] is! String ||
        data['refreshToken'] is! String) {
      throw ApiException(
        'Ứng dụng chỉ dành cho tài khoản đối tác tài xế.',
        status: 403,
      );
    }
  }

  Future<void> restore() async {
    final raw = await store.read();
    if (raw == null) return;
    try {
      final saved = jsonDecode(raw) as Json;
      _validateSession(saved);
      _session = saved;
    } catch (_) {
      await clear();
      return;
    }
    await load();
  }

  Future<void> authenticate(String action, Json body) async {
    final epoch = ++_generation;
    final result = await _send('POST', 'auth/$action', {
      ...body,
      'accountGroup': 'Operator',
    }, null);
    _validateSession(result);
    if (epoch != _generation) return;
    _session = result;
    user = result;
    driver = null;
    receipt = null;
    profileLoaded = false;
    await _persist(epoch);
    notifyListeners();
    await load();
  }

  Future<void> load() async {
    final epoch = _generation;
    final current = await auth.currentUser();
    if (current['accountGroup'] != 'Operator') {
      await clear();
      throw ApiException('Tài khoản không thuộc nhóm Operator.');
    }
    Json? profile;
    if (current['emailVerified'] == true) {
      try {
        profile = await profiles.current();
      } on ApiException catch (e) {
        if (e.status != 404) rethrow;
      }
    }
    if (epoch != _generation) return;
    user = current;
    driver = profile;
    profileLoaded = true;
    notifyListeners();
  }

  Future<void> publicAction(String action, Json body) async {
    await auth.publicAction(action, body);
  }

  Future<void> verify(String code) async {
    await publicAction('verify-email', {'email': user!['email'], 'code': code});
    await load();
  }

  Future<void> submit(String fullName) async {
    final epoch = _generation;
    final result = await profiles.submit(fullName);
    if (epoch != _generation) return;
    driver = result;
    profileLoaded = true;
    notifyListeners();
  }

  Future<void> accept(String token) async {
    if (!canAccept) {
      throw ApiException(
        'Cần xác thực email và hồ sơ được duyệt trước khi nhận lời mời.',
      );
    }
    final epoch = _generation;
    final result = await invitations.accept(token);
    if (epoch != _generation) return;
    receipt = result;
    notifyListeners();
  }

  Future<void> logout() async {
    // Await an in-flight rotation before revoking the newest refresh token.
    try {
      await _refreshing;
    } catch (_) {}
    final epoch = _generation;
    try {
      if (_session == null) return;
      try {
        await _send('POST', 'auth/logout', {
          'refreshToken': _session!['refreshToken'],
        }, _session!['accessToken'] as String);
      } on ApiException catch (error) {
        if (error.status != 401) rethrow;
        await _refresh(epoch);
        if (epoch == _generation && _session != null) {
          await _send('POST', 'auth/logout', {
            'refreshToken': _session!['refreshToken'],
          }, _session!['accessToken'] as String);
        }
      }
    } finally {
      if (epoch == _generation) await clear();
    }
  }

  Future<void> clear() async {
    final epoch = ++_generation;
    _session = null;
    user = null;
    driver = null;
    receipt = null;
    profileLoaded = false;
    notifyListeners();
    await _persist(epoch);
  }

  @override
  void dispose() {
    client.close();
    super.dispose();
  }
}
