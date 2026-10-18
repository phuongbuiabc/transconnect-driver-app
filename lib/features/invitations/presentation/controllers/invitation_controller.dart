import 'package:flutter/foundation.dart';
import '../../data/invitation_repository.dart';
import '../../models/engagement.dart';

class InvitationController extends ChangeNotifier {
  final InvitationRepository repository;
  Engagement? _receipt;
  Engagement? get receipt => _receipt;
  int _revision = 0;
  InvitationController(this.repository);
  Future<void> accept(String token) async {
    final started = ++_revision;
    final value = await repository.accept(token);
    if (started != _revision) return;
    _receipt = value;
    notifyListeners();
  }

  void clear() {
    _revision++;
    _receipt = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _revision++;
    super.dispose();
  }
}
