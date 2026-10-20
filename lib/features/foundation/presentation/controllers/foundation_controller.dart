import 'package:flutter/foundation.dart';
import '../../../../core/errors/api_exception.dart';
import '../../data/foundation_repository.dart';
import '../../models/foundation_data.dart';

class FoundationController extends ChangeNotifier {
  final FoundationRepository repository;
  FoundationController(this.repository);
  List<Collaboration> collaborations = [];
  List<ReceivedInvitation> invitations = [];
  List<ProfileReview> reviews = [];
  List<DocumentVersion> documents = [];
  DriverContact? contact;
  String? error, documentError;
  bool loading = false, busy = false, _disposed = false;
  int _revision = 0;
  int _operation = 0;
  bool get signedIn => repository.session.signedIn;
  void _changed() {
    if (!_disposed) notifyListeners();
  }

  Future<void> load(String id) async {
    final started = ++_revision;
    loading = true;
    error = null;
    documentError = null;
    _changed();
    try {
      final contacts = await repository.contact();
      final links = await repository.collaborations();
      final received = await repository.invitations();
      final history = await repository.reviews(id);
      List<DocumentVersion> versions = [];
      String? docError;
      try {
        versions = await repository.documents(id);
      } on ApiException catch (failure) {
        docError = failure.status == 404
            ? 'Chức năng giấy tờ demo chưa khả dụng.'
            : failure.toString();
      }
      if (started != _revision || _disposed) return;
      contact = contacts;
      collaborations = links;
      invitations = received;
      reviews = history;
      documents = versions;
      documentError = docError;
    } catch (failure) {
      if (started == _revision) error = failure.toString();
    } finally {
      if (started == _revision) {
        loading = false;
        _changed();
      }
    }
  }

  Future<void> run(String driverId, Future<void> Function() action) async {
    if (busy) return;
    final started = _revision;
    final operation = ++_operation;
    busy = true;
    error = null;
    _changed();
    try {
      await action();
      if (started == _revision && !_disposed) await load(driverId);
    } catch (failure) {
      if (started == _revision) error = failure.toString();
    } finally {
      if (operation == _operation && !_disposed) {
        busy = false;
        _changed();
      }
    }
  }

  Future<void> updateContact(String id, String phone, String address) =>
      run(id, () => repository.updateContact(phone, address));
  Future<void> end(String id, Collaboration item) =>
      run(id, () => repository.end(item));
  Future<void> upload(String id, List<int> bytes, String name) =>
      run(id, () => repository.upload(id, bytes, name));
  Future<void> documentAction(
    String driverId,
    String versionId,
    String action,
  ) => run(driverId, () => repository.documentAction(versionId, action));
  Future<List<int>> preview(String id) => repository.preview(id);
  void clear() {
    _revision++;
    _operation++;
    collaborations = [];
    invitations = [];
    reviews = [];
    documents = [];
    contact = null;
    error = null;
    documentError = null;
    loading = false;
    busy = false;
    _changed();
  }

  @override
  void dispose() {
    _disposed = true;
    _revision++;
    _operation++;
    super.dispose();
  }
}
