import '../../../core/session/session_client.dart';
import '../models/engagement.dart';

class InvitationRepository {
  final SessionClient session;
  InvitationRepository(this.session);
  Future<Engagement> accept(String token) => session.request(
    'POST',
    'drivers/invitations/accept',
    body: {'token': token},
    decode: Engagement.fromJson,
  );
}
