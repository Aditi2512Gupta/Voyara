import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/saved_trip_model.dart';
import '../data/repositories/saved_trip_repository.dart';
import '../data/services/saved_trip_service.dart';

final savedTripServiceProvider =
    Provider(
      (ref) => SavedTripService(),
    );

final savedTripRepositoryProvider =
    Provider(
      (ref) => SavedTripRepository(
        service: ref.read(savedTripServiceProvider),
      ),
    );

final savedTripsProvider =
    StreamProvider<List<SavedTripModel>>(
      (ref) {
        return ref
            .read(savedTripRepositoryProvider)
            .getTrips();
      },
    );