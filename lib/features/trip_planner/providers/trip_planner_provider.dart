import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/trip_plan_model.dart';
import '../data/models/trip_plan_request.dart';
import '../data/repositories/trip_planner_repository.dart';
import '../data/repositories/trip_planner_repository_impl.dart';
import '../data/services/gemini_trip_planner_service.dart';

final tripPlannerServiceProvider = Provider(
  (ref) => GeminiTripPlannerService(),
);

final tripPlannerRepositoryProvider = Provider<TripPlannerRepository>(
  (ref) => TripPlannerRepositoryImpl(
    service: ref.read(tripPlannerServiceProvider),
  ),
);

class TripPlanNotifier extends StateNotifier<AsyncValue<TripPlanModel?>> {
  TripPlanNotifier(this._repository)
      : super(const AsyncData(null));

  final TripPlannerRepository _repository;

  Future<void> generatePlan(
    TripPlanRequest request,
  ) async {
    state = const AsyncLoading();

    try {
      final plan = await _repository.generatePlan(request);

      state = AsyncData(plan);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final tripPlanProvider =
    StateNotifierProvider<
        TripPlanNotifier,
        AsyncValue<TripPlanModel?>>(
  (ref) => TripPlanNotifier(
    ref.read(tripPlannerRepositoryProvider),
  ),
);