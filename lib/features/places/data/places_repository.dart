import '../../../core/network/paged_result.dart';
import '../../../core/session/session_client.dart';
import '../models/transport_place.dart';

class PlacesRepository {
  final SessionClient session;
  PlacesRepository(this.session);
  Future<PagedResult<TransportPlace>> search(
    String query,
    int page,
  ) => session.request(
    'GET',
    'locations/shared?search=${Uri.encodeQueryComponent(query)}&pageNumber=$page&pageSize=20',
    decode: (value) => PagedResult.fromJson(value, TransportPlace.fromJson),
  );
}
