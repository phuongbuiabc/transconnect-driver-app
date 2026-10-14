import 'package:transconnect_driver_app/core/network/api_request.dart';
import 'package:transconnect_driver_app/core/network/json.dart';

class InvitationRepository {
  InvitationRepository(this.request);
  final ApiRequest request;
  Future<Json> accept(String token) =>
      request('POST', 'drivers/invitations/accept', body: {'token': token});
}
