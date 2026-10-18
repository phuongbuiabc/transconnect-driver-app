import 'package:transconnect_driver_app/core/storage/token_store.dart';

class MemoryStore implements TokenStore {
  String? value;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String v) async {
    value = v;
  }

  @override
  Future<void> clear() async {
    value = null;
  }
}
