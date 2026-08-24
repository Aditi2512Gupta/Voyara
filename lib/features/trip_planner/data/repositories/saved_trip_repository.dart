import '../models/saved_trip_model.dart';
import '../services/saved_trip_service.dart';

class SavedTripRepository {
  const SavedTripRepository({
    required SavedTripService service,
  }) : _service = service;

  final SavedTripService _service;

  Future<void> saveTrip(
    SavedTripModel trip,
  ) {
    return _service.saveTrip(trip);
  }

  Stream<List<SavedTripModel>> getTrips() {
    return _service.getTrips();
  }

  Future<void> deleteTrip(
    String id,
  ) {
    return _service.deleteTrip(id);
  }
}