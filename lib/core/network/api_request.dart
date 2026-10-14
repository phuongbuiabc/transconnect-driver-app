import 'json.dart';

typedef ApiRequest =
    Future<Json> Function(
      String method,
      String path, {
      Json? body,
      bool authenticated,
    });
