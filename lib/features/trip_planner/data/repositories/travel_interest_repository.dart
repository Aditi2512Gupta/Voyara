import '../models/travel_interest_model.dart';
import '../services/travel_interest_service.dart';

class TravelInterestRepository {
  const TravelInterestRepository({
    required TravelInterestService service,
  }) : _service = service;

  final TravelInterestService _service;

  Future<List<TravelInterestModel>> getInterests() {
    return _service.getInterests();
  }
}