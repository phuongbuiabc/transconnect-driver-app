import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../errors/api_exception.dart';
import '../network/api_client.dart';
import '../network/json.dart';
import '../storage/token_store.dart';
import 'auth_session.dart';

/// Owns token persistence, rotation and account-generation boundaries.
class SessionClient extends ChangeNotifier {
  final ApiClient transport;
  final TokenStore store;
  final String accountGroup;
  AuthSession? _session;
  int _generation = 0;
  Future<void>? _refreshing;
  int? _refreshGeneration;
  Future<void> _storageQueue = Future.value();
  bool _disposed = false;
  SessionClient({
    required this.transport,
    required this.store,
    required this.accountGroup,
  });
  bool get signedIn => _session != null;
  int get generation => _generation;
  void _changed() {
    if (!_disposed) notifyListeners();
  }

  AuthSession _decode(Object? value) {
    final session = AuthSession.fromJson(value);
    if (session.accountGroup != accountGroup) {
      throw ApiException(
        'Tài khoản không thuộc nhóm $accountGroup.',
        status: 403,
      );
    }
    return session;
  }

  Future<void> _persist(int generation) {
    final task = _storageQueue.catchError((Object _) {}).then((_) async {
      if (generation != _generation) return;
      if (_session == null) {
        await store.clear();
      } else {
        await store.write(jsonEncode(_session!.toJson()));
      }
    });
    _storageQueue = task;
    return task;
  }

  Future<void> restore() async {
    final started = _generation;
    final raw = await store.read();
    if (started != _generation || raw == null) return;
    try {
      _session = _decode(jsonDecode(raw));
    } catch (_) {
      await clear();
      return;
    }
    _changed();
  }

  Future<void> authenticate(String action, Json body) async {
    final started = ++_generation;
    _session = null;
    _changed();
    await _persist(started);
    final result = _decode(
      await transport.send('POST', 'auth/$action', {
        ...body,
        'accountGroup': accountGroup,
      }, null),
    );
    if (started != _generation) return;
    _session = result;
    try {
      await _persist(started);
    } catch (_) {
      if (started == _generation) await clear();
      throw ApiException('Không lưu được phiên an toàn. Vui lòng thử lại.');
    }
    _changed();
  }

  Future<T> request<T>(
    String method,
    String path, {
    required Decoder<T> decode,
    Json? body,
    bool authenticated = true,
  }) async {
    final started = _generation;
    final token = _session?.accessToken;
    if (authenticated && token == null) {
      throw ApiException('Vui lòng đăng nhập.', status: 401);
    }
    Object? result;
    try {
      result = await transport.send(
        method,
        path,
        body,
        authenticated ? token : null,
      );
    } on ApiException catch (error) {
      if (!authenticated || error.status != 401 || started != _generation) {
        rethrow;
      }
      if (_session?.accessToken == token) await _refresh(started);
      _assertCurrent(started);
      final retryToken = _session!.accessToken;
      try {
        result = await transport.send(method, path, body, retryToken);
      } on ApiException catch (retryError) {
        if (retryError.status == 401 &&
            started == _generation &&
            _session?.accessToken == retryToken) {
          await clear();
        }
        rethrow;
      }
    }
    if (authenticated) _assertCurrent(started);
    return decode(result);
  }

  void _assertCurrent(int started) {
    if (started != _generation || _session == null) {
      throw ApiException('Phiên đăng nhập đã thay đổi.', status: 401);
    }
  }

  Future<void> _refresh(int started) async {
    _assertCurrent(started);
    if (_refreshing != null && _refreshGeneration == started) {
      return _refreshing;
    }
    final future = () async {
      try {
        final next = _decode(
          await transport.send('POST', 'auth/refresh', {
            'refreshToken': _session!.refreshToken,
          }, null),
        );
        _assertCurrent(started);
        _session = next;
        await _persist(started);
      } on ApiException catch (error) {
        if (started == _generation && [400, 401, 403].contains(error.status)) {
          await clear();
        }
        rethrow;
      }
    }();
    _refreshing = future;
    _refreshGeneration = started;
    try {
      await future;
    } finally {
      if (identical(_refreshing, future)) {
        _refreshing = null;
        _refreshGeneration = null;
      }
    }
  }

  Future<void> logout() async {
    final started = _generation;
    try {
      if (_refreshGeneration == started) await _refreshing;
    } catch (_) {}
    if (started != _generation) return;
    try {
      if (_session == null) return;
      try {
        await transport.send('POST', 'auth/logout', {
          'refreshToken': _session!.refreshToken,
        }, _session!.accessToken);
      } on ApiException catch (error) {
        if (error.status != 401) rethrow;
        await _refresh(started);
        _assertCurrent(started);
        await transport.send('POST', 'auth/logout', {
          'refreshToken': _session!.refreshToken,
        }, _session!.accessToken);
      }
    } finally {
      if (started == _generation) await clear();
    }
  }

  Future<void> clear() async {
    final started = ++_generation;
    _session = null;
    _changed();
    await _persist(started);
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    transport.dispose();
    super.dispose();
  }
}
