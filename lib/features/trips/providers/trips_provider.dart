import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../bookings/providers/booking_provider.dart';
import '../../bookings/data/models/booking_model.dart';
import '../data/models/trip_status.dart';
import '../data/models/trip_filter.dart';
import 'trip_filter_provider.dart';

final tripsProvider = Provider<AsyncValue<List<BookingModel>>>((ref) {
  final filter = ref.watch(tripFilterProvider);
  final bookings = ref.watch(bookingsProvider);

  return bookings.whenData((trips) {
    final sortedTrips = [...trips]
      ..sort((a, b) => a.travelDate.compareTo(b.travelDate));

    switch (filter) {
      case TripFilter.all:
        return sortedTrips;

      case TripFilter.upcoming:
        return sortedTrips
            .where((e) => e.status == TripStatus.upcoming)
            .toList();

      case TripFilter.completed:
        return sortedTrips.where((e) => e.status == TripStatus.completed).toList();

      case TripFilter.cancelled:
        return sortedTrips.where((e) => e.status == TripStatus.cancelled).toList();
    }
  });
});
