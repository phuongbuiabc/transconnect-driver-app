import 'package:flutter/foundation.dart';

abstract final class AppConfig {
  static const _override = String.fromEnvironment('API_BASE_URL');
  static String get apiBaseUrl => resolveBaseUrl(
    override: _override,
    isWeb: kIsWeb,
    platform: defaultTargetPlatform,
  );

  static String resolveBaseUrl({
    required String override,
    required bool isWeb,
    required TargetPlatform platform,
  }) {
    if (override.isNotEmpty) return override;
    return !isWeb && platform == TargetPlatform.android
        ? 'http://10.0.2.2:5267'
        : 'http://localhost:5267';
  }
}
