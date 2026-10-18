import '../../../core/session/session_client.dart';
import '../models/driver_profile.dart';

class DriverProfileRepository {
  final SessionClient session;
  DriverProfileRepository(this.session);
  Future<DriverProfile> current() =>
      session.request('GET', 'drivers/me', decode: DriverProfile.fromJson);
  Future<DriverProfile> submit(String fullName) => session.request(
    'POST',
    'drivers',
    body: {'fullName': fullName},
    decode: DriverProfile.fromJson,
  );
}
