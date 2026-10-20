import 'package:flutter/foundation.dart';
import '../../../../core/errors/api_exception.dart';
import '../../data/driver_profile_repository.dart';
import '../../models/driver_profile.dart';

class DriverProfileController extends ChangeNotifier {
  final DriverProfileRepository repository;
  DriverProfile? _profile;
  DriverProfile? get profile => _profile;
  int _revision = 0;
  DriverProfileController(this.repository);
  Future<void> load() async {
    final started = ++_revision;
    DriverProfile? value;
    try {
      value = await repository.current();
    } on ApiException catch (error) {
      if (error.status != 404) rethrow;
    }
    if (started != _revision) return;
    _profile = value;
    notifyListeners();
  }

  Future<void> submit(String fullName) async {
    final started = ++_revision;
    final value = _profile?.reviewStatus == 'Rejected'
        ? await repository.resubmit(fullName)
        : await repository.submit(fullName);
    if (started != _revision) return;
    _profile = value;
    notifyListeners();
  }

  void clear() {
    _revision++;
    _profile = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _revision++;
    super.dispose();
  }
}
