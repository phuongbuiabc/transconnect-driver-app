import '../../../core/network/json.dart';

class CurrentUser {
  final String accountGroup, email, fullName;
  final String? accountId, phoneNumber, avatarUrl;
  final bool emailVerified;
  final List<String> roles, permissions;
  const CurrentUser({
    required this.accountGroup,
    required this.email,
    required this.fullName,
    required this.emailVerified,
    this.accountId,
    this.phoneNumber,
    this.avatarUrl,
    this.roles = const [],
    this.permissions = const [],
  });
  factory CurrentUser.fromJson(Object? value) {
    final json = decodeObject(value);
    return CurrentUser(
      accountGroup: requiredString(json, 'accountGroup'),
      email: requiredString(json, 'email'),
      fullName: requiredString(json, 'fullName'),
      accountId: (json['accountId'] ?? json['userId']) as String?,
      phoneNumber: json['phoneNumber'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      emailVerified: json['emailVerified'] == true,
      roles: List.unmodifiable((json['roles'] as List? ?? []).cast<String>()),
      permissions: List.unmodifiable(
        (json['permissions'] as List? ?? []).cast<String>(),
      ),
    );
  }
}
