import 'package:transconnect_driver_app/core/network/api_request.dart';
import 'package:transconnect_driver_app/core/network/json.dart';

class AuthRepository {
  AuthRepository(this.request);
  final ApiRequest request;
  Future<Json> currentUser() => request('GET', 'auth/me');
  Future<Json> publicAction(String action, Json body) => request(
    'POST',
    'auth/$action',
    body: {...body, 'accountGroup': 'Operator'},
    authenticated: false,
  );
}
