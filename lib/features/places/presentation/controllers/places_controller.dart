import 'package:flutter/foundation.dart';
import '../../data/places_repository.dart';
import '../../models/transport_place.dart';

class PlacesController extends ChangeNotifier {
  final PlacesRepository repository;
  List<TransportPlace> items = [];
  String query = '';
  String? error;
  int page = 1, totalPages = 0, total = 0;
  bool loading = false, _disposed = false;
  int _revision = 0;
  late int _generation;
  PlacesController(this.repository) {
    _generation = repository.session.generation;
    repository.session.addListener(_sessionChanged);
  }
  void _sessionChanged() {
    if (_generation == repository.session.generation) return;
    _generation = repository.session.generation;
    _revision++;
    items = [];
    error = null;
    total = 0;
    totalPages = 0;
    loading = false;
    if (!_disposed) notifyListeners();
  }

  Future<void> search(String value, {int pageNumber = 1}) async {
    if (value.trim().length > 100) {
      _revision++;
      loading = false;
      error = 'Tên hoặc địa chỉ tối đa 100 ký tự.';
      notifyListeners();
      return;
    }
    final revision = ++_revision;
    query = value.trim();
    loading = true;
    error = null;
    notifyListeners();
    try {
      final result = await repository.search(query, pageNumber);
      if (_disposed || revision != _revision) return;
      items = result.items;
      page = result.pageNumber;
      totalPages = result.totalPages;
      total = result.totalRecords;
    } catch (failure) {
      if (!_disposed && revision == _revision) {
        error = failure.toString();
        items = [];
        total = 0;
        totalPages = 0;
      }
    } finally {
      if (!_disposed && revision == _revision) {
        loading = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _revision++;
    repository.session.removeListener(_sessionChanged);
    super.dispose();
  }
}
