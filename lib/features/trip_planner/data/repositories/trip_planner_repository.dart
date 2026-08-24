import '../models/trip_plan_request.dart';
import '../models/trip_plan_model.dart';

abstract class TripPlannerRepository {
  Future<TripPlanModel> generatePlan(TripPlanRequest request);
}
