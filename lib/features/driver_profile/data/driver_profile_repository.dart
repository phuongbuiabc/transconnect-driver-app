import 'package:transconnect_driver_app/core/network/api_request.dart';
import 'package:transconnect_driver_app/core/network/json.dart';

class DriverProfileRepository {
  DriverProfileRepository(this.request);
  final ApiRequest request;
  Future<Json> current() => request('GET', 'drivers/me');
  Future<Json> submit(String fullName) =>
      request('POST', 'drivers', body: {'fullName': fullName});
}
