import '../models/trip_plan_model.dart';

abstract class TripPlannerService {
  Future<TripPlanModel> generateTripPlan({
    required String destination,
    required double latitude,
    required double longitude,
    required DateTime startDate,
    required int days,
    required double budget,
    required int travelers,
    required List<String> interests,
  });
}
