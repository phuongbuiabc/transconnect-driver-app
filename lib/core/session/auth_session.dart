import '../network/json.dart';

class AuthSession {
  final String accessToken, refreshToken, accountGroup;
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.accountGroup,
  });
  factory AuthSession.fromJson(Object? value) {
    final json = decodeObject(value);
    return AuthSession(
      accessToken: requiredString(json, 'accessToken'),
      refreshToken: requiredString(json, 'refreshToken'),
      accountGroup: requiredString(json, 'accountGroup'),
    );
  }
  Json toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'accountGroup': accountGroup,
  };
}
