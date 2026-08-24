import '../models/trip_plan_model.dart';
import '../models/trip_plan_request.dart';
import '../services/trip_planner_service.dart';
import 'trip_planner_repository.dart';

class TripPlannerRepositoryImpl implements TripPlannerRepository {
  const TripPlannerRepositoryImpl({required TripPlannerService service})
    : _service = service;

  final TripPlannerService _service;

  @override
  Future<TripPlanModel> generatePlan(TripPlanRequest request) {
    return _service.generateTripPlan(
      destination: request.destination,
      latitude: request.latitude,
      longitude: request.longitude,
      startDate: request.startDate,
      days: request.days,
      budget: request.budget,
      travelers: request.travelers,
      interests: request.interests,
    );
  }
}
