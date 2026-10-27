import '../../../../core/services/notification_service.dart';
import '../models/saved_trip_model.dart';
import '../services/saved_trip_service.dart';

class SavedTripRepository {
  const SavedTripRepository({
    required SavedTripService service,
  }) : _service = service;

  final SavedTripService _service;

  Future<void> saveTrip(
    SavedTripModel trip,
  ) async {
    await _service.saveTrip(trip);

    try {
      await NotificationService.instance.scheduleTripReminder(
        destination: trip.destination,
        travelDate: trip.startDate,
        tripId: trip.id,
      );
    } catch (_) {}
  }

  Future<void> updateTrip(
    SavedTripModel trip,
  ) async {
    await _service.updateTrip(trip);

    try {
      await NotificationService.instance.scheduleTripReminder(
        destination: trip.destination,
        travelDate: trip.startDate,
        tripId: trip.id,
      );
    } catch (_) {}
  }

  Stream<List<SavedTripModel>> getTrips() {
    return _service.getTrips();
  }

  Future<void> deleteTrip(
    String id,
  ) async {
    await _service.deleteTrip(id);

    try {
      await NotificationService.instance.cancelTripReminder(id);
    } catch (_) {}
  }
}