import 'package:http/http.dart' as http;
import '../../core/network/api_client.dart';
import '../../core/session/session_client.dart';
import '../../core/storage/token_store.dart';
import '../../core/storage/secure_token_store.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/driver_profile/data/driver_profile_repository.dart';
import '../../features/driver_profile/models/driver_profile.dart';
import '../../features/driver_profile/presentation/controllers/driver_profile_controller.dart';
import '../../features/invitations/data/invitation_repository.dart';
import '../../features/invitations/presentation/controllers/invitation_controller.dart';

/// Composition of independent auth, profile and invitation controllers.
class DriverController extends AuthController {
  late final DriverProfileController profiles;
  late final InvitationController invitations;
  DriverController({
    required String baseUrl,
    http.Client? client,
    TokenStore? store,
  }) : super(
         SessionClient(
           transport: ApiClient(baseUrl: baseUrl, client: client),
           store: store ?? SecureTokenStore(),
           accountGroup: 'Operator',
         ),
       ) {
    profiles = DriverProfileController(DriverProfileRepository(session))
      ..addListener(changed);
    invitations = InvitationController(InvitationRepository(session))
      ..addListener(changed);
  }
  DriverProfile? get driver => profiles.profile;
  bool get canAccept => verified && driver?.isApproved == true;
  @override
  void sessionChanged() {
    if (!signedIn) {
      profiles.clear();
      invitations.clear();
    }
    super.sessionChanged();
  }

  @override
  Future<void> load() async {
    final started = session.generation;
    await super.load();
    if (started != session.generation || !signedIn) return;
    profileLoaded = false;
    try {
      if (verified) {
        await profiles.load();
      } else {
        profiles.clear();
      }
      if (started != session.generation) return;
      profileLoaded = true;
    } finally {
      changed();
    }
  }

  @override
  void dispose() {
    profiles.removeListener(changed);
    invitations.removeListener(changed);
    profiles.dispose();
    invitations.dispose();
    super.dispose();
  }
}
